local jq = require("json_nvim.jq")
local utils = require("json_nvim.utils")

local M = {}

function M.minify_string(json_string)
    local result = jq.get_collapsed(json_string)
    assert(result and result ~= "", "minified result was nil or empty")
    return result
end

function M.minify_file()
    local content = utils.get_buffer_content_as_string()
    local minified = M.minify_string(content)
    local root = utils.get_treesitter_root()
    utils.replace_tsnode_text(root, minified)
end

---minifies and puts input json to current buffer's target node
---@param input_json string
---@param target_node TSNode
function M.minify_and_put(input_json, target_node)
    local minified = M.minify_string(input_json)
    utils.replace_tsnode_text(target_node, minified)
end

return M
