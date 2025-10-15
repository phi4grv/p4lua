local assert = require("luassert")
local Map = require("p4lua.data.Map")

describe("p4lua.data.Array.Mutable", function()

    local MutableArray = require("p4lua.data.Array.Mutable")

    describe("Array.Mutable.appendInto", function()

        local cases = {
            { "append two non-empty arrays", { 1, 2, 3 }, { 4, 5 }, { 4, 5, 1, 2, 3 } },
            { "append empty to non-empty", {}, { 1, 2, 3 }, { 1, 2, 3 } },
            { "append non-empty to empty", { 1, 2, 3 }, {}, { 1, 2, 3 } },
            { "append empty to empty", {}, {}, {} },
            { "mixed types", { 1, "a" }, { true, {} }, { true, {}, 1, "a" } },
            { "nil in first array", { 1, nil, 3 }, { 4, 5 }, { 4, 5, 1 } },
            { "nil in second array middle", { 1, 2 }, { nil, 4, 5, 6 }, { 1, 2, nil, 6 } },
            { "nil in both arrays", { 1, nil, 3 }, { nil, 4, nil, 6 }, { 1, nil, nil, 6 } },
        }

        for i, case in ipairs((cases)) do
            local desc, arr1Org, arr2Org, expectedOrg = table.unpack(case)

            it("case #" .. i .. ": " .. desc, function()
                local arr1 = Map.copyDeep(arr1Org)
                local arr2 = Map.copyDeep(arr2Org)
                local expected = Map.copyDeep(expectedOrg)

                local actual = MutableArray.appendInto(arr1, arr2)

                assert.same(expected, actual)
                assert.equal(arr2, actual)
            end)

            it("case #" .. i .. " supports curry", function()
                local arr1 = Map.copyDeep(arr1Org)
                local arr2 = Map.copyDeep(arr2Org)
                local expected = Map.copyDeep(expectedOrg)

                local actual = MutableArray.appendInto(arr1)(arr2)

                assert.same(expected, actual)
                assert.equal(arr2, actual)
            end)
        end

    end)

    describe("Array.Mutable.prependInto", function()

        local cases = {
            { "prepend two non-empty arrays", { 1, 2, 3 }, { 4, 5 }, { 1, 2, 3, 4, 5 } },
            { "prepend empty to non-empty", {}, { 1, 2, 3 }, { 1, 2, 3 } },
            { "prepend non-empty to empty", { 1, 2, 3 }, {}, { 1, 2, 3 } },
            { "prepend empty to empty", {}, {}, {} },
            { "mixed types", { 1, "a" }, { true, {} }, { 1, "a", true, {} } },
            { "nil in first array", { 1, nil, 3 }, { 4, 5 }, { 1, 4, 5 } },
            { "nil in second array middle", { 1, 2 }, { nil, 4, 5, 6 }, { 1, 2, nil, 6 } },
            { "nil in both arrays", { 1, nil, 3 }, { nil, 4, nil, 6 }, { 1, nil, nil, 6 } },
        }

        for i, case in ipairs((cases)) do
            local desc, arr1Org, arr2Org, expectedOrg = table.unpack(case)

            it("case #" .. i .. ": " .. desc, function()
                local arr1 = Map.copyDeep(arr1Org)
                local arr2 = Map.copyDeep(arr2Org)
                local expected = Map.copyDeep(expectedOrg)

                local actual = MutableArray.prependInto(arr1, arr2)

                assert.same(expected, actual)
                assert.equal(arr2, actual)
            end)

            it("case #" .. i .. " supports curry", function()
                local arr1 = Map.copyDeep(arr1Org)
                local arr2 = Map.copyDeep(arr2Org)
                local expected = Map.copyDeep(expectedOrg)

                local actual = MutableArray.prependInto(arr1)(arr2)

                assert.same(expected, actual)
                assert.equal(arr2, actual)
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
