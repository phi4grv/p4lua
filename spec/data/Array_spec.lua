local Map = require("p4lua.data.Map")
local assert = Map.filterByKeys(assert, { "are", "equals", "is_true", "is_false" }) -- suppress LSP warning

local Array = require("p4lua.data.Array")

describe("p4lua.data.Array.new", function()

    it("should create an empty array when no arguments are passed", function()
        local arr = Array.new()
        assert.are.same(arr, {})
    end)
    it("should create an empty array when nil is passed", function()
        local arr = Array.new(nil)
        assert.are.same(arr, {})
    end)

    it("should create an array with a single element when one argument is passed", function()
        local arr = Array.new(10)
        assert.are.same(arr, {10})
    end)

    it("should create an array with multiple elements when several arguments are passed", function()
        local arr = Array.new(5, "test", false)
        assert.are.same(arr, {5, "test", false})
    end)

    it("should handle nil values as elements in the array", function()
        local arr = Array.new(1, nil, 3)
        assert.are.same(arr, {1, nil, 3})
    end)

end)

describe("p4lua.data.Array.isEmpty", function()

    it("returns true for empty arrays", function()
        assert.is_true(Array.isEmpty({}))
    end)

    it("returns false for non-empty arrays", function()
        assert.is_false(Array.isEmpty({ "a", "b" }))
    end)

    it("returns true for arrays with nil at index 1", function()
        assert.is_true(Array.isEmpty({ nil, "a", "b" }))
    end)

    it("returns true for non-table inputs", function()
        assert.is_true(Array.isEmpty(nil))
        assert.is_true(Array.isEmpty(123))
        assert.is_true(Array.isEmpty("string"))
    end)

    it("returns false for table with key 1 (array-like)", function()
        local arr = { [1] = "value", k = "v" }
        assert.is_false(Array.isEmpty(arr))
    end)

    it("returns true for numeric keys starting from 2 (missing 1)", function()
        local arr = { [2] = "s2", [3] = "s3" }
        assert.is_true(Array.isEmpty(arr))
    end)

    it("returns true for table with only keys (map-like)", function()
        local arr = { k1 = "s1", k2 = 2 }
        assert.is_true(Array.isEmpty(arr))
    end)

end)

describe("p4lua.data.Array.zipWith", function()

    describe("p4lua.data.Array.zipWith with single parameter functions", function()
        local add1 = function(x) return x + 1 end
        local mul2 = function(x) return x * 2 end
        local square = function(x) return x ^ 2 end

        it("applies functions to corresponding elements", function()
            local fs = { add1, mul2, square }
            local values = { 1, 2, 3 }

            local result = Array.zipWith(fs, values)
            assert.are.same({ 2, 4, 9 }, result)
        end)

        it("returns empty if either list is empty", function()
            local fs = {}
            local values = {1, 2, 3}

            local result = Array.zipWith(fs, values)
            assert.are.same({}, result)

            result = Array.zipWith(values, {})
            assert.are.same({}, result)
        end)

        it("stops at the shorter list length", function()
            local fs = { add1, mul2 }
            local values = { 1, 2, 3, 4 }

            local result = Array.zipWith(fs, values)
            assert.are.same({ 2, 4 }, result)
        end)
    end)

    describe("p4lua.data.Array.zipWith with two parameter functions", function()
        local add = function(a, b) return a + b end
        local mul = function(a, b) return a * b end
        local sub = function(a, b) return a - b end

        it("applies each function to corresponding elements from two arrays", function()
            local fs = { add, mul, sub }
            local a1 = { 1, 2, 3 }
            local a2 = { 4, 5, 6 }

            local result = Array.zipWith(fs, a1, a2)
            assert.are.same({ 5, 10, -3 }, result)
        end)

        it("returns empty if any array is empty", function()
            local fs = { add }
            local a1 = {}
            local a2 = { 1 }

            local result = Array.zipWith(fs, a1, a2)
            assert.are.same({}, result)

            result = Array.zipWith(fs, {1}, {})
            assert.are.same({}, result)
        end)

        it("stops at the shortest array length", function()
            local fs = { add, mul }
            local a1 = { 1, 2, 3 }
            local a2 = { 4, 5 }

            local result = Array.zipWith(fs, a1, a2)
            assert.are.same({ 5, 10 }, result)
        end)
    end)

end)
