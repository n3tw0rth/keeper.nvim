-- Minimal config for running the specs headlessly (see `just test`).
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:prepend(root)

-- plenary provides the busted test harness
local plenary_dir = os.getenv("PLENARY_DIR") or (vim.fn.stdpath("data") .. "/lazy/plenary.nvim")
if vim.fn.isdirectory(plenary_dir) == 0 then
  error("plenary.nvim not found at " .. plenary_dir .. " (set PLENARY_DIR to override)")
end
vim.opt.runtimepath:prepend(plenary_dir)
vim.cmd("runtime plugin/plenary.vim")
