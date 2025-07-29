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

describe("Map.valuesByKeys function", function()

    it("returns values for given keys in order", function()
        local m = { a = 1, b = 2, c = 3 }
        local keys = { "b", "c" }

        local vals = Map.valuesByKeys(m, keys)
        assert.are.same({ 2, 3 }, vals)
    end)

    it("return nil if keys not exists in the map", function()
        local m = { a = 1, b = 2 }
        local keys = { "b", "not exists", "a" }

        local vals = Map.valuesByKeys(m, keys)
        assert.are.same({ 2, nil, 1 }, vals)
    end)

    it("returns empty array if keys list is empty", function()
        local m = { a = 1 }
        local keys = {}

        local vals = Map.valuesByKeys(m, keys)
        assert.are.same({}, vals)
    end)

    it("returns empty array if map is empty", function()
        local m = {}
        local keys = { "a", "b" }

        local vals = Map.valuesByKeys(m, keys)
        assert.are.same({}, vals)
    end)
end)
