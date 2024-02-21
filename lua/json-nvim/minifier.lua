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

function M.minify_selection()
    local cur_node = vim.treesitter.get_node({})
    if cur_node == nil then
        error("can't get treesitter node")
        return
    end

    local buf_id = vim.api.nvim_get_current_buf()

    -- json array or object which should be minified
    local target_json = vim.treesitter.get_node_text(cur_node, buf_id)
    if target_json == nil or target_json == "" then
        error("content is nil or empty")
        return
    end

    local minified = jq.get_collapsed(target_json)
    if minified == nil or minified == "" then
        error("result was nil or empty")
        return
    end

    utils.replace_tsnode_text(cur_node, minified)
end

function M.minify_token()
    local token, target_json, err = utils.get_nearest_token_and_content()
    if err then
        error("could not get target_json")
        return
    end

    local minified = jq.get_collapsed(target_json)
    if minified == nil or minified == "" then
        error("result was nil or empty")
        return
    end

    utils.replace_tsnode_text(token, minified)
end

return M
