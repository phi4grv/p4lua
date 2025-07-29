local Map = require("p4lua.data.Map")
local assert = Map.filterByKeys(assert, { "are", "equals", "is_true", "is_false" }) -- suppress LSP warning

describe("p4lua.require", function()

    local p4lua = require("p4lua")
    local p4fn = require("p4lua.fn")

    it("loads specified functions from module", function()
        local f1, f2 = p4lua.require("p4lua.fn", { "compose", "compose_table" })
        assert.are.same(f1, p4fn.compose)
        assert.are.same(f2, p4fn.compose_table)
    end)

end)
