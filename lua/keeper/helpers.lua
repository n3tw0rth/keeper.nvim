local constants = require("keeper.constants")

local M = {}

--- Whether the current buffer is the keeper buffer.
---@return boolean
M.is_the_plugin_buffer = function()
  return vim.api.nvim_buf_get_name(0) == constants.KEEPER_BUFFER_NAME
end

--- Focus the given buffer, optionally placing the cursor on a line.
---@param buf integer
---@param line? integer
M.focus_on_the_selected_buf = function(buf, line)
  vim.api.nvim_set_current_buf(buf)
  if line ~= nil then
    local last_line = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_win_set_cursor(0, { math.min(line, last_line), 0 })
  end
end

return M
