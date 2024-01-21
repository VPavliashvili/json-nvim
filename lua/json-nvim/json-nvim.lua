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
    local is_invalid = utils.validate_jq_input(selection)

    if is_invalid then
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

    local minified = utils.get_minified_jq(target_json)
    if minified == nil or minified == "" then
        error("result was nil or empty")
        return
    end

    utils.replace_tsnode_text(cur_node, minified)
end

function M.format_selection()
    local selection = utils.get_visual_selection()
    local is_invalid = utils.validate_jq_input(selection)

    if is_invalid then
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

    local formatted = utils.get_formatted_jq(target_json)
    if formatted == nil or formatted == "" then
        error("result was nil or empty")
        return
    end
    local lines = utils.split(formatted, "\n\r")

    local indentation_node = value_node
    local stop = 0
    while true do
        if indentation_node:type() ~= "pair" then
            indentation_node = indentation_node:parent()
        else
            break
        end
        stop = stop + 1
        if stop == 100000 then
            error("while loop stuck")
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

return M
