local assert = require("p4lua.test.compat").luassert(assert)

local adt = require("p4lua.adt")

describe("Sum Types", function()

    local ASumType, match = adt.defineSumType("ASumType", {
        NoKey = {},
        OneKey = { "k1" },
        TwoKeys = { "k1", "k2" },
        ThreeKeys = { "k1", "k2", "k3" },
    })

    it("should match NoKeys", function()
        local noKeyValue = ASumType.NoKey()
        local result = match(noKeyValue, {
            NoKey = function(...) return { ... } end
        })
        assert.are.same(result, {})
    end)

    it("should match OneKeys", function()
        local oneKeyValue = ASumType.OneKey("v1")
        local result = match(oneKeyValue, {
            OneKey = function(...) return { ... } end
        })
        assert.are.same(result, { "v1" })
    end)

    it("should match TwoKeys", function()
        local twoKeyValue = ASumType.TwoKeys("v1", "v2")
        local result = match(twoKeyValue, {
            TwoKeys = function(...) return { ... } end
        })
        assert.are.same(result, { "v1", "v2" })
    end)

    it("should match ThreeKeys", function()
        local threeKeyValue = ASumType.ThreeKeys("v1", "v2", "v3")
        local result = match(threeKeyValue, {
            ThreeKeys = function(...) return { ... } end
        })
        assert.are.same(result, { "v1", "v2", "v3" })
    end)

    it("works with first nil argument in constructors", function()
        local twoKeyValue = ASumType.TwoKeys(nil , "v2")
        local result = match(twoKeyValue, {
            TwoKeys = function(...) return { ... } end
        })
        assert.are.same(result, { nil, "v2" })
    end)

    it("works with last nil argument in constructors", function()
        local twoKeyValue = ASumType.TwoKeys("v1" , nil)
        local result = match(twoKeyValue, {
            TwoKeys = function(...) return { ... } end
        })
        assert.are.same(result, { "v1", nil })
    end)

    it("works with middle nil argument in constructors", function()
        local threeKeyValue = ASumType.ThreeKeys("v1", nil , "v3")
        local result = match(threeKeyValue, {
            -- ThreeKeys = function(a1, a2, a3) return { a1, a2, a3 } end
            ThreeKeys = function(...) return { ... } end
        })
        assert.are.same(result, { "v1", nil, "v3" })
    end)

    it("should raise error if tag does not match", function()
        local unknownValue = { _tag = "Unknown" }
        local success, err = pcall(function()
            match(unknownValue, {})
        end)
        assert.is_false(success)
        assert.is_not_nil(err)
    end)

    it("should return a singleton for constructors with no values", function()
        local a = ASumType.NoKey()
        local b = ASumType.NoKey()
        assert.is_true(a == b)
    end)

end)
