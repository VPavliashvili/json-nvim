local jq = require("json-nvim.jq")
local utils = require("json-nvim.utils")

local M = {}

function M.format_file()
    local content = utils.get_buffer_content_as_string()
    local formatted = jq.get_formatted(content)
    if formatted == nil or formatted == "" then
        error("result was nil or empty")
        return
    end
    local replacement = utils.split(formatted, "\n")

    local root = utils.get_treesitter_root()
    utils.replace_tsnode_text(root, replacement)
end

return M
