local jn = require("json_nvim.json_nvim")

local M = {}

function M.FormatFile()
    jn.format_file()
end

function M.MinifyFile()
    jn.minify_file()
end

function M.FormatSelection()
    jn.format_selection()
end

function M.MinifySelection()
    jn.minify_selection()
end

function M.FormatToken()
    jn.format_token()
end

function M.MinifyToken()
    jn.minify_token()
end

function M.UnescapeFile()
    jn.unescape_file()
end

function M.EscapeFile()
    jn.escape_file()
end

function M.EscapeSelection()
    jn.escape_selection()
end

function M.UnescapeSelection()
    jn.unescape_selection()
end

function M.KeysToSnakeCase()
    jn.switch_to_snake_case()
end

function M.KeysToCamelCase()
    jn.switch_to_camel_case()
end

function M.KeysToPascalCase()
    jn.switch_to_pascal_case()
end

return M
