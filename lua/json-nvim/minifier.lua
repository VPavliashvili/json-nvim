local jq = require("json-nvim.jq")
local utils = require("json-nvim.utils")

local M = {}

function M.minify_file()
    local content = utils.get_buffer_content_as_string()
    local minified = jq.get_collapsed(content)
    if minified == nil or minified == "" then
        error("result was nil or empty")
        return
    end

    local root = utils.get_treesitter_root()
    utils.replace_tsnode_text(root, minified)
end

---minifies and puts input json to current buffer's target node
---@param input_json string
---@param target_node TSNode
function M.minify_and_put(input_json, target_node)
    local minified = jq.get_collapsed(input_json)
    if minified == nil or minified == "" then
        error("result was nil or empty")
        return
    end

    utils.replace_tsnode_text(target_node, minified)
end

return M
