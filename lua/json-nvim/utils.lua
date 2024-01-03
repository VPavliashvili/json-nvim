local M = {}

-- most of the functions below
-- are just in case

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
    return table.concat(lines, '\n')
end

function M.get_selection_positions()
    return {
        s_start = vim.fn.getpos("'<"),
        s_end = vim.fn.getpos("'>")
    }
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

function M.format_command_according_os(jq_command, input)
    local cmd = ""
    if vim.fn.has('win32') == 1 then
        cmd = string.format('echo %s | %s', input, jq_command)
    else
        cmd = string.format("echo '%s' | %s", input, jq_command)
    end
    return cmd
end

function M.replace_tsnode_text(node, replacement_text)
    local start_row, start_col, end_row, end_col = node:range()
    vim.api.nvim_buf_set_text(
        vim.api.nvim_get_current_buf(),
        start_row,
        start_col,
        end_row,
        end_col,
        { replacement_text }
    )
end

return M
