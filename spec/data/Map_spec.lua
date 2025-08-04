local assert = require("luassert")

local Map = require("p4lua.data.Map")

describe("p4lua.data.Map.new", function()

    it("should create an empty array when no arguments are passed", function()
        local map = Map.new()
        assert.are.same(map, {})
    end)

end)

describe("Map.empty", function()

    it("should return an empty map (table) with no keys", function()
        local m = Map.empty()
        assert.is_table(m)
        assert.is_nil(next(m))  -- check empty table
    end)

    it("should always return the same table (singleton)", function()
        local m1 = Map.empty()
        local m2 = Map.empty()
        assert.is_true(m1 == m2)
    end)

    it("should be immutable (error on new index)", function()
        local m = Map.empty()
        assert.error_matches(function()
            m.a = 1
        end, "readonly")
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

describe("Map.values", function()

    it("returns an empty array when the table is empty", function()
        local vs = Map.values({})
        assert.are.same({}, vs)
    end)

    it("returns all values from a map", function()
        local vs = Map.values({ a = 10, b = 20, c = 30 })

        table.sort(vs) -- to ignore order
        assert.are.same({10, 20, 30}, vs)
    end)

    it("returns all non-nil values from a map", function()
        local vs = Map.values({ a = 1, b = nil, c = 2 })

        table.sort(vs) -- to ignore order
        assert.are.same({1, 2}, vs)
    end)

    it("returns an empty array when all values are nil", function()
        local vs = Map.values({ a = nil, b = nil })

        assert.are.same({}, vs)
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
