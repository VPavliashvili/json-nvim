local jq = require("json-nvim.jq")
local utils = require("json-nvim.utils")

---comment
---@param target_node TSNode
---@return TSNode
local function get_indentation_node(target_node)
    local indentation_node = target_node
    while true do
        if indentation_node:type() == "document" or indentation_node:type() == "pair" then
            break
        else
            indentation_node = indentation_node:parent() or indentation_node
        end
    end

    return indentation_node
end

local M = {}

--- formats and returns replacement text for whole file
--- @return string[] replacement text as array of lines of text
function M.get_formatted_file_content()
    local content = utils.get_buffer_content_as_string()
    local formatted = jq.get_formatted(content)
    if formatted == nil or formatted == "" then
        error("result was nil or empty")
    end
    local replacement = utils.split(formatted, "\n\r")

    return replacement
end

---returns formatted json from provided token
---@param input_json string
---@param target_node TSNode
function M.get_formatted_token(input_json, target_node)
    local formatted = jq.get_formatted(input_json)
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
end

return M
