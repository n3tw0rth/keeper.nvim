
oil.nvim inspired nvim plugin to manage buffers and persists open buffers when you close nvim. (scrub.nvim renamed to keeper.nvim)

## Features

* **Effortless Buffer Management**: Quickly close unwanted buffers by updating the buffer (eg: `dd` to remove a line).
* **Session Persistence**: Save and restore the current buffer state across Neovim sessions.
* **Inspired by oil.nvim**: Designed with simplicity and efficiency in mind, drawing inspiration from the `oil.nvim` plugin.


## Installation

Install `keeper.nvim` using your preferred Neovim plugin manager:

**Using Lazy.nvim**:

```lua
return {
    "n3tw0rth/keeper.nvim",
    config = function()
        require("scrub").setup()
    end
}
```

**Using Packer**:

```lua
use {
    "n3tw0rth/keeper.nvim",
    config = function()
        require("scrub").setup()
    end
}
```

**Using Vim-Plug**:

```vim
Plug 'n3tw0rth/scrub.nvim'
```

## Usage

After installation, you should add the following key mapping to your Neovim configuration to open the plugin. You can also run :Scrub to open the plugin.

```lua
vim.keymap.set("n", "_", "<CMD>Scrub<CR>", { desc = "Open Scrub" })
```

then pressing `_` anytime will open the plugin (in normal mode).

Let's say you removed the unwanted buffers by editing the scrub buffer, then you can save the current buffer by running `:w`. Then if you run `:ls` you should see the unwanted buffers are removed and things clean for you to continue work on.

Then you shall press `Enter` on the required buffer or use a plugin like telescope to open the buffer you want to work on.

Note: the plugin by default saves the current open buffers in `/tmp/scrub.lua` and you will loose the save file when system shutdown. This will improved and will make configurable in the next release.


## Requirements

- Too many open buffers and urge clean that up. 


## Configuration

Will be availble in a future release


##  License

This plugin is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.


##  Feedback and Contributions

Your feedback and contributions are welcome! If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request on the [GitHub repository](https://github.com/n3tw0rth/scrub.nvim).
