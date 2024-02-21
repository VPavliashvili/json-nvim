local formatter = require("json-nvim.formatter")
local jq = require("json-nvim.jq")
local minifier = require("json-nvim.minifier")
local utils = require("json-nvim.utils")

local M = {}

function M.format_file()
    formatter.format_file()
end

function M.minify_file()
    minifier.minify_file()
end

function M.minify_selection()
    local selection = utils.get_visual_selection()
    local is_valid = jq.is_valid(selection)
    if is_valid == false then
        print("marked text is not a valid json object or array and can't be minified")
        return
    end

    local target_node = vim.treesitter.get_node({})
    if target_node == nil then
        error("can't get treesitter node")
        return
    end

    local buf_id = vim.api.nvim_get_current_buf()

    -- json array or object which should be minified
    local input_json = vim.treesitter.get_node_text(target_node, buf_id)
    if input_json == nil or input_json == "" then
        error("content is nil or empty")
        return
    end

    minifier.minify_and_put(input_json, target_node)
end

function M.format_selection()
    local selection = utils.get_visual_selection()
    local is_valid = jq.is_valid(selection)

    if is_valid == false then
        print("marked text is not a valid json object or array and can't be formatted")
        return
    end

    local target_node = vim.treesitter.get_node({})
    if target_node == nil then
        error("can't get treesitter node")
        return
    end

    local buf_id = vim.api.nvim_get_current_buf()

    local json = vim.treesitter.get_node_text(target_node, buf_id)
    if json == nil or json == "" then
        error("content was nil or empty")
        return
    end

    formatter.format_and_put(json, target_node)
end

function M.minify_token()
    local target_node, input_json, err = utils.get_nearest_token_and_content()
    if err then
        error("could not get target_json")
        return
    end

    minifier.minify_and_put(input_json, target_node)
end

function M.format_token()
    local target_node, json, err = utils.get_nearest_token_and_content()
    if err then
        error("could not get target_json")
        return
    end

    formatter.format_and_put(json, target_node)
end

function M.escape_file()
    local root = utils.get_treesitter_root()

    local content = utils.get_buffer_content_as_string()
    local escaped = utils.get_escaped_input(content)
    utils.replace_tsnode_text(root, escaped)
end

function M.unescape_file()
    local root = utils.get_treesitter_root()
    local content = utils.get_buffer_content_as_string()

    local is_escaped = content:sub(1, 1) == '"'
    if is_escaped == false then
        return
    end

    local unescaped = utils.get_unescaped_input(content)
    utils.replace_tsnode_text(root, unescaped)

    M.unescape_file()
end

return M
