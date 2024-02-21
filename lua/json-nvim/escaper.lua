local jq = require("json-nvim.jq")
local utils = require("json-nvim.utils")

local function get_escaped_input(input)
    local compacted = jq.get_collapsed(input)

    local pattern = '([\\"])'
    local replacement = "\\%1"
    local escaped = compacted:gsub(pattern, replacement)
    escaped = '"' .. escaped .. '"'

    return escaped
end

local function get_unescaped_input(input)
    local compacted = jq.get_collapsed(input)
    local raw = jq.get_rawed(compacted)

    return raw
end

local M = {}

function M.escape_file()
    local root = utils.get_treesitter_root()

    local content = utils.get_buffer_content_as_string()
    local escaped = get_escaped_input(content)
    utils.replace_tsnode_text(root, escaped)
end

function M.unescape_file()
    local root = utils.get_treesitter_root()
    local content = utils.get_buffer_content_as_string()

    local is_escaped = content:sub(1, 1) == '"'
    if is_escaped == false then
        return
    end

    local unescaped = get_unescaped_input(content)
    utils.replace_tsnode_text(root, unescaped)

    M.unescape_file()
end

M.get_unescaped = get_unescaped_input
M.get_escaped = get_escaped_input

return M
