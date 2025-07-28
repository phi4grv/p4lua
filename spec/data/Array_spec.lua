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
