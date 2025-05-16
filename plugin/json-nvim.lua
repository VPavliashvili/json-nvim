local json_nvim = require("json_nvim")

local function command(name, callback, options)
    local final_opts = vim.tbl_deep_extend("force", options or {}, { bang = true })
    vim.api.nvim_create_user_command(name, callback, final_opts)
end

command("JsonFormatFile", function()
    json_nvim.FormatFile()
end)

command("JsonMinifyFile", function()
    json_nvim.MinifyFile()
end)

command("JsonFormatSelection", function()
    json_nvim.FormatSelection()
end, { range = true })

command("JsonMinifySelection", function()
    json_nvim.MinifySelection()
end, { range = true })

command("JsonFormatNode", function()
    json_nvim.FormatToken()
end)

command("JsonMinifyNode", function()
    json_nvim.MinifyToken()
end)

command("JsonEscapeFile", function()
    json_nvim.EscapeFile()
end)

command("JsonUnescapeFile", function()
    json_nvim.UnescapeFile()
end)

command("JsonEscapeSelection", function()
    json_nvim.EscapeSelection()
end, { range = true })

command("JsonUnescapeSelection", function()
    json_nvim.UnescapeSelection()
end, { range = true })

command("JsonKeysToCamelCase", function()
    json_nvim.KeysToCamelCase()
end)
command("JsonKeysToPascalCase", function()
    json_nvim.KeysToPascalCase()
end)
command("JsonKeysToSnakeCase", function()
    json_nvim.KeysToSnakeCase()
end)
