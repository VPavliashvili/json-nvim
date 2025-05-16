local escaper = require("json_nvim.escaper")
local formatter = require("json_nvim.formatter")
local jq = require("json_nvim.jq")
local minifier = require("json_nvim.minifier")
local utils = require("json_nvim.utils")

---sometimes buffer with valid json content is not
---set to `json` filetype, for example `log.log`
---this function will fix that
---@return boolean
local function validate_and_set_buffer_filetype()
    local res = true

    local content = utils.get_buffer_content_as_string()
    if jq.is_valid(content) == false then
        print("buffer content is not valid a json!")
        return false
    end

    local current = vim.bo.filetype
    if current ~= "json" then
        res = false
        vim.ui.input({ prompt = "current buffer filetype is not set to json, set it to json? y/n: " }, function(choice)
            if vim.opt.cmdheight._value ~= 0 then
                vim.cmd("normal! :")
            end

            if choice ~= "y" then
                print("json_nvim operation cancelled")
            else
                vim.bo.filetype = "json"
                res = true
                print("buffer filetype set to json")
            end
        end)
    end
    return res
end

---wraps validation
---@param operation function
local function validate_and_run_operation(operation)
    if validate_and_set_buffer_filetype() then
        operation()
    end
end

local M = {}

function M.format_file()
    validate_and_run_operation(formatter.format_file)
end

function M.minify_file()
    validate_and_run_operation(minifier.minify_file)
end

function M.minify_selection()
    validate_and_run_operation(function()
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
    end)
end

function M.format_selection()
    validate_and_run_operation(function()
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
    end)
end

function M.minify_token()
    validate_and_run_operation(function()
        local target_node, input_json, err = utils.get_nearest_token_and_content()
        if err then
            error("could not get target_json")
            return
        end

        minifier.minify_and_put(input_json, target_node)
    end)
end

function M.format_token()
    validate_and_run_operation(function()
        local target_node, json, err = utils.get_nearest_token_and_content()
        if err then
            error("could not get target_json")
            return
        end

        formatter.format_and_put(json, target_node)
    end)
end

function M.escape_file()
    validate_and_run_operation(escaper.escape_file)
end

function M.unescape_file()
    validate_and_run_operation(escaper.unescape_file)
end

function M.escape_selection()
    validate_and_run_operation(function()
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
    end)
end

function M.unescape_selection()
    validate_and_run_operation(function()
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
    end)
end

local function switch_casing(to)
    validate_and_run_operation(function()
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
    end)
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
