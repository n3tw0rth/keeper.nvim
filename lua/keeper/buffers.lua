local constants = require("keeper.constants")

local M = {}

---@class KeeperBufferInfo
---@field bufnr integer
---@field name string absolute path of the file the buffer points to
---@field lnum integer line the cursor was last on in the buffer

--- Listed buffers that point to a file, excluding the keeper buffer itself.
---@return KeeperBufferInfo[]
M.get_listed_buffers = function()
  local buffers = {}
  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if info.name ~= "" and info.name ~= constants.KEEPER_BUFFER_NAME then
      table.insert(buffers, { bufnr = info.bufnr, name = info.name, lnum = info.lnum })
    end
  end
  return buffers
end

--- Path shown in the keeper buffer: relative to the cwd when possible.
---@param name string absolute path
---@return string
M.display_name = function(name)
  return vim.fn.fnamemodify(name, ":.")
end

--- Absolute path for a line of the keeper buffer.
---@param line string
---@return string
M.resolve_name = function(line)
  return vim.fn.fnamemodify(vim.trim(line), ":p")
end

return M
