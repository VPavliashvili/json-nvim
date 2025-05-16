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
    "jaredbarranco/json-nvim",
    ft = "json", -- only load for json filetype
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
        ![format_file](https://github.com/VPavliashvili/json-nvim/assets/40483227/a84930dd-c6f4-46a3-a9e8-7240c449cfe3)
    </details>
* `:JsonMinifyFile`<details>
        <summary> see example </summary>
        ![minify_file](https://github.com/VPavliashvili/json-nvim/assets/40483227/c36d590d-006f-45e8-9e96-d7d91537eddd)
    </details>
* `:JsonFormatSelection`<details>
        <summary> see example </summary>
        ![format_selection](https://github.com/VPavliashvili/json-nvim/assets/40483227/03d6dccf-774b-46e0-a37d-6cedc4fbc711)
    </details>
* `:JsonMinifySelection`<details>
        <summary> see example </summary>
        ![minify_selection](https://github.com/VPavliashvili/json-nvim/assets/40483227/b1b14d2e-e920-415b-9bf3-60afa920b3fd)
     </details>
* `:JsonFormatNode`<details>
        <summary> see example </summary>
    ![format_node](https://github.com/VPavliashvili/json-nvim/assets/40483227/7ba1bbe7-020e-41be-bd50-714aa22ff28c)
    </details>
* `:JsonMinifyNode`<details>
        <summary> see example </summary>
   ![minify_node](https://github.com/VPavliashvili/json-nvim/assets/40483227/d285497d-e863-49f9-965b-42ec14e0a5cd)
     </details>
* `:JsonEscapeFile`<details>
        <summary> see example </summary>
   ![escape_file](https://github.com/VPavliashvili/json-nvim/assets/40483227/2aef5259-6124-44d3-88c8-ac6ab12e5075)
     </details>
* `:JsonUnescapeFile`<details>
        <summary> see example </summary>
   ![unescape_file](https://github.com/VPavliashvili/json-nvim/assets/40483227/4431d2e7-a0a2-449d-bc2f-645a9499826a)
     </details>
* `:JsonEscapeSelection`<details>
        <summary> see example </summary>
   ![escape_selection](https://github.com/VPavliashvili/json-nvim/assets/40483227/af4d611b-c5eb-4c93-afa9-4a33a3cc0678)
     </details>
* `:JsonUnescapeSelection`<details>
        <summary> see example </summary>
   ![unescape_selection](https://github.com/VPavliashvili/json-nvim/assets/40483227/f78c2cd9-3f8f-4b83-b50c-ecdcb0a2627a)
     </details>
* `:JsonKeysToCamelCase`<details>
        <summary> see example </summary>
   ![to_camel](https://github.com/VPavliashvili/json-nvim/assets/40483227/b4dfdbd4-7145-4937-8955-3c2a1a9911df)
     </details>
* `:JsonKeysToPascalCase`<details>
        <summary> see example </summary>
   ![to_pascal](https://github.com/VPavliashvili/json-nvim/assets/40483227/2d33dc0f-86ff-4107-8aa7-a3003924ab80)
     </details>
* `:JsonKeysToSnakeCase`<details>
        <summary> see example </summary>
   ![to_snake](https://github.com/VPavliashvili/json-nvim/assets/40483227/044361a3-9e82-4fa6-81e8-7e55100b8a89)
     </details>


## TODO

- [ ] Implement windows support for case switching
- [x] Fix bug: Can't process long json buffers on windows due to [cmd string limitation](https://learn.microsoft.com/en-us/troubleshoot/windows-client/shell-experience/command-line-string-limitation)
