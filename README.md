# json-nvim
`json-nvim` is a NeoVim plugin that aims to vastly improve json editing and processing experience with help of [jq](https://github.com/jqlang/jq?tab=readme-ov-file) and [Neovim Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

**🚧 NOTE: This plugin is developed on linux environment and support for mac is not tested. Also some functionality won't work on windows**

## Features
* Format whole file
* Format visual selection
* Format nearest json object/array under cursor
* Minify whole file
* Minify visual selection
* Minify nearest json object/array under cursor
* Escape whole file
* Unescape whole file
* Escape Selection
* Unescape Selection
* Switch keys to camelCase
* Switch keys to PascalCase
* Switch keys to snake_case

:warning: switching key cases is not supported on windows yet

## Prerequisites
* [jq](https://github.com/jqlang/jq?tab=readme-ov-file) installed and available on $PATH
* [Neovim Treesitter](https://github.com/nvim-treesitter/nvim-treesitter) with json module installed
* buffer filetype should be json [:h filetype](https://neovim.io/doc/user/filetype.html#filetypes)

## Installation
Using [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{
    "VPavliashvili/json-nvim"
}
``````

## Configuration 
There is not much needed but I reccomend to use keymaps, otherwise you can ignore this section <br>
For example setup with lazy.nvim like this
```lua
{
    "VPavliashvili/json-nvim",
    config = function()
        vim.keymap.set("n", "<leader>jff", '<cmd>JsonFormatFile<cr>')
        vim.keymap.set("n", "<leader>jmf", '<cmd>JsonMinifyFile<cr>')
    end,
}
``````

## Usage
These are all the available commands below with usage examples <br>
Commands involving visual mode always should be used with valid json selection
* `:JsonFormatFile`<details>
        <summary> see example </summary>
    </details>
* `:JsonMinifyFile`<details>
        <summary> see example </summary>
    </details>
* `:JsonFormatSelection`<details>
        <summary> see example </summary>
    </details>
* `:JsonMinifySelection`<details>
        <summary> see example </summary>
    </details>
* `:JsonFormatToken`<details>
        <summary> see example </summary>
    </details>
* `:JsonMinifyToken`<details>
        <summary> see example </summary>
    </details>
* `:JsonEscapeFile`<details>
        <summary> see example </summary>
    </details>
* `:JsonUnescapeFile`<details>
        <summary> see example </summary>
    </details>
* `:JsonEscapeSelection`<details>
        <summary> see example </summary>
    </details>
* `:JsonUnescapeSelection`<details>
        <summary> see example </summary>
    </details>
* `:JsonEscapeFile`<details>
        <summary> see example </summary>
    </details>
* `:JsonKeysToPascalCase`<details>
        <summary> see example </summary>
    </details>
* `:JsonKeysToSnakeCase`<details>
        <summary> see example </summary>
    </details>


## TODO

- [ ] Implement windows support for case switching
