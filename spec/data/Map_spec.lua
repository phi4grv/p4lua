local assert = require("luassert")
local Maybe = require("p4lua.data.Maybe")
local Just = Maybe.Just
local Nothing = Maybe.Nothing

describe("p4lua.data.Map", function()

    local Map = require("p4lua.data.Map")

    describe("Map.delete", function()
        it("removes an existing key from the map", function()
            local m = { a = 1, b = 2, c = 3 }
            local actual = Map.delete("b", m)

            assert.same({ a = 1, c = 3 }, actual)
            assert.same({ a = 1, b = 2, c = 3 }, m)
        end)

        it("does nothing if the key does not exist", function()
            local m = { a = 1, b = 2 }
            local actual = Map.delete("missing", m)

            assert.same({ a = 1, b = 2 }, actual)
            assert.not_equal(m, actual)
        end)

        it("works with an empty map", function()
            local empty = {}
            local actual = Map.delete("x", empty)

            assert.same({}, actual)
            assert.not_equal(empty, actual)
        end)

        it("supports currying", function()
            local m = { a = 1, b = 2, c = 3 }
            local actual = Map.delete("b")(m)

            assert.same({ a = 1, c = 3 }, actual)
            assert.same({ a = 1, b = 2, c = 3 }, m)
        end)
    end)

    describe("Map.deepCopy", function()

        local nested1 = { x = 10, y = { z = 20 } }
        local nested2 = { a = 1, b = { c = 2, d = { e = 3 } } }

        local cases = {
            { "empty map", {}, {} },
            { "flat map", { a = 1, b = 2, c = 3 }, { a = 1, b = 2, c = 3 } },
            { "nested map", nested1, { x = 10, y = { z = 20 } } },
            { "deep nested map", nested2, { a = 1, b = { c = 2, d = { e = 3 } } } },
            { "array with nil", { 1, 2, nil, 4 }, { 1, 2, nil, 4 } },
        }

        for _, case in ipairs(cases) do
            local desc, input, expected = table.unpack(case)

            it(desc, function()
                local copy = Map.deepCopy(input)

                assert.not_equal(input, copy)
                assert.same(expected, copy)

                local function check_nested_different(t1, t2)
                    for k, v in pairs(t1) do
                        if type(v) == "table" then
                            assert.not_equal(v, t2[k])
                            check_nested_different(v, t2[k])
                        end
                    end
                end

                check_nested_different(input, copy)
            end)
        end

        describe("Map.deepCopy - non-table inputs", function()

            local cases = {
                { "number", 42 },
                { "string", "hello" },
                { "boolean true", true },
                { "boolean false", false },
                { "nil", nil },
                { "function", function() return 1 end },
            }

            for _, case in ipairs(cases) do
                local desc, input = table.unpack(case)

                it(desc, function()
                    local copy = Map.deepCopy(input)
                    assert.equal(input, copy)
                end)
            end
        end)

    end)

    describe("Map.equals", function()

        it("compare using ==", function()
            assert.is_true(Map.equals({ k = "v" }, { k = "v" }))
            assert.is_false(Map.equals({ a = {} }, { a = {} }))
        end)

        it("supports curry", function()
            local eq1 = Map.equals({ a = "v" })
            assert.is_true(eq1({ a = "v" }))
            assert.is_false(eq1({ a = "x" }))
        end)

    end)

    describe("Map.equalsWith", function()

        local simpleEq = function(a, b) return a == b end
        local ignoreCaseEq = function(a, b)
            if type(a) == "string" and type(b) == "string" then
                return a:lower() == b:lower()
            end
            return a == b
        end

        local cases = {
            { "equal simple maps", simpleEq, { a = 1, b = 2 }, { a = 1, b = 2 }, true },
            { "different keys", simpleEq, { a = 1 }, { b = 1 }, false },
            { "different values", simpleEq, { a = 1 }, { a = 2 }, false },
            { "ignore case values", ignoreCaseEq, { a = "Hello" }, { a = "hello" }, true },
            { "empty maps", simpleEq, {}, {}, true },
            { "nil value equal", simpleEq, { a = nil }, { a = nil }, true },
            { "nil vs missing key", simpleEq, { a = nil }, {}, true },
            { "nil vs non-nil", simpleEq, { a = nil }, { a = 1 }, false },
        }
        for i, case in ipairs(cases) do
            local desc, eqf, m1, m2, expected = table.unpack(case)

            it("case #" .. i .. ": " .. desc, function()
                assert.equal(expected, Map.equalsWith(eqf, m1, m2))
            end)

            it("case #" .. i .. ": curry support", function()
                assert.equal(expected, Map.equalsWith(eqf)(m1)(m2))
                assert.equal(expected, Map.equalsWith(eqf)(m1, m2))
                assert.equal(expected, Map.equalsWith(eqf, m1)(m2))
            end)
        end

    end)

    describe("Map.fold", function()

        it("sums all values in the map", function()
            local map = { a = 1, b = 2, c = 3 }

            local sum = Map.fold(function(acc, _, v)
                return acc + v
            end, 0, map)
            assert.is_true(sum == 6)
        end)

        it("accumulates entries into a new table by key and value", function()
            local map = { a = 1, b = 2 }
            local seen = Map.fold(function(acc, k, v)
                acc[k .. v] = true
                return acc
            end, {}, map)

            assert.is_true(seen["a1"])
            assert.is_true(seen["b2"])
        end)

        it("returns the initial value when folding over an empty map", function()
            local result = Map.fold(function(acc, k, v) return acc + 1 end, 0, {})
            assert.equals(0, result)
        end)

        describe("Map.fold (curried)", function()
            local map = { a = 1, b = 2 }

            local function sum(acc, _, v)
                return acc + v
            end

            it("works with full application: fold(f, init, map)", function()
                local result = Map.fold(sum, 0, map)
                assert.equals(3, result)
            end)

            it("works with partial: fold(f, init)(map)", function()
                local result = Map.fold(sum, 0)(map)
                assert.equals(3, result)
            end)

            it("works with partial: fold(f)(init, map)", function()
                local result = Map.fold(sum)(0, map)
                assert.equals(3, result)
            end)

            it("works with full curry: fold(f)(init)(map)", function()
                local result = Map.fold(sum)(0)(map)
                assert.equals(3, result)
            end)
        end)

    end)

    describe("filterByKeys function", function()

        it("should return an empty Map when Map is empty and no keys are provided", function()
            assert.are.same(Map.filterByKeys({}, {}), {})
        end)

        it("should return an empty Map when no keys are provided", function()
            local m = { k = "v" }
            assert.are.same(Map.filterByKeys({}, m), {})
        end)

        it("should return an empty Map if none of the keys match", function()
            local m = { k = "v" }
            assert.are.same(Map.filterByKeys({ "no matching key"}, m), {})
        end)
        --
        it("should return the Map with matched keys", function()
            local m = { k1 = "v1", k2 = "v2" }
            assert.are.same(Map.filterByKeys({ "k1" }, m), { k1 = "v1" })
        end)

        it("supports curry", function()
            local m = { k1 = "v1", k2 = "v2" }
            assert.are.same(Map.filterByKeys({ "k1" })(m), { k1 = "v1" })
        end)

    end)

    describe("Map.fromKeysAndValues", function()

        local cases = {
            { "011", { {}, {} }, {}, "both are emtpy" },
            { "012", { {}, { 1 } }, {}, "keys are emtpy" },
            { "013", { { "k1" }, {} }, {}, "values are emtpy" },
            { "021", { { nil, "k2" }, { nil, 2 } }, {}, "both are emtpy with nil" },
            { "022", { { nil, "k2" }, { 1 } }, {}, "keys are emtpy with nil" },
            { "023", { { "k1" }, { nil, 1} }, {}, "values are emtpy with nil" },
            { "031", { { "k1" }, { 1 } }, { k1 = 1 }, "keys and values are same length" },
            { "032", { { "k1", "k2" }, { 1, 2 } }, { k1 = 1, k2 = 2 }, "keys and values are same length" },
            { "041", { { "k1" }, { 1, 2 } }, { k1 = 1 }, "keys and values are different length" },
            { "042", { { "k1", "k2" }, { 1 } }, { k1 = 1 }, "keys and values are different length" },
        }

        for _, c in ipairs(cases) do
            local case = { id = c[1], data = c[2], expected = c[3], desc = c[4] }

            it(("case #%s: %s"):format(case.id, case.desc), function()
                assert.same(case.expected, Map.fromKeysAndValues(case.data[1], case.data[2]))
            end)

            it(("case #%s: %s: supports curry"):format(case.id, case.desc), function()
                assert.same(case.expected, Map.fromKeysAndValues(case.data[1])(case.data[2]))
            end)
        end

    end)

    describe("Map.insert", function()

        it("inserts a new key-value pair into an empty map", function()
            local m0 = {}
            local m1 = Map.insert("a", 1, m0)
            assert.is_nil(m0["a"])
            assert.equals(1, m1["a"])
            assert.are.same({}, m0)
        end)

        it("inserts a new key-value pair into a non-empty map", function()
            local m0 = { b = 2 }
            local m1 = Map.insert("a", 1, m0)

            assert.equals(2, m0["b"])
            assert.is_nil(m0["a"])
            assert.equals(1, m1["a"])
            assert.equals(2, m1["b"])
            assert.are.same({ b = 2 }, m0)
        end)

        it("overwrites an existing key with a new value", function()
            local m0 = { a = 1, b = 2 }
            local m1 = Map.insert("a", 3, m0)
            assert.equals(1, m0["a"])
            assert.equals(3, m1["a"])
            assert.equals(2, m1["b"])
            assert.are.same({ a = 1, b = 2 }, m0)
        end)

        it("does not mutate the original map", function()
            local m0 = { a = 1 }
            local m1 = Map.insert("a", 2, m0)
            assert.equals(1, m0["a"])
            assert.equals(2, m1["a"])
            assert.are.same({ a = 1 }, m0)
        end)

        it("supports currying: Map.insert(k, v)(map)", function()
            local m0 = { a = 1 }
            local insertA = Map.insert("a", 2)
            local m1 = insertA(m0)
            assert.equals(2, m1["a"])
            assert.are.same({ a = 1 }, m0)
        end)

        it("supports currying: Map.insert(k)(v)(map)", function()
            local m0 = { a = 1 }
            local insertA = Map.insert("a")
            local insertA2 = insertA(2)
            local m1 = insertA2(m0)
            assert.equals(2, m1["a"])
            assert.are.same({ a = 1 }, m0)
        end)

        it("supports currying: Map.insert(k)(v, map)", function()
            local m0 = { a = 1 }
            local insertA = Map.insert("a")
            local m1 = insertA(2, m0)
            assert.equals(2, m1["a"])
            assert.are.same({ a = 1 }, m0)
        end)
    end)

    describe("Map.keys", function()

        local cases = {
            { "empty map", {}, {} },
            { "flat map", { a = 1, b = 2, c = 3 }, { "a", "b", "c" } },
            { "nested map", { a = { x = 10 }, b = 2 }, { "a", "b" } },
            { "numeric keys", { [1] = "one", [2] = "two" }, { 1, 2 } },
            { "mixed keys", { ["one"] = 1, [2] = "two" }, { "one", 2 } },
            { "keys with nil values", { a = nil, b = 2 }, { "b" } },
            { "array keys", { "one", "two" }, { 1, 2 } },
            { "array starting nil", { nil, "two", "three" }, { 2, 3 } },
            { "array with middle nil", { "one", nil, "three" }, { 1, 3 } },
            { "array trailing nil", { nil, "two", nil }, { 2 } },
            { "array with nils only", { nil, nil, nil }, {} },
        }

        for i, case in ipairs(cases) do
            local desc, input, expected = table.unpack(case)

            it(desc, function()
                local keys = Map.keys(input)
                -- Sort keys for consistent order before assert.same
                table.sort(keys, function(a, b)
                    if type(a) == type(b) then return a < b
                    else return tostring(a) < tostring(b) end
                end)
                ---@cast expected table
                table.sort(expected, function(a, b)
                    if type(a) == type(b) then return a < b
                    else return tostring(a) < tostring(b) end
                end)
                assert.same(expected, keys)
            end)
        end

    end)

    describe("Map.lookup", function()

        it("returns Maybe.Just(value) if key exists", function()
            local actual = Map.lookup("a", { a = 42 })
            assert.is_true(Maybe.equals(Maybe.Just(42), actual))
        end)

        it("returns Maybe.Nothing() if key does not exist", function()
            local actual = Map.lookup("missing", { })
            assert.equals(Maybe.Nothing, actual)
        end)

        it("supports currying", function()
            local actual = Map.lookup("a")({ a = 99})
            assert.is_true(Maybe.equals(Maybe.Just(99), actual))
        end)

    end)

    describe("Map.shallowCopy", function()

        local nested = { x = 10 }
        local cases = {
            { "empty map", {} },
            { "flat map", { a = 1, b = 2, c = 3 } },
            { "nested map reference", { a = nested, b = 2 } },
            { "array with no nils", { 1, 2, 3 } },
            { "array starting with nil", { nil, 2, 3 } },
            { "array with nil in middle", { 1, nil, 3 } },
            { "array with trailing nils", { 1, 2, nil } },
        }

        for i, case in ipairs(cases) do
            local desc, data = table.unpack(case)
            it(desc, function()
                local copy = Map.shallowCopy(data)

                assert.not_equal(data, copy)
                assert.same(data, copy)

                ---@cast data table
                for k, v in pairs(data) do
                    if type(v) == "table" then
                        assert.equal(v, copy[k])
                    end
                end
            end)
        end

    end)

    describe("Map.size", function()

        local cases = {
            { "empty map", {}, 0 },
            { "single entry", { a = 1 }, 1 },
            { "multiple entries", { a = 1, b = 2, c = 3 }, 3 },
            { "nested table values", { a = {1, 2}, b = 2 }, 2 },
            { "nil values ignored", { a = 1, b = nil, c = 3 }, 2 },
        }

        for i, case in ipairs(cases) do
            local desc, map, expected = table.unpack(case)
            it(desc, function()
                local result = Map.size(map)
                assert.same(expected, result)
            end)
        end

    end)

    describe("Map.values", function()

        it("returns an empty array when the table is empty", function()
            local vs = Map.values({})
            assert.are.same({}, vs)
        end)

        it("returns all values from a map", function()
            local vs = Map.values({ a = 10, b = 20, c = 30 })

            table.sort(vs) -- to ignore order
            assert.are.same({10, 20, 30}, vs)
        end)

        it("returns all non-nil values from a map", function()
            local vs = Map.values({ a = 1, b = nil, c = 2 })

            table.sort(vs) -- to ignore order
            assert.are.same({1, 2}, vs)
        end)

        it("returns an empty array when all values are nil", function()
            local vs = Map.values({ a = nil, b = nil })

            assert.are.same({}, vs)
        end)

    end)

    describe("Map.valuesByKeys function", function()

        it("returns Maybe.Just values for given keys in order", function()
            local m = { a = 1, b = 2, c = 3 }
            local ks = { "b", "c" }

            local actual = Map.valuesByKeys(ks, m)
            assert.same({ Just(2), Just(3) }, actual)
        end)

        it("return Maybe.Nothing if keys not exists in the map", function()
            local actual = Map.valuesByKeys({ "k1", "k2" }, {})
            assert.same({ Nothing, Nothing }, actual)
        end)

        it("returns empty array if keys list is empty", function()
            local m = { a = 1 }
            local ks = {}

            local vals = Map.valuesByKeys(ks, m)
            assert.same({}, vals)
        end)

        it("supports curry", function()
            local m = { a = 1, b = 2 }
            local ks = { "b", "not exists", "a" }

            local actual = Map.valuesByKeys(ks)(m)
            assert.same({ Just(2), Nothing, Just(1) }, actual)
        end)

    end)
end)
