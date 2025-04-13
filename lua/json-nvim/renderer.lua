local utils = require("json-nvim.utils")

---replaces whole json in the buffer
---@param replacement string[] each element is each buffer line
local function render_root_token(replacement)
    local root = utils.get_treesitter_root()
    utils.replace_tsnode_text(root, replacement)
end

---replaces specified json token with provided replacement json
---@param target_node TSNode treesitter node representing json token which will be modified
---@param replacement string[] replacement json for target_node token
local function render_specific_token(target_node, replacement)
    local fline = replacement[1]
    -- removing leading extra spaces
    -- from the first line to avoid shifting
    fline = fline:gsub("^%s+", "")
    replacement[1] = fline

    local start_row, start_col, end_row, end_col = target_node:range()
    local cur_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_text(cur_buf, start_row, start_col, end_row, end_col, replacement)
end

return {
    render_root_token = render_root_token,
    render_specific_token = render_specific_token,
}
