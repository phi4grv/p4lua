local assert = require("luassert")

describe("MutableMap.insert", function()

    local MutableMap = require("p4lua.data.Map.Mutable")

    describe("MutableMap.delete", function()

        it("removes an existing key from the map", function()
            local m = { a = 1, b = 2, c = 3 }
            local actual = MutableMap.delete("b", m)

            assert.same({ a = 1, c = 3 }, actual)
            assert.equal(m, actual)
        end)

        it("does nothing if the key does not exist", function()
            local m = { a = 1, b = 2 }
            local actual = MutableMap.delete("missing", m)

            assert.same({ a = 1, b = 2 }, actual)
            assert.equal(m, actual)
        end)

        it("works with an empty map", function()
            local empty = {}
            local actual = MutableMap.delete("x", empty)

            assert.same({}, actual)
            assert.equal(empty, actual)
        end)

        it("supports currying", function()
            local m = { a = 1, b = 2, c = 3 }
            local actual = MutableMap.delete("b")(m)

            assert.same({ a = 1, c = 3 }, actual)
            assert.equal(m, actual)
        end)

    end)

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
