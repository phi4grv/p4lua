local assert = require("luassert")
local p4fn = require("p4lua.fn")

describe ("p4lua", function()

    local p4lua = require("p4lua")

    describe("p4lua.require", function()

        it("loads specified functions from module", function()
            local f1, f2 = p4lua.require("p4lua.fn", { "compose", "composeArray" })
            assert.is_not_nil(f1)
            assert.equal(f1, p4fn.compose)
            assert.is_not_nil(f2)
            assert.equal(f2, p4fn.composeArray)
        end)

        it("assign nil if function is not found", function()
            local f1, f2, f3 = p4lua.require("p4lua.fn", { "compose", "not_exist", "composeArray" })
            assert.is_not_nil(f1)
            assert.equal(f1, p4fn.compose)
            assert.is_nil(f2)
            assert.is_not_nil(f3)
            assert.equal(f3, p4fn.composeArray)
        end)

    end)
end)
