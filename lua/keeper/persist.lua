local buffers = require("keeper.buffers")

local M = {}

---@class KeeperSavedBuffer
---@field file string absolute path of the file
---@field line integer 1-based line the cursor was on when the list was saved
---@field col? integer 0-based byte column of the cursor (missing in older save files)

--- Restored cursor positions of buffers that have not been displayed yet,
--- keyed by bufnr. Kept so saving again before a restored buffer is ever
--- opened does not lose its position.
---@type table<integer, integer[]>
M.pending_positions = {}

--- Read the save file, returning an empty table when the file is missing
--- or does not contain valid JSON.
---@param path string
---@return table<string, KeeperSavedBuffer[]> buffer lists keyed by cwd
local read_save_file = function(path)
  local file = io.open(path, "r")
  if file == nil then
    return {}
  end
  local content = file:read("*a")
  file:close()

  local ok, data = pcall(vim.json.decode, content)
  if not ok or type(data) ~= "table" then
    return {}
  end
  return data
end

--- Where the cursor is, or last was, in a buffer as a (1,0)-indexed
--- { line, col } pair. A window showing the buffer wins (the current one
--- first), since the '" mark is only updated when the buffer is left. A
--- restored buffer that was never shown keeps its restored position.
---@param bufnr integer
---@return integer[]
local cursor_position = function(bufnr)
  local wins = vim.fn.win_findbuf(bufnr)
  if #wins > 0 then
    local win = vim.api.nvim_get_current_win()
    if not vim.tbl_contains(wins, win) then
      win = wins[1]
    end
    return vim.api.nvim_win_get_cursor(win)
  end

  -- checked before the '" mark, which reads { 1, 0 } in a buffer that was
  -- restored but never loaded
  if M.pending_positions[bufnr] ~= nil then
    return M.pending_positions[bufnr]
  end

  local ok, mark = pcall(vim.api.nvim_buf_get_mark, bufnr, '"')
  if ok and mark[1] > 0 then
    return mark
  end

  return { 1, 0 }
end

--- Move the cursor of a window to a saved position, clamped to the buffer.
---@param win integer
---@param pos integer[] { line, col }
local set_cursor = function(win, pos)
  local last_line = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(win))
  -- nvim_win_set_cursor clamps the column itself, but not the line
  pcall(vim.api.nvim_win_set_cursor, win, { math.max(1, math.min(pos[1], last_line)), pos[2] })
end

--- Save the listed buffers for the current working directory.
---@param config KeeperConfig
M.save_buffers = function(config)
  local path = config.save_n_restore.save_file

  local entries = {}
  for _, info in ipairs(buffers.get_listed_buffers()) do
    local pos = cursor_position(info.bufnr)
    table.insert(entries, { file = info.name, line = pos[1], col = pos[2] })
  end

  local data = read_save_file(path)
  data[vim.fn.getcwd()] = entries

  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local file, err = io.open(path, "w")
  if file == nil then
    vim.notify("keeper.nvim: could not write " .. path .. ": " .. tostring(err), vim.log.levels.WARN)
    return
  end
  file:write(vim.json.encode(data))
  file:close()
end

--- Restore the buffers saved for the current working directory. Buffers
--- are only added to the list; Neovim loads them when they are entered,
--- and the cursor is moved to the saved position the first time they are
--- shown in a window.
---@param config KeeperConfig
M.restore_buffers = function(config)
  local entries = read_save_file(config.save_n_restore.save_file)[vim.fn.getcwd()]
  if entries == nil then
    return
  end

  for _, entry in ipairs(entries) do
    if type(entry) == "table" and type(entry.file) == "string"
        and vim.fn.filereadable(entry.file) == 1 then
      local buf = vim.fn.bufadd(entry.file)
      vim.bo[buf].buflisted = true

      -- an already loaded buffer (e.g. a file passed on the command line)
      -- keeps the cursor the user already has in it
      if type(entry.line) == "number" and not vim.api.nvim_buf_is_loaded(buf) then
        M.pending_positions[buf] = { entry.line, type(entry.col) == "number" and entry.col or 0 }
        vim.api.nvim_create_autocmd("BufWinEnter", {
          buffer = buf,
          once = true,
          desc = "Restore the keeper cursor position",
          callback = function(args)
            local pos = M.pending_positions[args.buf]
            M.pending_positions[args.buf] = nil
            if pos ~= nil then
              set_cursor(vim.api.nvim_get_current_win(), pos)
            end
          end,
        })
      end
    end
  end
end

return M
