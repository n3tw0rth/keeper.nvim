local buffers = require("keeper.buffers")
local helpers = require("keeper.helpers")

local M = {}

--- Open the buffer named on the cursor line of the keeper buffer.
--- Mapped to <CR> inside the keeper buffer.
M.enter_buffer = function()
  if not helpers.is_the_plugin_buffer() then
    return
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
  local name = buffers.resolve_name(line)

  for _, buf in ipairs(buffers.get_listed_buffers()) do
    if buf.name == name then
      helpers.focus_on_the_selected_buf(buf.bufnr)
      return
    end
  end
end

--- Leave the keeper buffer once the list is empty. The keeper buffer has
--- bufhidden=wipe, so it is destroyed as soon as it is no longer shown.
local leave_empty_view = function()
  if #vim.api.nvim_list_wins() > 1 then
    vim.api.nvim_win_close(0, true)
  else
    vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(true, false))
  end
end

--- Delete every listed buffer whose line was removed from the keeper
--- buffer. Runs on :w (BufWriteCmd) in the keeper buffer.
M.update_buffers = function()
  if not helpers.is_the_plugin_buffer() then
    return
  end

  local keeper_buf = vim.api.nvim_get_current_buf()

  local kept = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(keeper_buf, 0, -1, false)) do
    if vim.trim(line) ~= "" then
      kept[buffers.resolve_name(line)] = true
    end
  end

  local remaining = 0
  for _, buf in ipairs(buffers.get_listed_buffers()) do
    if kept[buf.name] then
      remaining = remaining + 1
    else
      vim.api.nvim_buf_delete(buf.bufnr, { force = true })
    end
  end

  require("keeper.view").populate_buffer(keeper_buf)

  if remaining == 0 then
    leave_empty_view()
  end
end

return M
