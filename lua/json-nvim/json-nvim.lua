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
    local replacement = ""

    if vim.loop.os_uname().sysname == "Windows_NT" then
        local selection_without_newlines = vim.fn.substitute(selection, [[\n]], '', 'g')
        local cmd = string.format('echo %s | jq . -r -c', selection_without_newlines)
        local result = vim.fn.system(cmd)
        replacement = vim.fn.substitute(result, [[\n]], '', 'g')
    else
        local cmd = string.format("echo '%s' | jq . -c", selection)
        local result = vim.fn.system(cmd)
        replacement = vim.fn.substitute(result, [[\n]], '', 'g')
    end

    vim.fn.setreg(vim.v.register, replacement)
    local vimc = [[
        normal!gvx
        normal!"0P
    ]]

    vim.cmd(vimc)
    vim.cmd.noh()
end

function M.format_selection()
    vim.inspect(utils.get_visual_selection())
end

return M
