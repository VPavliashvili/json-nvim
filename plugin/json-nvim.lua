local json_nvim = require("json-nvim")

local function command(name, callback, options)
    local final_opts = vim.tbl_deep_extend('force', options or {}, { bang = true })
    vim.api.nvim_create_user_command(name, callback, final_opts)
end

command("JsonFileFormat", function()
    vim.cmd("%!jq")
end)

command("JsonFileMinify", function()
    vim.cmd("%!jq -c")
end)

command("JsonSelectionMinify", function()
    local selection = json_nvim.get_visual_selection()
    local replacement = ""

    if vim.loop.os_uname().sysname == "Windows_NT" then
        local fmt_selection = vim.fn.substitute(selection, [[\n]], '', 'g')
        local cmd = string.format('echo %s | jq . -r -c', fmt_selection)
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
end, { range = true })
