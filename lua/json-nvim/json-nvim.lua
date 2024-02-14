local jq = require("json-nvim.jq")
local utils = require("json-nvim.utils")

local M = {}

function M.format_file()
    vim.cmd("%!jq")
end

function M.minify_file()
    vim.cmd("%!jq -c")
end

function M.minify_selection()
    local selection = utils.get_visual_selection()
    local is_valid = jq.is_valid(selection)
    if is_valid == false then
        print("marked text is not json object or array and can't be minified")
        return
    end

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

function M.format_selection()
    local selection = utils.get_visual_selection()
    local is_valid = jq.is_valid(selection)

    if is_valid == false then
        print("marked text is not json object or array and can't be formatted")
        return
    end

    local value_node = vim.treesitter.get_node({})
    if value_node == nil then
        error("can't get treesitter node")
        return
    end

    local buf_id = vim.api.nvim_get_current_buf()

    local target_json = vim.treesitter.get_node_text(value_node, buf_id)
    if target_json == nil or target_json == "" then
        error("content was nil or empty")
        return
    end

    local formatted = jq.get_formatted(target_json)
    if formatted == nil or formatted == "" then
        error("result was nil or empty")
        return
    end
    local lines = utils.split(formatted, "\n\r")

    local indentation_node = value_node
    while true do
        if indentation_node:type() == "document" then
            break
        end

        if indentation_node:type() ~= "pair" then
            indentation_node = indentation_node:parent()
        else
            break
        end
    end

    local _, start_col, _ = indentation_node:start()

    if not (value_node:prev_named_sibling() ~= nil and value_node:prev_named_sibling():type() == "string") then
        start_col = start_col + 2
    end

    local space = ""
    for _ = 1, start_col do
        space = space .. " "
    end
    for i = 2, #lines do
        lines[i] = space .. lines[i]
    end
    local start_row, start_col, end_row, end_col = value_node:range()
    vim.api.nvim_buf_set_text(vim.api.nvim_get_current_buf(), start_row, start_col, end_row, end_col, lines)
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

function M.format_token()
    local target_node, target_json, err = utils.get_nearest_token_and_content()
    if err then
        error("could not get target_json")
        return
    end

    local formatted = jq.get_formatted(target_json)
    if formatted == nil or formatted == "" then
        error("result was nil or empty")
        return
    end
    local lines = utils.split(formatted, "\n\r")

    local indentation_node = target_node
    while true do
        if indentation_node:type() == "document" or indentation_node:type() == "pair" then
            break
        else
            indentation_node = indentation_node:parent()
        end
    end

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
