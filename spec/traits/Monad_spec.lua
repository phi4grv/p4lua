local assert = require("p4lua.test.compat").luassert(assert)
local Monad = require("p4lua.traits.Monad")
local Maybe = require("p4lua.data.Maybe")

describe("Kleisli composition using Monad.makeKleisliCompose and Monad.makeKleisliComposeArray", function()

    local f1 = function(x)
        if x > 0 then return Maybe.Just(x + 1) else return Maybe.Nothing end
    end

    local f2 = function(x) return Maybe.Just(x * 2) end

    local f3 = function(x)
        if x < 10 then return Maybe.Just(x - 3) else return Maybe.Nothing end
    end

    local cases = {
        {
            name = "makeKleisliCompose (variadic arguments)",
            getComposed = function()
                local compose = Monad.makeKleisliCompose(Maybe.bind)
                return compose(f1, f2, f3)
            end
        },
        {
            name = "makeKleisliComposeArray (array of functions)",
            getComposed = function()
                local composeArray = Monad.makeKleisliComposeArray(Maybe.bind)
                return composeArray({ f1, f2, f3 })
            end
        }
    }

    for _, case in ipairs(cases) do
        describe(case.name, function()

            local composed = case.getComposed()

            it("composes functions and returns final Just result when all succeed", function()
                assert.are.same(Maybe.Just(5), composed(3))
            end)

            it("returns Nothing if any function short-circuits", function()
                assert.are.same(Maybe.Nothing, composed(10))
            end)

        end)
    end

    describe("supports re-composition", function()

        it("using makeKleisliCompose", function()
            local compose = Monad.makeKleisliCompose(Maybe.bind)
            local composed1 = compose(f1, f2)
            local composed2 = compose(composed1, f3)

            assert.are.same(Maybe.Just(5), composed2(3))
        end)

        it("using makeKleisliComposeArray", function()
            local compose = Monad.makeKleisliComposeArray(Maybe.bind)
            local composed1 = compose({f1, f2})
            local composed2 = compose({composed1, f3})

            assert.are.same(Maybe.Just(5), composed2(3))
        end)

    end)

    describe("Kleisli composition with no functions falls back to unit", function()

        it("makeKleisliCompose returns unit when called with no functions", function()
            local compose = Monad.makeKleisliCompose(Maybe.bind, Maybe.Just)
            local unit = compose()

            assert.are.same(Maybe.Just(42), unit(42))
            assert.are.same(Maybe.Just("hello"), unit("hello"))
        end)

        it("makeKleisliComposeArray returns unit when called with empty array", function()
            local compose = Monad.makeKleisliComposeArray(Maybe.bind, Maybe.Just)
            local unit = compose({})

            assert.are.same(Maybe.Just(42), unit(42))
            assert.are.same(Maybe.Just("hello"), unit("hello"))
        end)
    end)

    describe("makeKleisliComposeArray input validation", function()
        local composeArray = Monad.makeKleisliComposeArray(Maybe.bind, Maybe.Just)

        it("throws error if input is not a table", function()
            assert.has_error(function()
                composeArray(nil)
            end, "bad argument #1 to 'makeKleisliComposeArray' (table expected, got nil)")

            assert.has_error(function()
                composeArray(123)
            end, "bad argument #1 to 'makeKleisliComposeArray' (table expected, got number)")

            assert.has_error(function()
                composeArray(nil)
            end, "bad argument #1 to 'makeKleisliComposeArray' (table expected, got nil)")
        end)
    end)

end)

describe("makeChainBind", function()

    local function f1(x)
        return x > 0 and Maybe.Just(x + 1) or Maybe.Nothing
    end

    local function f2(x)
        return x % 2 == 0 and Maybe.Just(x * 2) or Maybe.Nothing
    end

    local function f3(x)
        return Maybe.Just(x - 3)
    end

    local chainBind = Monad.makeChainBind(Maybe.bind)

    it("chains multiple monadic functions correctly", function()
        local result = chainBind({f1, f2, f3}, Maybe.Just(1))
        assert.same(Maybe.Just(1), result)

        local curriedResult = chainBind({f1, f2, f3})(Maybe.Just(1))
        assert.same(Maybe.Just(1), curriedResult)
    end)

    it("returns Nothing if any function returns Nothing", function()
        local result = chainBind({f1, f2, f3}, Maybe.Just(-1)) -- f1 returns Nothing
        assert.equals(Maybe.Nothing, result)

        local curriedResult = chainBind({f1, f2, f3})(Maybe.Just(-1))
        assert.equals(Maybe.Nothing, curriedResult)

        local result2 = chainBind({f1, f2, f3}, Maybe.Just(4)) -- f2 fails (4 % 2 ≠ 0)
        assert.equals(Maybe.Nothing, result2)

        local curriedResult2 = chainBind({f1, f2, f3})(Maybe.Just(4)) -- f2 fails (4 % 2 ≠ 0)
        assert.equals(Maybe.Nothing, curriedResult2)
    end)

    it("works with a single function", function()
        local result = chainBind({f3}, Maybe.Just(10))
        assert.same(Maybe.Just(7), result)

        local curriedResult = chainBind({f3})(Maybe.Just(10))
        assert.same(Maybe.Just(7), curriedResult)
    end)

    it("returns identity when function list is empty", function()
        local result = chainBind({}, Maybe.Just(42))
        assert.same(Maybe.Just(42), result)

        local curriedResult = chainBind({})(Maybe.Just(42))
        assert.same(Maybe.Just(42), curriedResult)
    end)

    it("returns identity function when called with nil", function()
        local result = chainBind(nil, Maybe.Just("hello"))
        assert.are.same(Maybe.Just("hello"), result)

        local curriedResult = chainBind(nil)(Maybe.Just("hello"))
        assert.are.same(Maybe.Just("hello"), curriedResult)
    end)

    it("returns identity function when called with no args", function()
        local curriedResult = chainBind()(Maybe.Just("hello"))
        assert.are.same(Maybe.Just("hello"), curriedResult)
    end)

    it("supports a single function instead of a list", function()
        local result = chainBind(f3, Maybe.Just(10)) -- f3: x - 3 → 7
        assert.same(Maybe.Just(7), result)

        local curriedResult = chainBind(f3)(Maybe.Just(10))
        assert.same(Maybe.Just(7), curriedResult)
    end)

end)
