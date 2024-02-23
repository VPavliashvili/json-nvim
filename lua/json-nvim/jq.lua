local M = {}

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
        local one_line = vim.fn.substitute(input, [[\n]], "", "g")
        cmd = string.format("echo %s | jq .", one_line)
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
        local one_line = vim.fn.substitute(input, [[\n]], "", "g")
        cmd = string.format("echo %s | jq -c .", one_line)
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
        local one_line = vim.fn.substitute(input, [[\n]], "", "g")
        cmd = string.format("echo %s | jq -r .", one_line)
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
    local found_error
    local cmd
    local result
    if vim.fn.has("win32") == 1 then
        local one_line = vim.fn.substitute(input, [[\n]], "", "g")
        cmd = string.format("echo %s | jq . -e", one_line)
        result = vim.fn.system(cmd)
        result = vim.fn.substitute(result, [[\n]], "", "g")

        found_error = result:find("jq . %-e") or result:find("error")
    else
        cmd = string.format("echo '%s' | jq -e .", input)
        result = vim.fn.system(cmd)

        found_error = result:find("error")
    end

    return found_error == nil or found_error == 0
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
