local function command(name, callback, options)
    local final_opts = vim.tbl_deep_extend('force', options or {}, { bang = true })
    vim.api.nvim_create_user_command(name, callback, final_opts)
end

local function get_visual_selection()
    local s_start = vim.fn.getpos("'<")
    local s_end = vim.fn.getpos("'>")
    local n_lines = math.abs(s_end[2] - s_start[2]) + 1
    local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
    lines[1] = string.sub(lines[1], s_start[3], -1)
    if n_lines == 1 then
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
    else
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
    end
    return table.concat(lines, '\n')
end

local function get_reg(char)
    return vim.api.nvim_exec([[echo getreg(']] .. char .. [[')]], true):gsub("[\n\r]", "")
end

command("SayHi", function()
    print("say hi -> hiiiiiii")
end)

command("JsonFileFormat", function()
    vim.cmd("%!jq")
end)

command("JsonFileMinify", function()
    vim.cmd("%!jq -c")
end)

command("JsonSelectionMinify", function()
    -- local temp_json =  '{"date": "2024-10-01", "payment": 3.97 }'

    -- local reg_a = get_reg('a')
    -- local cmd = string.format("echo '%s' | jq . -c", reg_a)
    -- local output = vim.fn.system(cmd)

    -- vim.api.nvim_command('normal! gv')
    -- local selection = vim.fn.getreg(vim.v.register)
    local selection = get_visual_selection()
    -- print(selection)

    local cmd = string.format("echo '%s' | jq . -c", selection)
    local result = vim.fn.system(cmd)
    print(result)
    local replacement = vim.fn.substitute(result, [[\n]], '', 'g')
    print(replacement)
    -- local replacement = "I AM THE REPLACEMENT"

    -- vim.cmd([[normal! gv"0y]])
    -- local expression = vim.fn.substitute(vim.fn.getreg("0"), [[\n]], '\\n', 'g')
    -- vim.cmd('%s,' .. expression .. ',' .. vim.fn.input("Replacement: "))

    -- local vimc = "'<,'>c"
    -- let expression = substitute(@0, "\<C-J>", '\\n', 'g')
    -- normal!gvy
    -- let expression = @0
    -- echo expression
    -- execute "'<,'>s,".expression.','."baby"
    vim.fn.setreg(vim.v.register, replacement)
    local vimc = [[
        normal!gvx
        normal!"0P
    ]]
    print(vimc)
    vim.cmd(vimc)
    vim.cmd.noh()

    -- vim.fn.setreg(vim.v.register, replacement)
    -- print(replacement)
    -- vim.api.nvim_command('normal! "' .. vim.v.register .. 'p')
end, { range = true })
