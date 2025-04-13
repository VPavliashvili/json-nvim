---@diagnostic disable: undefined-field, param-type-mismatch, no-unknown, undefined-global

local formatter = require("json-nvim.formatter")

local original_isvalid = package.loaded["json-nvim.jq"]["is_valid"]
local original_get_formatted = package.loaded["json-nvim.jq"]["get_formatted"]
local eq = assert.are.same

local function mock_jq_format(returnJson)
    package.loaded["json-nvim.jq"]["get_formatted"] = function(json)
        return returnJson
    end
end

local function mock_jq_isvalid(returnBool)
    package.loaded["json-nvim.jq"]["is_valid"] = function(json)
        return returnBool
    end
end

describe("get_formatted_token", function()
    after_each(function()
        package.loaded["json-nvim.jq"]["is_valid"] = original_isvalid
        package.loaded["json-nvim.jq"]["get_formatted"] = original_get_formatted
    end)

    local function create_mock_node(start_col, prev_sibling_type, target_node_type, parent_type)
        return {
            start = function()
                return 0, start_col
            end,
            prev_named_sibling = function()
                if prev_sibling_type then
                    return {
                        type = function()
                            return prev_sibling_type
                        end,
                    }
                else
                    return nil
                end
            end,
            type = function()
                return target_node_type
            end,
            parent = function()
                return {
                    start = function()
                        return 0, start_col
                    end,
                    type = function()
                        return parent_type
                    end,
                }
            end,
        }
    end

    it(
        "should return correctly indented and formatted json when selecting separate json child of root/document",
        function()
            mock_jq_isvalid(true)
            mock_jq_format([[
{
  "id": 2,
  "name": "Amparo Barber"
}]])

            local input = [[{"id":2,"name":"Amparo Barber"}]] -- it does not matter if minified or not
            local expected = {
                "{",
                '  "id": 2,',
                '  "name": "Amparo Barber"',
                "}",
            }

            local target_node = create_mock_node(0, nil, "array", "document")

            local actual = formatter.get_formatted_token(input, target_node)

            print("Actual result type:", type(actual))
            print("Actual result:", vim.inspect(actual))

            eq(expected, actual)
        end
    )

    it("should return correctly indented and formatted json when root level object", function()
        mock_jq_isvalid(true)
        mock_jq_format([[
{
  "id": 2,
  "name": "Amparo Barber"
}]])

        local input = [[{"id":2,"name":"Amparo Barber"}]] -- it does not matter if minified or not
        local expected = {
            "  {",
            '    "id": 2,',
            '    "name": "Amparo Barber"',
            "  }",
        }

        local target_node = create_mock_node(0, nil, "pair", "pair")

        local actual = formatter.get_formatted_token(input, target_node)

        print("Actual result type:", type(actual))
        print("Actual result:", vim.inspect(actual))

        eq(expected, actual)
    end)

    it("should return correctly indented and formatted json when has parent", function()
        mock_jq_isvalid(true)
        mock_jq_format([[
{
  "id": 2,
  "name": "Amparo Barber"
}]])
        local input = [[{"id":2,"name":"Amparo Barber"}]]
        local expected = {
            "  {",
            '    "id": 2,',
            '    "name": "Amparo Barber"',
            "  }",
        }
        -- 2 means here it has one parent and virtual json is formatted
        local target_node = create_mock_node(2, "string", "array", "pair")

        local actual = formatter.get_formatted_token(input, target_node)

        print("Actual result type:", type(actual))
        print("Actual result:", vim.inspect(actual))

        eq(expected, actual)
    end)

    it("should raise error when input is invalid json", function()
        mock_jq_isvalid(false)
        assert.has_error(function()
            formatter.get_formatted_token("invalid", nil)
        end, "provided input was not a valid json")
    end)

    it("should raise error when jq returns invalid output", function()
        local input = [[{"id":2,"name":"Amparo Barber"}]]

        mock_jq_isvalid(true)
        mock_jq_format(nil)
        assert.has_error(function()
            formatter.get_formatted_token(input, nil)
        end, "result was nil or empty")

        mock_jq_format("")
        assert.has_error(function()
            formatter.get_formatted_token(input, nil)
        end, "result was nil or empty")
    end)
end)

describe("get_formatted_buffer", function()
    after_each(function()
        package.loaded["json-nvim.jq"]["is_valid"] = original_isvalid
        package.loaded["json-nvim.jq"]["get_formatted"] = original_get_formatted
    end)

    it("should return correctly formatted json from from valid minified json", function()
        mock_jq_isvalid(true)
        mock_jq_format([[
{
  "id": 2,
  "name": "Amparo Barber"
}]])
        local input = [[{"id":2,"name":"Amparo Barber"}]]
        local expected = {
            "{",
            '  "id": 2,',
            '  "name": "Amparo Barber"',
            "}",
        }
        local actual = formatter.get_formatted_buffer(input)

        print("Actual result type:", type(actual))
        print("Actual result:", vim.inspect(actual))

        eq(expected, actual)
    end)

    it("should return correctly formatted json from valid unformatted json", function()
        mock_jq_isvalid(true)
        mock_jq_format([[
{
  "id": 2,
  "name": "Amparo Barber"
}]])
        local input = [[
                    {
          "id": 2,
          "name": "Amparo Barber"
                }
        ]]
        local expected = {
            "{",
            '  "id": 2,',
            '  "name": "Amparo Barber"',
            "}",
        }

        local actual = formatter.get_formatted_buffer(input)

        print("Actual result type:", type(actual))
        print("Actual result:", vim.inspect(actual))

        eq(expected, actual)
    end)

    it("should return correctly formatted json from valid already formatted json", function()
        mock_jq_isvalid(true)
        mock_jq_format([[
{
  "id": 2,
  "name": "Amparo Barber"
}]])
        local input = [[
        {
          "id": 2,
          "name": "Amparo Barber"
        }
        ]]
        local expected = {
            "{",
            '  "id": 2,',
            '  "name": "Amparo Barber"',
            "}",
        }

        local actual = formatter.get_formatted_buffer(input)

        print("Actual result type:", type(actual))
        print("Actual result:", vim.inspect(actual))

        eq(expected, actual)
    end)

    it("should raise error when input is invalid json", function()
        local input = "obvious invalid json"
        mock_jq_isvalid(false)
        assert.has_error(function()
            formatter.get_formatted_buffer(input)
        end, "provided input was not a valid json")
    end)

    it("should raise error when jq returns invalid output", function()
        local input = [[{"id":2,"name":"Amparo Barber"}]]

        mock_jq_isvalid(true)
        mock_jq_format(nil)
        assert.has_error(function()
            formatter.get_formatted_buffer(input)
        end, "result was nil or empty")

        mock_jq_format("")
        assert.has_error(function()
            formatter.get_formatted_buffer(input)
        end, "result was nil or empty")
    end)
end)
