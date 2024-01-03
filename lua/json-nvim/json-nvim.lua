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
end

return M
