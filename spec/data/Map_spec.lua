local Map = require("p4lua.data.Map")
local assert = Map.filterByKeys(assert, { "are", "equals", "is_true", "is_false" }) -- suppress LSP warning

describe("p4lua.data.Map.new", function()

    it("should create an empty array when no arguments are passed", function()
        local map = Map.new()
        assert.are.same(map, {})
    end)

end)

describe("filterByKeys function", function()

    it("should return an empty Map when Map is empty and no keys are provided", function()
        assert.are.same(Map.filterByKeys({}, {}), {})
    end)

    it("should return an empty Map when no keys are provided", function()
        local map = { k = "v" }
        assert.are.same(Map.filterByKeys(map, {}), {})
    end)

    it("should return an empty Map if none of the keys match", function()
        local map = { k = "v" }
        assert.are.same(Map.filterByKeys(map, { "no matching key"}), {})
    end)
    --
    it("should return the Map with matched keys", function()
        local map = { k1 = "v1", k2 = "v2" }
        assert.are.same(Map.filterByKeys(map, { "k1" }), { k1 = "v1" })
    end)

end)
