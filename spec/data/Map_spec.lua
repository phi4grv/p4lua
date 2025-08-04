local assert = require("luassert")

local Map = require("p4lua.data.Map")

describe("Map.fold", function()

    it("sums all values in the map", function()
        local map = { a = 1, b = 2, c = 3 }

        local sum = Map.fold(function(acc, _, v)
            return acc + v
        end, 0, map)
        assert.is_true(sum == 6)
    end)

    it("accumulates entries into a new table by key and value", function()
        local map = { a = 1, b = 2 }
        local seen = Map.fold(function(acc, k, v)
            acc[k .. v] = true
            return acc
        end, {}, map)

        assert.is_true(seen["a1"])
        assert.is_true(seen["b2"])
    end)

    it("returns the initial value when folding over an empty map", function()
        local result = Map.fold(function(acc, k, v) return acc + 1 end, 0, {})
        assert.equals(0, result)
    end)

    describe("Map.fold (curried)", function()
        local map = { a = 1, b = 2 }

        local function sum(acc, _, v)
            return acc + v
        end

        it("works with full application: fold(f, init, map)", function()
            local result = Map.fold(sum, 0, map)
            assert.equals(3, result)
        end)

        it("works with partial: fold(f, init)(map)", function()
            local result = Map.fold(sum, 0)(map)
            assert.equals(3, result)
        end)

        it("works with partial: fold(f)(init, map)", function()
            local result = Map.fold(sum)(0, map)
            assert.equals(3, result)
        end)

        it("works with full curry: fold(f)(init)(map)", function()
            local result = Map.fold(sum)(0)(map)
            assert.equals(3, result)
        end)
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
