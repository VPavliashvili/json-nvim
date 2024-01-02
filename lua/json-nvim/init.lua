local jn = require("json-nvim.json-nvim")

local M = {}

function M.FormatFile()
    jn.format_file()
end

function M.MinifyFile()
    jn.minify_file()
end

function M.FormatSelection()
    -- local temp = u.minify_current_ts_json_object_or_array()
    -- return temp
end

function M.MinifySelection()
    jn.minify_selection()
end

return M
