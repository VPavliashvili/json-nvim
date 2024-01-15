local jn = require("json-nvim.json-nvim")

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

return M
