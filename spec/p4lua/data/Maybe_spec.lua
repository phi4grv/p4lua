local assert = require("luassert")
local spy = require("luassert.spy")

describe("p4lua.data.Maybe", function()

    local Maybe = require("p4lua.data.Maybe")
    local Just, Nothing = require("p4lua").require("p4lua.data.Maybe", { "Just", "Nothing" })

    describe("Maybe.catMaybes", function()

        it("returns empty array when input is empty", function()
            local empty = {}
            local actual = Maybe.catMaybes(empty)

            assert.are.same({}, actual)
            assert.are_not.equal(empty, actual)
        end)

        it("returns empty array when all elements are Nothing", function()
            local ms = { Nothing, Nothing }
            local actual = Maybe.catMaybes(ms)

            assert.are.same({}, actual)
            assert.are.same({ Nothing, Nothing } , ms)
        end)

        it("extracts values from all Just elements", function()
            local ms = { Just(1), Just(2), Just(3) }
            local actual = Maybe.catMaybes(ms)
            assert.are.same({ 1, 2, 3 }, actual)
            assert.are.same({ Just(1), Just(2), Just(3) }, ms)
        end)

        it("removes Nothing elements and keeps Just values", function()
            local ms = { Just(10), Nothing, Just(20) }
            local actual = Maybe.catMaybes(ms)
            assert.are.same({ 10, 20 }, actual)
            assert.are.same({ Just(10), Nothing, Just(20) }, ms)
        end)

    end)

    describe("Maybe.equalsWith", function()

        it("calls the passed equality function for Just values", function()
            local eqSpy = spy.new(function(a, b)
                return a == b
            end)
            local a = Maybe.Just(10)
            local b = Maybe.Just(10)

            local result = Maybe.equalsWith(eqSpy, a, b)

            assert.is_true(result)
            assert.spy(eqSpy).was.called(1)
            assert.spy(eqSpy).was.called_with(10, 10)
        end)

        it("does not call equality function when comparing two Nothings", function()
            local eqSpy = spy.new(function(a, b)
                return a == b
            end)
            local a = Maybe.Nothing
            local b = Maybe.Nothing

            local result = Maybe.equalsWith(eqSpy, a, b)

            assert.is_true(result)
            assert.spy(eqSpy).was_not.called()
        end)

        it("does not call equality function when comparing Just and Nothing", function()
            local eqSpy = spy.new(function(a, b)
                return a == b
            end)
            local a = Maybe.Just(10)
            local b = Maybe.Nothing

            local result1 = Maybe.equalsWith(eqSpy, a, b)
            local result2 = Maybe.equalsWith(eqSpy, b, a)

            assert.is_false(result1)
            assert.is_false(result2)
            assert.spy(eqSpy).was_not.called()
        end)

        describe("Maybe.equalsWith curried", function()

            it("returns true for equal Just values", function()
                local ma = Maybe.Just("apple")
                local mb = Maybe.Just("apple")
                local eqStr = function(a, b) return a == b end

                local curried = Maybe.equalsWith(eqStr)
                assert.is_true(curried(ma)(mb))
            end)

            it("returns false for different Just values", function()
                local ma = Maybe.Just("apple")
                local mb = Maybe.Just("banana")
                local eqStr = function(a, b) return a == b end

                local curried = Maybe.equalsWith(eqStr)
                assert.is_false(curried(ma)(mb))
            end)

            it("returns false when one side is Nothing", function()
                local ma = Maybe.Just("apple")
                local mb = Maybe.Nothing
                local eqStr = function(a, b) return a == b end

                local curried = Maybe.equalsWith(eqStr)
                assert.is_false(curried(ma)(mb))
            end)

            it("returns true when both sides are Nothing", function()
                local ma = Maybe.Nothing
                local mb = Maybe.Nothing
                local eqStr = function(a, b) return a == b end

                local curried = Maybe.equalsWith(eqStr)
                assert.is_true(curried(ma)(mb))
            end)

        end)
    end)

    describe(".isJust", function()

        it("returns true if Just is given, false otherwise", function()
            assert.is_true(Maybe.isJust(Maybe.Just("_")))
            assert.is_false(Maybe.isJust(Maybe.Nothing))
        end)

    end)

    describe("isNothing", function()

        it("returns true if Nothing is given, false otherwise", function()
            assert.is_true(Maybe.isNothing(Maybe.Nothing))
            assert.is_false(Maybe.isNothing(Maybe.Just("_")))
        end)

    end)

    describe("Maybe.mapMaybe", function()

        local f = function(x)
            if x % 2 == 0 then
                return Just(x * 10)
            else
                return Nothing
            end
        end

        it("returns empty array when input is empty", function()
            local empty = {}
            local actual = Maybe.mapMaybe(f, empty)
            assert.are.same({}, actual)
            assert.not_equal(actual, empty)
        end)

        it("returns empty array when all results are Nothing", function()
            local allOdd = { 1, 3, 5 }
            local actual = Maybe.mapMaybe(f, allOdd)
            assert.are.same({}, actual)
            assert.are.same({ 1, 3, 5 }, allOdd)
        end)

        it("extracts values when all results are Just", function()
            local allEven = { 2, 4 }
            local actual = Maybe.mapMaybe(f, allEven)
            assert.are.same({ 20, 40 }, actual)
            assert.are.same({ 2, 4 }, allEven)
        end)

        it("removes Nothing elements and keeps Just values", function()
            local mixed = { 1, 2, 3, 4 }
            local actual = Maybe.mapMaybe(f, mixed)
            assert.are.same({ 20, 40 }, actual)
            assert.are.same({ 1, 2, 3, 4 }, mixed)
        end)

        it("supports currying", function()
            local arr = { 2, 4 }
            assert.are.same({ 20, 40 }, Maybe.mapMaybe(f)(arr))
            assert.are.same({ 20, 40 }, Maybe.mapMaybe(f, arr))
        end)

    end)

    describe("Maybe.match", function()

        it("should match Just and apply the function", function()
            local justValue = Maybe.Just(123)
            local result = Maybe.match({
                Just = function(v) return v * 2 end,
                Nothing = function() return 0 end
            }, justValue)
            assert.are.equal(246, result)
        end)

        it("should match Nothing and apply the function", function()
            local nothingValue = Maybe.Nothing
            local result = Maybe.match({
                Just = function(v) return v * 2 end,
                Nothing = function() return 0 end
            }, nothingValue)
            assert.are.equal(0, result)
        end)

        it("should throw error if no match and no default is provided", function()
            local nothingValue = Maybe.Nothing
            assert.error_matches(function()
                Maybe.match({
                    Just = function(v) return v * 2 end
                }, nothingValue)
            end, "Match error: unmatched tag")
        end)

    end)

    describe("Maybe.fmap", function()
        it("applies the function to a Just value", function()
            local just = Maybe.Just(10)
            local result = Maybe.fmap(function(x) return x * 2 end, just)
            assert.are.same(Maybe.Just(20), result)
        end)

        it("returns Nothing unchanged", function()
            local result = Maybe.fmap(function(x) return x * 2 end, Maybe.Nothing)
            assert.are.equal(Maybe.Nothing, result)
        end)

        it("does not call function on Nothing", function()
            local called = false
            local result = Maybe.fmap(function()
                called = true
                return "should not be called"
            end, Maybe.Nothing)
            assert.is_false(called)
            assert.are.equal(Maybe.Nothing, result)
        end)

        describe("Maybe.fmap (curried)", function()
            local inc = function(x) return x + 1 end
            local fmapInc = Maybe.fmap(inc)

            it("applies function inside Just", function()
                local result = fmapInc(Maybe.Just(10))
                assert.are.same({ _tag = "Just", value = 11 }, result)
            end)

            it("returns Nothing unchanged", function()
                local result = fmapInc(Maybe.Nothing)
                assert.are.same(Maybe.Nothing, result)
            end)

            it("throws error on invalid input", function()
                assert.error_matches(function()
                    fmapInc({ _tag = "Invalid" })
                end, "Match error: unmatched tag")
            end)

        end)
    end)

    describe("Maybe.fromMaybe", function()

        it("works as a normal function", function()
            assert.are.equal("hello", Maybe.fromMaybe("default", Maybe.Just("hello")))
            assert.are.equal("default", Maybe.fromMaybe("default", Maybe.Nothing))
        end)

        it("works as a curried function", function()
            local curriedFromMaybe = Maybe.fromMaybe("default")
            assert.are.equal("hello", curriedFromMaybe(Maybe.Just("hello")))
            assert.are.equal("default", curriedFromMaybe(Maybe.Nothing))
        end)
    end)

    describe("Maybe.bind", function()

        local function halfIfEven(n)
            if n % 2 == 0 then
                return Maybe.Just(n / 2)
            else
                return Maybe.Nothing
            end
        end

        it("applies function to Just value", function()
            local m = Maybe.Just(10)
            local result = Maybe.bind(m, halfIfEven)
            assert.are.same(Maybe.Just(5), result)
        end)

        it("returns Nothing when function returns Nothing", function()
            local m = Maybe.Just(11)
            local result = Maybe.bind(m, halfIfEven)
            assert.are.same(Maybe.Nothing, result)
        end)

        it("returns Nothing when binding Nothing", function()
            local m = Maybe.Nothing
            local result = Maybe.bind(m, halfIfEven)
            assert.are.same(Maybe.Nothing, result)
        end)

    end)

    describe(".pure", function()

        it("pure should wrap a single value into a Just", function()
            assert.same(Just(42), Maybe.pure(42))
        end)

    end)
end)
