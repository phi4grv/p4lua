local assert = require("p4lua.test.compat").luassert(assert)

describe("p4lua.data.Maybe", function()

    local Maybe = require("p4lua.data.Maybe")

    describe("Maybe.match", function()

        it("should match Just and apply the function", function()
            local justValue = Maybe.Just(123)
            local result = Maybe.match(justValue, {
                Just = function(v) return v * 2 end,
                Nothing = function() return 0 end
            })
            assert.are.equal(246, result)
        end)

        it("should match Nothing and apply the function", function()
            local nothingValue = Maybe.Nothing
            local result = Maybe.match(nothingValue, {
                Just = function(v) return v * 2 end,
                Nothing = function() return 0 end
            })
            assert.are.equal(0, result)
        end)

        it("should throw error if no match and no default is provided", function()
            local nothingValue = Maybe.Nothing
            assert.has_error(function()
                Maybe.match(nothingValue, {
                    Just = function(v) return v * 2 end
                })
            end, "Match error: unmatched tag 'Nothing' in type 'Maybe'")
        end)
    end)
end)
