local assert = require("luassert")

describe("p4lua.data.String", function()

    local String = require("p4lua.data.string")

    describe(".isEmpty", function()

        it("returns true for nil or empty string", function()
            assert.is_true(String.isEmpty(nil))
            assert.is_true(String.isEmpty(""))
        end)

        it("returns false for non-empty strings", function()
            assert.is_false(String.isEmpty("a"))
            assert.is_false(String.isEmpty(" "))
            assert.is_false(String.isEmpty("0"))
        end)
    end)

    describe(".optPrefix", function()

        it("adds prefix when string is non-empty", function()
            assert.equal(": x", String.optPrefix(": ", "x"))
            assert.equal("--foo", String.optPrefix("--", "foo"))
        end)

        it("returns empty string when input is empty or nil", function()
            assert.equal("", String.optPrefix(": ", ""))
            assert.equal("", String.optPrefix(": ", nil))
        end)

    end)

    describe(".optSuffix", function()

        it("adds suffix when string is non-empty", function()
            assert.equal("x.", String.optSuffix(".", "x"))
            assert.equal("foo!", String.optSuffix("!", "foo"))
        end)

        it("returns empty string when input is empty or nil", function()
            assert.equal("", String.optSuffix(".", ""))
            assert.equal("", String.optSuffix(".", nil))
        end)

    end)
end)
