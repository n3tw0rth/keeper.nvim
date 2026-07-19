<div align="center">

# keeper.nvim

**Edit your buffer list like text. Keep it across sessions.**

[![GitHub stars](https://img.shields.io/github/stars/n3tw0rth/keeper.nvim?style=flat-square)](https://github.com/n3tw0rth/keeper.nvim/stargazers)
[![License](https://img.shields.io/github/license/n3tw0rth/keeper.nvim?style=flat-square)](LICENSE)
[![Neovim](https://img.shields.io/badge/Neovim-0.9%2B-57A143?style=flat-square&logo=neovim)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Made%20with-Lua-blue?style=flat-square&logo=lua)](https://www.lua.org)

</div>

An [oil.nvim](https://github.com/stevearc/oil.nvim)-inspired buffer manager. `:Keeper` opens your buffers as plain lines in a scratch buffer — delete a line, `:w`, and the buffer is closed. Your open buffers are saved per directory and restored the next time you start Neovim there.

> [!IMPORTANT]
> Formerly **scrub.nvim**. Update `require("scrub")` → `require("keeper")` and `:Scrub` → `:Keeper`.

## Features

- **Buffers as text** — manage buffers with the motions you already know (`dd`, visual delete, …)
- **Session persistence** — the buffer list is saved on exit, keyed by working directory, and restored on start
- **Zero-config** — works out of the box; `setup()` is optional
- **Lightweight** — pure Lua, no dependencies

## Install

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ "n3tw0rth/keeper.nvim", opts = {} }
```

Any plugin manager works — if you never call `setup()`, the defaults apply automatically.

## Usage

| Action | Effect |
| :--- | :--- |
| `:Keeper` | Open the buffer list |
| `dd` + `:w` | Close the removed buffers |
| `<CR>` | Jump to the buffer under the cursor |
| `:e` | Refresh the list |

```lua
vim.keymap.set("n", "_", "<CMD>Keeper<CR>", { desc = "Open Keeper" })
```

## Configuration

Defaults:

```lua
require("keeper").setup({
    -- register the :Keeper command
    enabled = true,

    save_n_restore = {
        -- save the buffer list on exit and restore it on start
        enabled = true,

        -- JSON file the buffer lists are saved to, keyed by cwd
        save_file = vim.fn.stdpath("data") .. "/keeper/buffers.json",
    },
})
```

Full documentation: `:help keeper`

## License

[MIT](LICENSE)
