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

