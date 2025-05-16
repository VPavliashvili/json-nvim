-- Add the plugin source to the Lua package path
package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"

-- Require the module
local json_nvim = require("json_nvim")
local update_golden = arg[1] == "--update"
-- Simple file helper functions
local function read_file(path)
    local f = assert(io.open(path, "r"))
    local content = f:read("*a")
    f:close()
    return content
end

local function write_file(path, data)
    local f = assert(io.open(path, "w"))
    f:write(data)
    f:close()
end

-- Run a single test
local function run_test(name, input_file, golden_file, transform_fn)
    local input = read_file(input_file)
    local expected = read_file(golden_file)
    local append_warning = "WARN: a newline was appended to output to match POSIX golden."
    -- Use your plugin's transformation (e.g., minifier)
    -- print(input)
    local actual = transform_fn(input)
    if not actual:match("\n$") then
        actual = actual .. "\n"
    end
    if actual == expected then
        print("✅ " .. name .. ": PASS")
    else
        if update_golden then
            write_file(golden_file, actual)
            print("🔁 " .. name .. ": Updated golden file.")
            return
        end
        if expected ~= actual then
            print("Mismatch:")
            print("Expected: [" .. vim.inspect(expected) .. "]")
            print("Actual:   [" .. vim.inspect(actual) .. "]")
        end
        print("❌ " .. name .. ": FAIL")
        -- Optional: write diff to disk for inspection
        write_file("tests/" .. name .. ".actual", actual)
        write_file("tests/" .. name .. ".expected", expected)
    end
end

-- Register your tests here
local tests = {
    {
        name = "Minify File",
        input = "tests/inputs/minify_file.json",
        golden = "tests/golden/minify_file.json.golden",
        fn = require("json_nvim.minifier").minify_string,
    },
    {
        name = "Format File",
        input = "tests/inputs/format_file.json",
        golden = "tests/golden/format_file.json.golden",
        fn = require("json_nvim.formatter").format_string,
    },
    {
        name = "Escape File",
        input = "tests/inputs/escape_file.json",
        golden = "tests/golden/escape_file.json.golden",
        fn = require("json_nvim.escaper").escape_string,
    },
    {
        name = "Unescape File",
        input = "tests/inputs/unescape_file.txt",
        golden = "tests/golden/unescape_file.json.golden",
        fn = require("json_nvim.escaper").unescape_string,
    },
}

-- Run them all
for _, test in ipairs(tests) do
    run_test(test.name, test.input, test.golden, test.fn)
end
