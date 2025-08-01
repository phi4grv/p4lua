local assert = require("p4lua.test.compat").luassert(assert)

local adt = require("p4lua.adt")

local ASumType, match = adt.defineSumType("ASumType", {
    NoKey = {},
    OneKey = { "k1" },
    TwoKeys = { "k1", "k2" },
    ThreeKeys = { "k1", "k2", "k3" },
})

describe("Sum Types", function()

    it("should match NoKeys", function()
        local noKeyValue = ASumType.NoKey()
        local result = match({
            NoKey = function(...) return { ... } end
        }, noKeyValue)
        assert.are.same(result, {})
    end)

    it("should match OneKeys", function()
        local oneKeyValue = ASumType.OneKey("v1")
        local result = match({
            OneKey = function(...) return { ... } end
        }, oneKeyValue)
        assert.are.same(result, { "v1" })
    end)

    it("should match TwoKeys", function()
        local twoKeyValue = ASumType.TwoKeys("v1", "v2")
        local result = match({
            TwoKeys = function(...) return { ... } end
        }, twoKeyValue)
        assert.are.same(result, { "v1", "v2" })
    end)

    it("should match ThreeKeys", function()
        local threeKeyValue = ASumType.ThreeKeys("v1", "v2", "v3")
        local result = match({
            ThreeKeys = function(...) return { ... } end
        }, threeKeyValue)
        assert.are.same(result, { "v1", "v2", "v3" })
    end)

    it("works with first nil argument in constructors", function()
        local twoKeyValue = ASumType.TwoKeys(nil , "v2")
        local result = match({
            TwoKeys = function(...) return { ... } end
        }, twoKeyValue)
        assert.are.same(result, { nil, "v2" })
    end)

    it("works with last nil argument in constructors", function()
        local twoKeyValue = ASumType.TwoKeys("v1" , nil)
        local result = match({
            TwoKeys = function(...) return { ... } end
        }, twoKeyValue)
        assert.are.same(result, { "v1", nil })
    end)

    it("works with middle nil argument in constructors", function()
        local threeKeyValue = ASumType.ThreeKeys("v1", nil , "v3")
        local result = match({
            -- ThreeKeys = function(a1, a2, a3) return { a1, a2, a3 } end
            ThreeKeys = function(...) return { ... } end
        }, threeKeyValue)
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

describe("match function returned by defineSumType", function()

    local branches = {
        NoKey = function(k1) return "NoKey" end,
        OneKey = function(k1) return "OneKey:" .. k1 end,
        TwoKeys = function(k1, k2) return "TwoKeys:" .. k1 .."," .. k2 end,
        ThreeKeys = function(k1, k2, k3) return "ThreeKeys:" .. k1 .."," .. k2 .. "," .. k3 end,
    }

    it("is curried: match(branches)(value)", function()
        local curried = match(branches)
        assert.are.same("NoKey", curried(ASumType.NoKey()))
        assert.are.same("OneKey:1", curried(ASumType.OneKey(1)))
        assert.are.same("TwoKeys:1,2", curried(ASumType.TwoKeys(1, 2)))
        assert.are.same("ThreeKeys:1,2,3", curried(ASumType.ThreeKeys(1, 2, 3)))
    end)
end)
