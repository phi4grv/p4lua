local assert = require("luassert")

local p4tbl = require("p4lua.table")

describe("p4lua.table.makeReadOnly", function()

    it("returns a readonly proxy table", function()
        local t = { a = 1, b = 2 }
        local rot = p4tbl.makeReadOnly(t)

        assert.are.equal(1, rot.a)
        assert.are.equal(2, rot.b)
        assert.are.same(t, rot)
        assert.error_matches(function() rot.a = 10 end, "Attempt to modify readonly")
        assert.error_matches(function() rot.newKey = 5 end, "Attempt to modify readonly")
    end)

    it("raises error if argument is not a table", function()
        assert.error_matches(function() p4tbl.makeReadOnly(123) end, "makeReadOnly expects a table")
    end)

    it("protects the metatable", function()
        local rot = p4tbl.makeReadOnly({ x = 1 })

        -- __metatable field is set to false to hide the metatable
        assert.is_false(getmetatable(rot))

        -- Attempting to change the metatable raises error
        assert.has_error(function() setmetatable(rot, {}) end)
    end)

    it("supports pairs iteration", function()
        local t = { foo = "bar", baz = 123 }
        local ro = p4tbl.makeReadOnly(t)

        local keys = {}
        local values = {}
        for k, v in pairs(ro) do
            table.insert(keys, k)
            table.insert(values, v)
        end

        assert.equals(2, #keys)
        assert.is(keys[1] == "foo" or keys[1] == "baz")
        assert.is_true(keys[2] == "foo" or keys[2] == "baz")
        assert.is_true(values[1] == "bar" or values[1] == 123)
        assert.is_true(values[2] == "bar" or values[2] == 123)
    end)

    it("#focus supports ipairs iteration", function()
        local t = { "a", "b", "c" }
        local ro = p4tbl.makeReadOnly(t)

        local result = {}
        for i, v in ipairs(ro) do
            result[i] = v
        end

        assert.are.same({ "a", "b", "c" }, result)
    end)

end)
