local escaper = require("json-nvim.escaper")
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
    escaper.escape_file()
end

function M.unescape_file()
    escaper.unescape_file()
end

function M.escape_selection()
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

    local escaped = escaper.get_escaped(json)
    utils.replace_tsnode_text(target_node, escaped)
end

function M.unescape_selection()
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

    local escaped_json = vim.treesitter.get_node_text(target_node, buf_id)
    if escaped_json == nil or escaped_json == "" then
        error("content was nil or empty")
        return
    end

    local unescaped = escaped_json
    local function get_unescaped()
        local is_escaped = unescaped:sub(1, 1) == '"'
        if is_escaped == false then
            return unescaped
        end

        unescaped = escaper.get_unescaped(unescaped)
        return get_unescaped()
    end

    unescaped = get_unescaped()
    utils.replace_tsnode_text(target_node, unescaped)
end

local function switch_casing(to)
    local jq_modules = utils.get_jq_modules_directory()

    local target_json = utils.get_buffer_content_as_string()
    target_json = jq.get_collapsed(target_json)
    local keys = jq.get_keys(target_json)
    local from = utils.get_casing(keys)
    from = "from_" .. from
    local modified = jq.switch_key_casing_to(to, from, target_json, jq_modules)
    local root = utils.get_treesitter_root()
    minifier.minify_and_put(modified, root)
    formatter.format_file()
end

function M.switch_to_snake_case()
    switch_casing("to_snake")
end

function M.switch_to_camel_case()
    switch_casing("to_camel")
end

function M.switch_to_pascal_case()
    switch_casing("to_pascal")
end

return M
