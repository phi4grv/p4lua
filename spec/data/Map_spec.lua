local assert = require("luassert")
local Maybe = require("p4lua.data.Maybe")
local Just = Maybe.Just
local Nothing = Maybe.Nothing

describe("p4lua.data.Map", function()

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

    describe("Map.insert", function()

        it("inserts a new key-value pair into an empty map", function()
            local m0 = {}
            local m1 = Map.insert("a", 1, m0)
            assert.is_nil(m0["a"])
            assert.equals(1, m1["a"])
            assert.are.same({}, m0)
        end)

        it("inserts a new key-value pair into a non-empty map", function()
            local m0 = { b = 2 }
            local m1 = Map.insert("a", 1, m0)

            assert.equals(2, m0["b"])
            assert.is_nil(m0["a"])
            assert.equals(1, m1["a"])
            assert.equals(2, m1["b"])
            assert.are.same({ b = 2 }, m0)
        end)

        it("overwrites an existing key with a new value", function()
            local m0 = { a = 1, b = 2 }
            local m1 = Map.insert("a", 3, m0)
            assert.equals(1, m0["a"])
            assert.equals(3, m1["a"])
            assert.equals(2, m1["b"])
            assert.are.same({ a = 1, b = 2 }, m0)
        end)

        it("does not mutate the original map", function()
            local m0 = { a = 1 }
            local m1 = Map.insert("a", 2, m0)
            assert.equals(1, m0["a"])
            assert.equals(2, m1["a"])
            assert.are.same({ a = 1 }, m0)
        end)

        it("supports currying: Map.insert(k, v)(map)", function()
            local m0 = { a = 1 }
            local insertA = Map.insert("a", 2)
            local m1 = insertA(m0)
            assert.equals(2, m1["a"])
            assert.are.same({ a = 1 }, m0)
        end)

        it("supports currying: Map.insert(k)(v)(map)", function()
            local m0 = { a = 1 }
            local insertA = Map.insert("a")
            local insertA2 = insertA(2)
            local m1 = insertA2(m0)
            assert.equals(2, m1["a"])
            assert.are.same({ a = 1 }, m0)
        end)

        it("supports currying: Map.insert(k)(v, map)", function()
            local m0 = { a = 1 }
            local insertA = Map.insert("a")
            local m1 = insertA(2, m0)
            assert.equals(2, m1["a"])
            assert.are.same({ a = 1 }, m0)
        end)
    end)

    describe("Map.lookup", function()

        it("returns Maybe.Just(value) if key exists", function()
            local actual = Map.lookup("a", { a = 42 })
            assert.is_true(Maybe.equals(Maybe.Just(42), actual))
        end)

        it("returns Maybe.Nothing() if key does not exist", function()
            local actual = Map.lookup("missing", { })
            assert.equals(Maybe.Nothing, actual)
        end)

        it("supports currying", function()
            local actual = Map.lookup("a")({ a = 99})
            assert.is_true(Maybe.equals(Maybe.Just(99), actual))
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

        it("returns Maybe.Just values for given keys in order", function()
            local m = { a = 1, b = 2, c = 3 }
            local ks = { "b", "c" }

            local actual = Map.valuesByKeys(m, ks)
            assert.same({ Just(2), Just(3) }, actual)
        end)

        it("return Maybe.Nothing if keys not exists in the map", function()
            local actual = Map.valuesByKeys({}, { "k1", "k2" })
            assert.same({ Nothing, Nothing }, actual)
        end)

        it("return Maybe.Nothing if keys not exists in the map", function()
            local m = { a = 1, b = 2 }
            local ks = { "b", "not exists", "a" }

            local actual = Map.valuesByKeys(m, ks)
            assert.same({ Just(2), Nothing, Just(1) }, actual)
        end)

        it("returns empty array if keys list is empty", function()
            local m = { a = 1 }
            local keys = {}

            local vals = Map.valuesByKeys(m, keys)
            assert.same({}, vals)
        end)

    end)
end)
