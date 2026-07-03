--- Fallback for installs that never call require("keeper").setup()
--- (e.g. plain vim-plug). Runs after user config; a user setup() wins.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local keeper = require("keeper")
    if not keeper.did_setup then
      keeper.setup()
    end
  end,
})
