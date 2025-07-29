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
