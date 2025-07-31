local assert = require("p4lua.test.compat").luassert(assert)

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

end)
