local buffers   = require("keeper.buffers")
local constants = require("keeper.constants")
local functions = require("keeper.functions")
local view      = require("keeper.view")

--- Add a listed buffer for a path, like an open file.
---@param path string
---@return integer bufnr, string absolute path
local add_file_buffer = function(path)
  local abs = vim.fn.fnamemodify(path, ":p")
  local buf = vim.fn.bufadd(abs)
  vim.bo[buf].buflisted = true
  return buf, abs
end

---@return string[] display names of the listed buffers, sorted
local listed_names = function()
  local names = {}
  for _, info in ipairs(buffers.get_listed_buffers()) do
    table.insert(names, buffers.display_name(info.name))
  end
  table.sort(names)
  return names
end

--- Remove the line matching the given text from a buffer.
local remove_line = function(buf, text)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, line in ipairs(lines) do
    if line == text then
      vim.api.nvim_buf_set_lines(buf, i - 1, i, false, {})
      return
    end
  end
  error("line not found in keeper buffer: " .. text)
end

describe("update_buffers", function()
  before_each(function()
    vim.cmd("silent! %bwipeout!")
  end)

  it("deletes only the buffer whose line was removed", function()
    add_file_buffer("foo.lua")
    add_file_buffer("bar.lua")

    local keeper_buf = view.view_buffer()
    remove_line(keeper_buf, "bar.lua")
    functions.update_buffers()

    assert.same({ "foo.lua" }, listed_names())
  end)

  it("does not keep a buffer just because its name is a substring of another (#25)", function()
    add_file_buffer("foo.lua")
    add_file_buffer("dir/foo.lua")

    local keeper_buf = view.view_buffer()
    remove_line(keeper_buf, "foo.lua")
    functions.update_buffers()

    assert.same({ "dir/foo.lua" }, listed_names())
  end)

  it("handles names containing Lua pattern characters (#25)", function()
    add_file_buffer("file-with-dash.lua")
    add_file_buffer("file (copy).lua")
    add_file_buffer("plain.lua")

    local keeper_buf = view.view_buffer()
    remove_line(keeper_buf, "plain.lua")
    functions.update_buffers()

    assert.same({ "file (copy).lua", "file-with-dash.lua" }, listed_names())
  end)

  it("closes everything and leaves the view when all lines are removed", function()
    add_file_buffer("foo.lua")
    add_file_buffer("bar.lua")

    local keeper_buf = view.view_buffer()
    vim.api.nvim_buf_set_lines(keeper_buf, 0, -1, false, {})
    functions.update_buffers()

    assert.same({}, listed_names())
    -- the keeper buffer was replaced with an empty one in the only window
    assert.equals("", vim.api.nvim_buf_get_name(0))
  end)

  it("does nothing outside the keeper buffer", function()
    local buf, _ = add_file_buffer("foo.lua")
    vim.api.nvim_set_current_buf(buf)

    functions.update_buffers()

    assert.same({ "foo.lua" }, listed_names())
  end)
end)

describe("enter_buffer", function()
  before_each(function()
    vim.cmd("silent! %bwipeout!")
  end)

  it("opens the buffer named on the cursor line", function()
    local _, foo = add_file_buffer("foo.lua")
    add_file_buffer("bar.lua")

    local keeper_buf = view.view_buffer()
    local lines = vim.api.nvim_buf_get_lines(keeper_buf, 0, -1, false)
    for i, line in ipairs(lines) do
      if line == "foo.lua" then
        vim.api.nvim_win_set_cursor(0, { i, 0 })
      end
    end

    functions.enter_buffer()

    assert.equals(foo, vim.api.nvim_buf_get_name(0))
  end)

  it("stays on the keeper buffer when the line matches nothing", function()
    add_file_buffer("foo.lua")

    local keeper_buf = view.view_buffer()
    vim.api.nvim_buf_set_lines(keeper_buf, 0, -1, false, { "does-not-exist.lua" })
    functions.enter_buffer()

    assert.equals(constants.KEEPER_BUFFER_NAME, vim.api.nvim_buf_get_name(0))
  end)
end)
