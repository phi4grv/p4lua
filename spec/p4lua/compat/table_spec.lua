local assert = require("luassert")

describe("p4lua.compat.table", function()

    local p4tbl = require("p4lua.compat.table")

    describe("table.move", function()

        it("copies elements forward within the same table", function()
            local t = { "a", "b", "c", "d" }
            p4tbl.move(t, 1, 3, 2, t) -- move a,b,c to position 2
            assert.are.same({ "a", "a", "b", "c" }, t)
        end)

        it("copies elements backward within the same table", function()
            local t = { "a", "b", "c", "d" }
            p4tbl.move(t, 2, 4, 1, t) -- move b,c,d to position 1
            assert.are.same({ "b", "c", "d", "d" }, t)
        end)

        it("copies elements to another table", function()
            local src = { 1, 2, 3, 4, 5 }
            local dst = {}
            p4tbl.move(src, 2, 4, 1, dst) -- copy 2,3,4 to dst[1..3]
            assert.are.same({ 2, 3, 4 }, dst)
        end)

        it("returns the destination table", function()
            local src = { 10, 20, 30 }
            local dst = {}
            local result = p4tbl.move(src, 1, 2, 1, dst)
            assert.are.equal(dst, result)
        end)

        it("works when destination is after source (forward copy)", function()
            local t = { "x", "y", "z" }
            p4tbl.move(t, 1, 2, 3, t) -- move x,y to 3,4
            assert.are.same({ "x", "y", "x", "y" }, t)
        end)

        it("works when destination is before source (backward copy)", function()
            local t = { "x", "y", "z" }
            p4tbl.move(t, 2, 3, 1, t) -- move y,z to 1,2
            assert.are.same({ "y", "z", "z" }, t)
        end)
    end)

    describe("table.unpack compatibility", function()

        it("works with empty array", function()
            assert.is_nil(p4tbl.unpack({}))
            assert.is_nil(table.unpack({}))
        end)

        it("works with simple array", function()
            local a1, a2, a3 = p4tbl.unpack({ 1, 2, 3 })
            assert.same({ 1, 2, 3 }, { a1, a2, a3 })

            local b1, b2, b3 = table.unpack({ 1, 2, 3 })
            assert.same({ 1, 2, 3 }, { b1, b2, b3 })
        end)

        it("works with staring nil", function()
            local a1, a2, a3 = p4tbl.unpack({ nil, 2, 3 }, 1, 3)
            assert.same({ nil, 2, 3 }, { a1, a2, a3 })

            local b1, b2, b3 = table.unpack({ nil, 2, 3 }, 1, 3)
            assert.same({ nil, 2, 3 }, { b1, b2, b3 })
        end)

        it("works with middle nil", function()
            local a1, a2, a3 = p4tbl.unpack({ 1, nil, 3 }, 1, 3)
            assert.same({ 1, nil, 3 }, { a1, a2, a3 })

            local b1, b2, b3 = table.unpack({ 1, nil, 3 }, 1, 3)
            assert.same({ 1, nil, 3 }, { b1, b2, b3 })
        end)

        it("works with trailing nil", function()
            local a1, a2, a3 = p4tbl.unpack({ 1, 2, nil }, 1, 3)
            assert.same({ 1, 2, nil }, { a1, a2, a3 })

            local b1, b2, b3 = table.unpack({ 1, 2, nil }, 1, 3)
            assert.same({ 1, 2, nil }, { b1, b2, b3 })
        end)

        it("works with only nil", function()
            local a1, a2, a3 = p4tbl.unpack({ nil, nil, nil }, 1, 3)
            assert.same({ nil, nil, nil }, { a1, a2, a3 })

            local b1, b2, b3 = table.unpack({ nil, nil, nil }, 1, 3)
            assert.same({ nil, nil, nil }, { b1, b2, b3 })
        end)

    end)

end)
