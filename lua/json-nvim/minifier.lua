local jq = require("json-nvim.jq")
local utils = require("json-nvim.utils")

local M = {}

--- minifies and returns replacement text for whole file
--- @param input string buffer content as string
--- @return string[] replacement text as array of lines of text
function M.get_minified_json(input)
    local minified = jq.get_collapsed(input)

    if minified == nil or minified == "" then
        error("result was nil or empty")
    end

    return { minified }
end

return M
