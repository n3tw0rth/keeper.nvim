local buffers = require("keeper.buffers")
local persist = require("keeper.persist")

describe("persist", function()
  local tmp_dir
  local save_file
  local config

  --- Create a real file on disk and return its absolute path.
  ---@param name string
  ---@return string
  local create_file = function(name)
    local path = tmp_dir .. "/" .. name
    local file = assert(io.open(path, "w"))
    file:write("content\n")
    file:close()
    return path
  end

  ---@param path string
  ---@return integer bufnr
  local open_listed = function(path)
    local buf = vim.fn.bufadd(path)
    vim.bo[buf].buflisted = true
    return buf
  end

  ---@return table decoded save file contents
  local read_save_file = function()
    local file = assert(io.open(save_file, "r"))
    local content = file:read("*a")
    file:close()
    return vim.json.decode(content)
  end

  before_each(function()
    vim.cmd("silent! %bwipeout!")
    tmp_dir = vim.fn.tempname()
    vim.fn.mkdir(tmp_dir, "p")
    -- the save file's directory does not exist yet: the first-run case (#28)
    save_file = tmp_dir .. "/keeper/buffers.json"
    config = { save_n_restore = { enabled = true, save_file = save_file } }
  end)

  it("saves on the very first run, when no save file exists (#28)", function()
    local path = create_file("a.lua")
    open_listed(path)

    persist.save_buffers(config)

    local entries = read_save_file()[vim.fn.getcwd()]
    assert.equals(1, #entries)
    assert.equals(path, entries[1].file)
  end)

  it("restores the buffers saved for the cwd", function()
    local a = create_file("a.lua")
    local b = create_file("b.lua")
    open_listed(a)
    open_listed(b)

    persist.save_buffers(config)
    vim.cmd("silent! %bwipeout!")
    assert.same({}, buffers.get_listed_buffers())

    persist.restore_buffers(config)

    local names = {}
    for _, info in ipairs(buffers.get_listed_buffers()) do
      names[info.name] = true
    end
    assert.is_true(names[a])
    assert.is_true(names[b])
  end)

  it("skips saved files that no longer exist on disk", function()
    local a = create_file("a.lua")
    local b = create_file("b.lua")
    open_listed(a)
    open_listed(b)

    persist.save_buffers(config)
    vim.cmd("silent! %bwipeout!")
    os.remove(b)

    persist.restore_buffers(config)

    local listed = buffers.get_listed_buffers()
    assert.equals(1, #listed)
    assert.equals(a, listed[1].name)
  end)

  it("ignores a corrupt save file and can save over it", function()
    vim.fn.mkdir(vim.fn.fnamemodify(save_file, ":h"), "p")
    local file = assert(io.open(save_file, "w"))
    file:write("this is { not json")
    file:close()

    assert.has_no.errors(function()
      persist.restore_buffers(config)
    end)

    local path = create_file("a.lua")
    open_listed(path)
    persist.save_buffers(config)

    local entries = read_save_file()[vim.fn.getcwd()]
    assert.equals(path, entries[1].file)
  end)

  it("keeps the lists saved for other directories", function()
    local other_cwd_entries = { { file = "/some/other/project/file.lua", line = 3 } }
    vim.fn.mkdir(vim.fn.fnamemodify(save_file, ":h"), "p")
    local file = assert(io.open(save_file, "w"))
    file:write(vim.json.encode({ ["/some/other/project"] = other_cwd_entries }))
    file:close()

    open_listed(create_file("a.lua"))
    persist.save_buffers(config)

    local data = read_save_file()
    assert.same(other_cwd_entries, data["/some/other/project"])
    assert.equals(1, #data[vim.fn.getcwd()])
  end)
end)
