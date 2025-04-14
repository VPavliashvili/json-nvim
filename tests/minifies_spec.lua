---@diagnostic disable: undefined-field, no-unknown, undefined-global
local minifier = require("json-nvim.minifier")

local original_get_collapsed = package.loaded["json-nvim.jq"]["get_collapsed"]
local eq = assert.are.same

local function mock_jq_minify(returnJson)
    package.loaded["json-nvim.jq"]["get_collapsed"] = function(json)
        return returnJson
    end
end

describe("get_minified_json", function()
    after_each(function()
        package.loaded["json-nvim.jq"]["get_formatted"] = original_get_collapsed
    end)

    it("should return minified json from valid input", function()
        mock_jq_minify([[{"id":2,"name":"Amparo Barber"}]])

        local input = [[{
      "id": 0,
      "name": "Constance Mcmillan"
    }]]
        local expected = { [[{"id":2,"name":"Amparo Barber"}]] }
        local actual = minifier.get_minified_json(input)

        print("Actual result:", vim.inspect(actual))

        eq(expected, actual)
    end)

    it("should raise an error when jq returns nil or empty", function()
        local input = [[{
      "id": 0,
      "name": "Constance Mcmillan"
    }]]

        mock_jq_minify(nil)
        assert.has_error(function()
            minifier.get_minified_json(input)
        end, "result was nil or empty")

        mock_jq_minify("")
        assert.has_error(function()
            minifier.get_minified_json(input)
        end, "result was nil or empty")
    end)
end)
