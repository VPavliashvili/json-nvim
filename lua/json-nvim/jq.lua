local utils = require("json-nvim.utils")

local temp_file_path = utils.get_plugin_root() .. "temp.json"

local function write_to_temp(input)
    local f = io.open(temp_file_path, "w")
    f:write(input)
    f:close()
end

local M = {}

---get all keys from json text
---this function is used for scase_switching feature
---@param json string
---@return string[]
function M.get_keys(json)
    local cmd = string.format("echo '%s' | jq 'keys_unsorted'", json)
    local keys = vim.fn.system(cmd)

    return keys
end

---takes valid json string and returns its formatted form
---@param input string
---@return string
function M.get_formatted(input)
    local result
    local cmd
    if vim.fn.has("win32") == 1 then
        write_to_temp(input)
        cmd = "jq . " .. temp_file_path
        result = vim.fn.system(cmd)
    else
        cmd = string.format("echo '%s' | jq .", input)
        result = vim.fn.system(cmd)
    end

    return result
end

---takes valid json string and returns its collapsed form
---@param input string
---@return string
function M.get_collapsed(input)
    local result
    local cmd
    if vim.fn.has("win32") == 1 then
        write_to_temp(input)
        cmd = "jq -c . " .. temp_file_path
        result = vim.fn.system(cmd)
        result = vim.fn.substitute(result, [[\n]], "", "g")
    else
        cmd = string.format("echo '%s' | jq -c .", input)
        result = vim.fn.system(cmd)
        result = result:gsub("[\n\r]", "")
    end

    return result
end

---takes valid json string and returns its raw form
---i.e. without escape characters, extra quotations and such
---@param input string
---@return string
function M.get_rawed(input)
    local result
    local cmd
    if vim.fn.has("win32") == 1 then
        write_to_temp(input)
        cmd = "jq -r . " .. temp_file_path
        result = vim.fn.system(cmd)
        result = vim.fn.substitute(result, [[\n]], "", "g")
    else
        cmd = string.format("echo '%s' | jq -r .", input)
        result = vim.fn.system(cmd)
        result = result:gsub("[\n\r]", "")
    end

    return result
end

---takes any string and returns true if its valid json
---@param input string
---@return boolean
function M.is_valid(input)
    local cmd
    local result
    if vim.fn.has("win32") == 1 then
        write_to_temp(input)
        cmd = "jq . -e " .. temp_file_path
        result = vim.fn.system(cmd)
        local exit_status = vim.v.shell_error

        result = vim.fn.substitute(result, [[\n]], "", "g")

        return exit_status == 0
    else
        cmd = string.format("echo '%s' | jq -e .", input)
        result = vim.fn.system(cmd)

        local exit_status = vim.v.shell_error

        return exit_status == 0
    end
end

---@param target_case string
---@param from_case string
---@param target_json string
---@param jq_modules string
---@return string
function M.switch_key_casing_to(target_case, from_case, target_json, jq_modules)
    local cmd = string.format("echo '%s' | jq -L %s 'map_keys(%s|%s)'", target_json, jq_modules, from_case, target_case)
    local result = vim.fn.system(cmd)
    return result
end

return M
