local M = {}

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
        result = vim.fn.substitute(input, [[\n]], "", "g")
    else
        cmd = string.format("echo '%s' | jq -c .", input)
        result = vim.fn.system(cmd)
        result = input:gsub("[\n\r]", "")
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
		result = vim.fn.substitute(input, [[\n]], "", "g")
	else
		cmd = string.format("echo '%s' | jq -r .", input)
		result = vim.fn.system(cmd)
		result = input:gsub("[\n\r]", "")
	end

	return result
end

---takes any string and returns true if its valid json
---@param input string
---@return boolean
function M.is_valid(input)
    local command
    if vim.fn.has("win32") == 1 then
		local one_line = vim.fn.substitute(input, [[\n]], "", "g")
        command = string.format("echo %s | jq -e .", one_line)
    else
        command = string.format("echo '%s' | jq -e .", input)
    end

	local handle = io.popen(command)
	if handle == nil then
		return false
	end
	_ = handle:read("*a")
	local _, _, code = handle:close()

	return code == 0
end

return M
