local assert = require("luassert")
local Maybe = require("p4lua.data.Maybe")
local Just = Maybe.Just
local Nothing = Maybe.Nothing

describe("p4lua.data.Array", function()

    local Array = require("p4lua.data.Array")

    describe("Array.append", function()

        local cases = {
            { { 1, 2, 3 }, { 4, 5 }, { 1, 2, 3, 4, 5 } },
            { {}, { 1, 2, 3 }, { 1, 2, 3 } },
            { { 1, 2, 3 }, {}, { 1, 2, 3 } },
            { {}, {}, {} },
            { { 1, "a" }, { true, { } }, { 1, "a", true, { } } },
            { { 1, nil, 3 }, { 4, 5 }, { 1, 4, 5 } },
            { { 1, 2 }, { nil, 4, 5 }, { 1, 2 } },
            { { 1, nil, 3 }, { nil, 4, nil }, { 1 } },
        }

        for i, case in ipairs(cases) do
            it("case #" .. i, function()
                local arr1, arr2, expected = table.unpack(case)
                ---@cast arr1 table
                local arr1Copy = { table.unpack(arr1) }
                ---@cast arr2 table
                local arr2Copy = { table.unpack(arr2) }

                local result = Array.append(arr1, arr2)

                assert.same(expected, result)
                assert.not_equal(arr1, result)
                assert.same(arr1Copy, arr1)
                assert.not_equal(arr2, result)
                assert.same(arr2Copy, arr2)
            end)
        end

        it("supports curry", function()
            assert.same({ 1, 2 }, Array.append({ 1 })({ 2 }))
        end)

    end)

    describe("Array.at", function()

        it("returns Just(value) for valid index", function()
            local arr = {"a", "b", "c"}
            assert.same(Just("a"), Array.at(1, arr))
            assert.same(Just("c"), Array.at(3, arr))
        end)

        it("returns Nothing for index out of bounds", function()
            local arr = {"a", "b", "c"}
            assert.same(Nothing, Array.at(0, arr))
            assert.same(Nothing, Array.at(4, arr))
            assert.same(Nothing, Array.at(-1, arr))
        end)

        it("supports curry", function()
            local arr = { "v" }

            assert.same(Just("v"), Array.at(1)(arr))
            assert.same(Nothing, Array.at(2)(arr))
        end)
    end)

    describe("Array.cons", function()

        it("works on empty array", function()
            local arr = {}
            local actual = Array.cons(1, arr)
            assert.same({ 1 }, actual)
            assert.same({}, arr)
        end)

        it("returns a new array with the element prepended", function()
            local arr = { 2, 3, 4 }
            local actual = Array.cons(1, arr)
            assert.same({ 1, 2, 3, 4 }, actual)
            assert.same({ 2, 3, 4 }, arr)
        end)

        it("supports curry", function()
            local arr = { 2, 3 }
            local actual = Array.cons(1)(arr)

            assert.same({ 1, 2, 3 }, actual)
            assert.same({ 2, 3 }, arr)
        end)

    end)

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

    describe("Array.fromTable", function()

        local cases = {
            { { 1, 2, 3 }, { 1, 2, 3 } },
            { { 1, 2, nil, 3 }, { 1, 2 } },
            { { nil, 2, 3 }, {} },
            { {}, {} },
            { { 1, "a", true, {}, nil, "after nil" }, { 1, "a", true, {} } },
        }

        for i, case in ipairs(cases) do
            it("case #" .. i, function()
                local input, expected = table.unpack(case)
                ---@cast input table
                local inputCopy = { table.unpack(input) }

                local actual = Array.fromTable(input)

                assert.same(expected, actual)
                assert.not_equal(input, actual)
                assert.same(input, inputCopy)
            end)
        end

    end)

    describe("Array.fromTableWithLength", function()

        local cases = {
            { { 1, 2, 3 }, { 1, 2, 3 }, 3 },
            { { 1, 2, nil, 3 }, { 1, 2 }, 2 },
            { { nil, 2, 3 }, {}, 0 },
            { {}, {}, 0 },
            { { 1, "a", true, {}, nil, "after nil" }, { 1, "a", true, {} }, 4 },
        }

        for i, case in ipairs(cases) do
            it("case #" .. i, function()
                local input, expectedArr, expectedLen = table.unpack(case)
                ---@cast input table
                local inputCopy = { table.unpack(input) }

                local actualArr, actualLen = Array.fromTableWithLength(input)

                assert.same(expectedArr, actualArr)
                assert.equal(expectedLen, actualLen)
                assert.not_equal(input, actualArr)
                assert.same(input, inputCopy)
            end)
        end

    end)

    describe("Array.fromVargs", function()
        local cases = {
            { {}, {} },
            { { 1, 2, 3 }, { 1, 2, 3 } },
            { { 1, 2, nil, 3 }, { 1, 2 } },
            { { nil, 2, 3 }, {} },
            { { 1, "a", true, {}, nil, "after nil" }, { 1, "a", true, {} } },
        }

        for i, case in ipairs(cases) do
            it("case #" .. i, function()
                local input, expected = table.unpack(case)
                local actual = Array.fromVargs(table.unpack(input))
                assert.same(expected, actual)
            end)
        end
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

    describe("Array.insert", function()

        it("inserts into an empty array at index 1", function()
            local arr = {}
            local actual = Array.insert(1, "v", arr)

            assert.same({ "v" }, actual)
            assert.same({}, arr)
        end)

        it("inserts at the beginning when index < 1", function()
            local arr = { "b", "c" }
            local actual = Array.insert(0, "a", arr)

            assert.same({ "a", "b", "c" }, actual)
            assert.same({ "b", "c" }, arr)
        end)

        it("inserts at the beginning when index == 1", function()
            local arr = { "b", "c" }
            local actual = Array.insert(1, "a", arr)

            assert.same({ "a", "b", "c" }, actual)
            assert.same({ "b", "c" }, arr)
        end)

        it("inserts in the middle", function()
            local arr = { "a", "c" }
            local actual = Array.insert(2, "b", arr)

            assert.same({ "a", "b", "c" }, actual)
            assert.same({ "a", "c" }, arr)
        end)

        it("inserts at the end when index == length + 1", function()
            local arr = { "a", "b" }
            local actual = Array.insert(3, "c", arr)

            assert.same({ "a", "b", "c" }, actual)
            assert.same({ "a", "b" }, arr)
        end)

        it("inserts at the end when index > length + 1", function()
            local arr = { "a", "b" }
            local actual = Array.insert(5, "c", arr)

            assert.same({ "a", "b", "c" }, actual)
            assert.same({ "a", "b" }, arr)
        end)

        it("supports curry", function()
            local arr = { "a", "c" }

            assert.same({ "a", "b", "c" }, Array.insert(2)("b")(arr))
            assert.same({ "a", "b", "c" }, Array.insert(2)("b", arr))
            assert.same({ "a", "b", "c" }, Array.insert(2, "b")(arr))
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

    describe("Array.length", function()

        it("returns 0 for an empty array", function()
            assert.equal(0, Array.length({}))
        end)

        it("returns 0 if the first element is nil", function()
            assert.equal(0, Array.length({ nil, 2, 3 }))
        end)

        it("returns the correct length for a non-empty array", function()
            assert.equal(3, Array.length({ 1, 2, 3 }))
        end)

        it("works with arrays containing mixed types", function()
            assert.equal(4, Array.length({ 1, "a", true, {} }))
        end)

        it("counts up to the first nil in the sequence", function()
            assert.equal(1, Array.length({ 1, nil, 3 }))
        end)

    end)

    describe("Array.snoc", function()

        it("works on empty array", function()
            local arr = {}
            local actual = Array.snoc(1, arr)
            assert.same({ 1 }, actual)
            assert.same({}, arr)
        end)

        it("returns a new array with the element appended", function()
            local arr = {1, 2, 3}
            local actual = Array.snoc(4, arr)

            assert.same({1, 2, 3, 4}, actual)
            assert.same({1, 2, 3}, arr)
        end)

        it("supports curry", function()
            local arr = { 1, 2 }
            local actual = Array.snoc(3)(arr)

            assert.same({ 1, 2, 3 }, actual)
            assert.same({ 1, 2 }, arr)
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
