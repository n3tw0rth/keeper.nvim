local persist = require("keeper.persist")
local view = require("keeper.view")

local M = {}

---@class KeeperSaveNRestoreConfig
---@field enabled boolean save the buffer list on exit and restore it on start
---@field save_file string path of the JSON file buffer lists are saved to

---@class KeeperConfig
---@field enabled boolean register the :Keeper command
---@field save_n_restore KeeperSaveNRestoreConfig

---@type KeeperConfig
local default_config = {
  enabled = true,
  save_n_restore = {
    enabled = true,
    save_file = vim.fn.stdpath("data") .. "/keeper/buffers.json",
  },
}

---@type KeeperConfig
M.config = default_config

--- Open the keeper buffer.
M.main = function()
  view.view_buffer()
end

--- True once setup() has run, so the plugin/keeper.lua fallback can tell
--- whether the user configured the plugin themselves.
M.did_setup = false

---@param config? KeeperConfig
M.setup = function(config)
  M.did_setup = true
  M.config = vim.tbl_deep_extend("force", default_config, config or {})

  -- clear=true keeps setup() idempotent: calling it again replaces the
  -- autocmds instead of stacking duplicates
  local augroup = vim.api.nvim_create_augroup("Keeper", { clear = true })

  if M.config.enabled then
    vim.api.nvim_create_user_command("Keeper", M.main, { desc = "Open the keeper buffer list" })
  end

  if M.config.save_n_restore.enabled then
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = augroup,
      desc = "Save the keeper buffer list",
      callback = function()
        persist.save_buffers(M.config)
      end,
    })

    if vim.v.vim_did_enter == 1 then
      -- setup() ran after startup (e.g. lazy-loaded), restore right away
      persist.restore_buffers(M.config)
    else
      vim.api.nvim_create_autocmd("VimEnter", {
        group = augroup,
        desc = "Restore the keeper buffer list",
        callback = function()
          persist.restore_buffers(M.config)
        end,
      })
    end
  end
end

return M
