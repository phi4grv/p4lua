local assert = require("p4lua.test.compat").luassert(assert)

describe("p4lua.data.Maybe", function()

    local Maybe = require("p4lua.data.Maybe")

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
end)
