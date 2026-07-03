local constants = require("keeper.constants")
local view      = require("keeper.view")

---@param path string
local open_listed = function(path)
  local buf = vim.fn.bufadd(vim.fn.fnamemodify(path, ":p"))
  vim.bo[buf].buflisted = true
  return buf
end

describe("view", function()
  before_each(function()
    vim.cmd("silent! %bwipeout!")
  end)

  it("lists the open buffers, one per line, relative to the cwd", function()
    open_listed("lua/keeper/view.lua")
    open_listed("README.md")

    local buf = view.view_buffer()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    table.sort(lines)

    assert.same({ "README.md", "lua/keeper/view.lua" }, lines)
  end)

  it("does not list the keeper buffer itself", function()
    open_listed("README.md")

    local buf = view.view_buffer()
    -- populate again while the keeper buffer exists
    view.populate_buffer(buf)

    assert.same({ "README.md" }, vim.api.nvim_buf_get_lines(buf, 0, -1, false))
  end)

  it("is named and not modified after populating", function()
    open_listed("README.md")

    local buf = view.view_buffer()

    assert.equals(constants.KEEPER_BUFFER_NAME, vim.api.nvim_buf_get_name(buf))
    assert.is_false(vim.bo[buf].modified)
  end)

  it("reuses the existing keeper buffer instead of creating a second one", function()
    open_listed("README.md")

    local first = view.view_buffer()
    local second = view.view_buffer()

    assert.equals(first, second)
  end)
end)
