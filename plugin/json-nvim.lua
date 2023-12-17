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

    local cmd = string.format("echo '%s' | jq . -c", selection)
    local result = vim.fn.system(cmd)
    local replacement = vim.fn.substitute(result, [[\n]], '', 'g')

    vim.fn.setreg(vim.v.register, replacement)
    local vimc = [[
        normal!gvx
        normal!"0P
    ]]

    vim.cmd(vimc)
    vim.cmd.noh()

end, { range = true })
