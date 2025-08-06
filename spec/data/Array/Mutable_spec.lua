local assert = require("luassert")

describe("p4lua.data.Array.Mutable", function()

    local MutableArray = require("p4lua.data.Array.Mutable")

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
end)
