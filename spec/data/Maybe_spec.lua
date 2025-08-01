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
    end)

end)
