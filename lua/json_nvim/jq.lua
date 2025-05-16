local utils = require("json_nvim.utils")

local temp_file_path, os_file_sep = utils.get_os_temp_file_path()

temp_file_path = temp_file_path .. os_file_sep .. "json_nvim_"

--write data to a temporary file in plugin root
---@param arg { input: string, operation: string }
---@return string
local function write_to_temp(arg)
    if type(arg.input) ~= "string" then
        error("no input to write_to_temp()")
    end
    local tmp_file = temp_file_path .. os.time() .. (arg.operation and ("-" .. arg.operation .. ".json") or ".json")
    local f = io.open(tmp_file, "w")
    f:write(arg.input)
    f:close()
    return tmp_file
end

local M = {}

---get all keys from json text
---this function is used for case_switching feature
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
    local tmp_file = write_to_temp({ input = input, operation = "get_formatted" })
    if vim.fn.has("win32") == 1 then
        cmd = "jq . " .. tmp_file
        result = vim.fn.system(cmd)
    else
        cmd = "jq . -e " .. tmp_file
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
    local tmp_file = write_to_temp({ input = input, operation = "get_collapsed" })
    if vim.fn.has("win32") == 1 then
        cmd = "jq -c . " .. tmp_file
        result = vim.fn.system(cmd)
        result = vim.fn.substitute(result, [[\n]], "", "g")
    else
        cmd = "jq -c . " .. tmp_file
        result = vim.fn.system(cmd)
        result = result:gsub("\r?\n", "")
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
    local tmp_file = write_to_temp({ input = input, operation = "get_rawed" })
    if vim.fn.has("win32") == 1 then
        cmd = "jq -r . " .. tmp_file
        result = vim.fn.system(cmd)
        result = vim.fn.substitute(result, [[\n]], "", "g")
    else
        cmd = "jq . -r " .. tmp_file
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
    local tmp_file = write_to_temp({ input = input, operation = "is_valid" })
    if vim.fn.has("win32") == 1 then
        cmd = "jq . -e " .. tmp_file
        result = vim.fn.system(cmd)
        local exit_status = vim.v.shell_error

        result = vim.fn.substitute(result, [[\n]], "", "g")

        return exit_status == 0
    else
        cmd = "jq . -e " .. tmp_file .. "</dev/null"
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
