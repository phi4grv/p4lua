local assert = require("luassert")

describe("p4lua.require", function()

    local p4lua = require("p4lua")
    local p4fn = require("p4lua.fn")

    it("loads specified functions from module", function()
        local f1, f2 = p4lua.require("p4lua.fn", { "compose", "compose_table" })
        assert.are.same(f1, p4fn.compose)
        assert.are.same(f2, p4fn.compose_table)
    end)

    it("assign nil if function is not found", function()
        local f1, f2, f3 = p4lua.require("p4lua.fn", { "compose", "not_exist", "compose_table" })
        assert.are.same(f1, p4fn.compose)
        assert.is_nil(f2)
        assert.are.same(f3, p4fn.compose_table)
    end)

end)
