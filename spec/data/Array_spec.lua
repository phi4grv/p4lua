local assert = require("luassert")

describe("p4lua.data.Array", function()

    local Array = require("p4lua.data.Array")

    describe("Array.fmap", function()

        local double = function(x) return x * 2 end

        it("returns empty array when input is empty", function()
            local empty = {}
            local actual = Array.fmap(double, empty)
            assert.same({}, actual)
            assert.not_equal(empty, actual)
        end)

        it("applies function to each element", function()
            local arr = { 1, 2, 3 }
            local actual = Array.fmap(double, arr)
            assert.same({ 2, 4, 6 }, actual)
            assert.same({ 1, 2, 3 }, arr)
        end)

        it("supports currying", function()
            local arr = { 1, 2, 3 }
            assert.are.same({ 2, 4, 6 }, Array.fmap(double)(arr))
        end)

    end)

    describe("foldl", function()
        local ff = function(acc, v) return acc - v end

        it("folds from the left", function()
            local actual = Array.foldl(ff, 0, { 1, 2, 3 }) -- ((0 - 1) - 2) - 3 = -6
            assert.equals(-6, actual)
        end)

        it("returns initial accumulator for empty array", function()
            local actual = Array.foldl(ff, 10, {})
            assert.equals(10, actual)
        end)

        it("supports currying", function()
            assert.equals(-6, Array.foldl(ff)(0)({ 1, 2, 3 }))
            assert.equals(-6, Array.foldl(ff)(0, { 1, 2, 3 }))
            assert.equals(-6, Array.foldl(ff, 0)({ 1, 2, 3 }))
        end)
    end)

    describe("foldr", function()
        local ff = function(v, acc) return v - acc end

        it("folds from the right", function()
            local actual = Array.foldr(ff, 0, { 1, 2, 3 }) -- 1 - (2 - (3 - 0)) = 2
            assert.equals(2, actual)
        end)

        it("returns initial accumulator for empty array", function()
            local actual = Array.foldr(ff, 10, {})
            assert.equals(10, actual)
        end)

        it("supports currying", function()
            assert.equals(2, Array.foldr(ff)(0)({ 1, 2, 3 }))
            assert.equals(2, Array.foldr(ff)(0, { 1, 2, 3 }))
            assert.equals(2, Array.foldr(ff, 0)({ 1, 2, 3 }))
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
end)
