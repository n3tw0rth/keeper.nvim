local buffers = require("keeper.buffers")
local constants = require("keeper.constants")

local M = {}

---@return integer? bufnr of the keeper buffer when it already exists
local find_existing_buffer = function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf)
        and vim.api.nvim_buf_get_name(buf) == constants.KEEPER_BUFFER_NAME then
      return buf
    end
  end
end

--- Show the keeper buffer in the current window, creating it when needed.
--- The keymap and autocmds are registered only on creation, and the buffer
--- is wiped when hidden, so they are never registered twice.
---@return integer bufnr
M.create_the_buffer = function()
  local existing = find_existing_buffer()
  if existing ~= nil then
    vim.api.nvim_set_current_buf(existing)
    return existing
  end

  local buf = vim.api.nvim_create_buf(false, false)
  -- the name marks the buffer as ours, so actions never touch other buffers
  vim.api.nvim_buf_set_name(buf, constants.KEEPER_BUFFER_NAME)
  vim.bo[buf].buftype = "acwrite"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false

  vim.keymap.set("n", "<CR>", function()
    require("keeper.functions").enter_buffer()
  end, { buffer = buf, silent = true, desc = "Open the buffer under the cursor" })

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    desc = "Close the buffers removed from the keeper list",
    callback = function()
      require("keeper.functions").update_buffers()
    end,
  })

  vim.api.nvim_create_autocmd("BufReadCmd", {
    buffer = buf,
    desc = "Refresh the keeper list on :edit",
    callback = function()
      M.populate_buffer(buf)
    end,
  })

  vim.api.nvim_win_set_buf(0, buf)
  return buf
end

--- Open the keeper buffer and fill it with the listed buffers.
---@return integer bufnr
M.view_buffer = function()
  local buf = M.create_the_buffer()
  M.populate_buffer(buf)
  return buf
end

--- Fill the keeper buffer with one line per listed buffer.
---@param buf integer
M.populate_buffer = function(buf)
  local lines = {}
  for _, info in ipairs(buffers.get_listed_buffers()) do
    table.insert(lines, buffers.display_name(info.name))
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modified = false
end

return M
