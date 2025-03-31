local trial = require("json-nvim").test_trial

local eq = assert.are.same

describe("json-nvim.test_trial", function()
    it("should be hello world", function()
        eq("hello world", trial())
    end)
end)

