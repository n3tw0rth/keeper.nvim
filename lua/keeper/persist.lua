local buffers = require("keeper.buffers")

local M = {}

---@class KeeperSavedBuffer
---@field file string absolute path of the file
---@field line integer line the cursor was on when the list was saved

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

--- Save the listed buffers for the current working directory.
---@param config KeeperConfig
M.save_buffers = function(config)
  local path = config.save_n_restore.save_file

  local entries = {}
  for _, info in ipairs(buffers.get_listed_buffers()) do
    table.insert(entries, { file = info.name, line = info.lnum })
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
--- are only added to the list; Neovim loads them when they are entered.
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
    end
  end
end

return M
