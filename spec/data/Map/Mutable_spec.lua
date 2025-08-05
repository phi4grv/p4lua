local assert = require("luassert")

local MutableMap = require("p4lua.data.Map.Mutable")

describe("MutableMap.insert", function()

    it("inserts a key-value pair into the map and modifies the original", function()
        local m = { a = 1 }
        local result = MutableMap.insert("b", 2, m)

        assert.are.equal(2, m.b)
        assert.are.equal(2, result["b"])
        assert.are.equal(m, result)
    end)

    it("overwrites the value if the key already exists", function()
        local m = { a = 1 }
        local result = MutableMap.insert("a", 42, m)
        assert.are.equal(42, m.a)
        assert.are.equal(m, result)
    end)

    describe("supports currying in all 3 patterns", function()

        it('pattern 1: MutableMap.insert("k")("v")("mm")', function()
            local mm = {}
            MutableMap.insert("k")("v")(mm)
            assert.are.equal( "v", mm.k )
        end)

        it('pattern 2: MutableMap.insert("k")("v", mm)', function()
            local mm = {}
            MutableMap.insert("k")("v", mm)
            assert.are.equal( "v", mm.k )
        end)

        it('pattern 3: MutableMap.insert("k", "v")(mm)', function()
            local mm = {}
            MutableMap.insert("k", "v")(mm)
            assert.are.equal( "v", mm.k )
        end)

    end)
end)
