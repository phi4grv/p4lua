local assert = require("luassert")

describe("p4lua.data.Array.Mutable", function()

    local MutableArray = require("p4lua.data.Array.Mutable")

    describe("Array.Mutable.append", function()

        local cases = {
            { { 1, 2, 3 }, { 4, 5 }, { 1, 2, 3, 4, 5 } },
            { {}, { 1, 2, 3 }, { 1, 2, 3 } },
            { { 1, 2, 3 }, {}, { 1, 2, 3 } },
            { {}, {}, {} },
            { { 1, "a" }, { true, { } }, { 1, "a", true, { } } },
            { { 1, nil, 3 }, { 4, 5 }, { 1, 4, 5 } },
            { { 1, 2 }, { nil, 4, 5 }, { 1, 2 } },
            { { 1, nil, 3 }, { nil, 4, nil }, { 1, nil, 3 } } --WRANING: special case
        }

        for i, case in ipairs(cases) do
            it("case #" .. i, function()
                local arr1, arr2, expected = table.unpack(case)

                local result = MutableArray.append(arr1, arr2)

                assert.same(expected, result)
                assert.equal(arr1, result)
            end)
        end

    end)

    describe("Array.Mutable.cons", function()

        it("works on empty array", function()
            local arr = {}
            local actual = MutableArray.cons(1, arr)
            assert.same({ 1 }, actual)
            assert.equal(arr, actual)
        end)

        it("returns a new array with the element prepended", function()
            local arr = {2, 3, 4}
            local actual = MutableArray.cons(1, arr)
            assert.are.same({1, 2, 3, 4}, actual)
            assert.equal(arr, actual)
        end)

        it("supports curry", function()
            local arr = {2, 3}
            local actual = MutableArray.cons(1)(arr)
            assert.are.same({1, 2, 3}, actual)
            assert.equal(arr, actual)
        end)

    end)

    describe("Array.Mutable.insert", function()

        it("inserts into an empty array at index 1", function()
            local arr = {}
            local actual = MutableArray.insert(1, "v", arr)

            assert.same({ "v" }, actual)
            assert.equal(arr, actual)
        end)

        it("inserts at the beginning when index < 1", function()
            local arr = { "b", "c" }
            local actual = MutableArray.insert(0, "a", arr)

            assert.same({ "a", "b", "c" }, actual)
            assert.equal(arr, actual)
        end)

        it("inserts at the beginning when index == 1", function()
            local arr = { "b", "c" }
            local actual = MutableArray.insert(1, "a", arr)

            assert.same({ "a", "b", "c" }, actual)
            assert.equal(arr, actual)
        end)

        it("inserts in the middle", function()
            local arr = { "a", "c" }
            local actual = MutableArray.insert(2, "b", arr)

            assert.same({ "a", "b", "c" }, actual)
            assert.equal(arr, actual)
        end)

        it("inserts at the end when index == length + 1", function()
            local arr = { "a", "b" }
            local actual = MutableArray.insert(3, "c", arr)

            assert.same({ "a", "b", "c" }, actual)
            assert.equal(arr, actual)
        end)

        it("inserts at the end when index > length + 1", function()
            local arr = { "a", "b" }
            local actual = MutableArray.insert(5, "c", arr)

            assert.same({ "a", "b", "c" }, actual)
            assert.equal(arr, actual)
        end)

        it("supports curry", function()
            local arr = { "a", "c" }

            assert.same({ "a", "b", "c" }, MutableArray.insert(2)("b")(arr))
            assert.same({ "a", "b2", "b", "c" }, MutableArray.insert(2)("b2", arr))
            assert.same({ "a", "b3", "b2", "b", "c" }, MutableArray.insert(2, "b3")(arr))
        end)

    end)

    describe("Array.Mutable.snoc", function()

        it("works on empty array", function()
            local arr = {}
            local actual = MutableArray.snoc(1, arr)
            assert.same({ 1 }, actual)
            assert.equal(arr, actual)
        end)

        it("returns a new array with the element appended", function()
            local arr = {1, 2, 3}
            local actual = MutableArray.snoc(4, arr)

            assert.same({1, 2, 3, 4}, actual)
            assert.equal(arr, actual)
        end)

        it("supports curry", function()
            local arr = { 1, 2 }
            local actual = MutableArray.snoc(3)(arr)

            assert.same({ 1, 2, 3 }, actual)
            assert.equal(arr, actual)
        end)

    end)
end)
