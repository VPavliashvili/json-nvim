local jq = require("json_nvim.jq")
local utils = require("json_nvim.utils")

---comment
---@param target_node TSNode
---@return TSNode
local function get_indentation_node(target_node)
    local indentation_node = target_node
    while true do
        if indentation_node:type() == "document" or indentation_node:type() == "pair" then
            break
        else
            indentation_node = indentation_node:parent()
        end
    end

    return indentation_node
end

local M = {}

function M.format_string(json_string)
    local result = jq.get_formatted(json_string)
    assert(result and result ~= "", "minified result was nil or empty")
    return result
end

function M.format_file()
    local content = utils.get_buffer_content_as_string()
    local formatted = M.format_string(content)
    local replacement = utils.split(formatted, "\n\r")

    local root = utils.get_treesitter_root()
    utils.replace_tsnode_text(root, replacement)
end

--- formats and puts input json to current buffer's target node
---@param input_json string
---@param target_node TSNode
function M.format_and_put(input_json, target_node)
    local formatted = M.format_string(input_json)
    if formatted == nil or formatted == "" then
        error("result was nil or empty")
        return
    end
    local lines = utils.split(formatted, "\n\r")

    local indentation_node = get_indentation_node(target_node)
    local _, start_col = indentation_node:start()

    if not (target_node:prev_named_sibling() ~= nil and target_node:prev_named_sibling():type() == "string") then
        start_col = start_col + 2
    end

    local indentation = ""
    for _ = 1, start_col do
        indentation = indentation .. " "
    end
    for i = 2, #lines do
        lines[i] = indentation .. lines[i]
    end

    local start_row, start_col, end_row, end_col = target_node:range()
    local cur_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_text(cur_buf, start_row, start_col, end_row, end_col, lines)
end

return M
