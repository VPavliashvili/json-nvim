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
    local cmd = string.format("echo '%s' | jq -e .", selection)
    local is_valid = vim.fn.system(cmd)

    if is_valid:find("error") then
        print("marked text is not json object or array and can't be minified")
        return
    end

    local cur_node = vim.treesitter.get_node({})
    if cur_node == nil then
        print("can't get treesitter node")
        return
    end

    local buf_id = vim.api.nvim_get_current_buf()

    -- json array or object which should be minified
    local target_json = vim.treesitter.get_node_text(cur_node, buf_id)
    if target_json == nil or target_json == "" then
        print("content is nil or empty")
        return
    end

    if vim.loop.os_uname().sysname == "Windows_NT" then
        cmd = string.format('echo %s | jq . -c', target_json)
    else
        cmd = string.format("echo '%s' | jq . -c", target_json)
    end

    local minified = vim.fn.system(cmd)
    minified = minified:gsub("[\n\r]", "")
    if minified == nil or minified == "" then
        print(minified)
        return
    end

    local start_row, start_col, end_row, end_col = cur_node:range()
    vim.api.nvim_buf_set_text(
        vim.api.nvim_get_current_buf(),
        start_row,
        start_col,
        end_row,
        end_col,
        { minified }
    )

    -- local r = { old = target_json, new = minified, tp = cur_node:type() }
    -- vim.print(r)
end

function M.format_selection()
end

return M
