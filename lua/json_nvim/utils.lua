local M = {}

-- some of the functions below
-- are just in case
---@return string
local function get_os_file_separator()
    local file_separator
    local init_path = debug.getinfo(1).source

    if not init_path:find("\\") then
        file_separator = "/"
    end
    return file_separator
end

function M.get_plugin_root()
    local file_separator = get_os_file_separator()
    local target_index = 0
    local separator_encountered = 0
    for i = #init_path, 1, -1 do
        if init_path:sub(i, i) == file_separator then
            separator_encountered = separator_encountered + 1
            if separator_encountered == 3 then
                target_index = i
                break
            end
        end
    end

    local result = init_path:sub(2, target_index)
    return result
end

function M.get_jq_modules_directory()
    local result = M.get_plugin_root()
    result = result .. "jq_modules"
    return result
end

-- Returns the OS TMP DIR and path_separator
---@return string?
---@return string
function M.get_os_temp_file_path()
    local tmp_dir
    if vim.fn.has("win32") == 1 then
        tmp_dir = os.getenv("TEMP")
    else
        tmp_dir = os.getenv("TMPDIR")
    end
    if not tmp_dir then
        error("json_nvim uses temp files. Either $TEMP (Windows) or $TMPDIR (Unix) must be defined")
    end

    return tmp_dir, get_os_file_separator()
end

---takes json string as keys and returns which casing is used
---@param input string
---@return string
function M.get_casing(input)
    local keys = M.split(input, "\n\r")
    table.remove(keys, 1)
    table.remove(keys, #keys)
    for i, key in pairs(keys) do
        local k = key:gsub("%s+", "")
        k = k:gsub('"', "")
        keys[i] = k
    end

    table.sort(keys, function(a, b)
        return #a > #b
    end)
    if keys == nil then
        error("sorting fked up")
    end
    local largest_key = keys[1]

    local splits = M.split(largest_key, "_")

    if #splits > 1 then
        return "snake"
    end

    local word = splits[1]
    local first = word:sub(1, 1)
    if first == string.upper(first) then
        return "pascal"
    end

    return "camel"
end

function M.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function M.get_visual_selection()
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
    return table.concat(lines, "\n")
end

function M.get_selection_positions()
    return {
        s_start = vim.fn.getpos("'<"),
        s_end = vim.fn.getpos("'>"),
    }
end

function M.get_treesitter_root()
    local cur_node = vim.treesitter.get_node({})
    if cur_node == nil then
        error("can't get current node of treesitter")
    end
    local root = cur_node:tree():root():child(0)

    if root == nil then
        error("could not get root")
    end

    return root
end

function M.get_buffer_content_as_string()
    local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
    return table.concat(content, "\n")
end

function M.get_buffer_content_as_string_up_to_cursor_pos()
    local line, _ = vim.api.nvim_win_get_cursor(0)
    local content = vim.api.nvim_buf_get_lines(0, 0, line[1], false)
    return table.concat(content, "\n")
end

-- print content of all children of treesitter node
function M.get_tsnode_children_content(tsnode)
    local count = tsnode:child_count()
    local r = {}
    for i = 0, count - 1 do
        local child = tsnode:child(i)
        local buf_id = vim.api.nvim_get_current_buf()
        local content = vim.treesitter.get_node_text(child, buf_id)
        if content == nil then
            content = "child on index " .. i .. " was nil"
        end
        table.insert(r, content)
    end
    return r
end

-- gets the nearest array or object token to cursor
-- returns json content of that token
function M.get_nearest_token_and_content()
    local cur_node = vim.treesitter.get_node({})
    if cur_node == nil then
        -- token, content, is_error
        return nil, "", true
    end

    local target = cur_node
    while true do
        if target:type() == "array" or target:type() == "object" then
            break
        end
        target = target:parent()
    end

    local buf_id = vim.api.nvim_get_current_buf()
    local content = vim.treesitter.get_node_text(target, buf_id)

    -- token, content, is_error
    return target, content, false
end

function M.replace_tsnode_text(node, replacement)
    if type(replacement) == "table" then
        local start_row, start_col, end_row, end_col = node:range()
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_text(buf, start_row, start_col, end_row, end_col, replacement)
    else
        local start_row, start_col, end_row, end_col = node:range()
        vim.api.nvim_buf_set_text(
            vim.api.nvim_get_current_buf(),
            start_row,
            start_col,
            end_row,
            end_col,
            { replacement }
        )
    end
end

return M
