local Map = require("p4lua.data.Map")
local assert = Map.filterByKeys(assert, { "are", "equals", "is_true", "is_false" }) -- suppress LSP warning

local p4fn = require("p4lua.fn")

local add1 = function(x) return x + 1 end
local mul2 = function(x) return x * 2 end
local square = function(x) return x ^ 2 end

local test_cases = {
    {
        name = "p4lua.fn.compose",
        apply = function(...) return p4fn.compose(...) end
    },
    {
        name = "p4lua.fn.compose_table",
        apply = function(...) return p4fn.compose_table({ ... }) end
    }
}

for _, case in ipairs(test_cases) do
    describe(case.name, function()
        it("should compose two functions", function()
            local f = case.apply(mul2, add1)
            assert.equals(4, f(1))
        end)

        it("should compose three functions", function()
            local f = case.apply(square, mul2, add1)
            assert.equals(16, f(1))
        end)

        it("returns identity when no functions given", function()
            local f = case.apply()
            assert.equals("identity", f("identity"))
        end)

        it("works with single function", function()
            local f = case.apply(add1)
            assert.equals(2, f(1))
        end)
    end)
end

describe("p4lua.fn.curry", function()
    local function add0() return "add0" end
    local function add1(a) return a end
    local function add2(a, b) return a + b end
    local function add3(a, b, c) return a + b + c end

    it("should curry a function with 0 arguments", function()
        local f = p4fn.curry(add0, 0)
        assert.equals("add0", f())
    end)

    it("should curry a function with 1 arguments", function()
        local f = p4fn.curry(add1, 1)
        assert.equals(1, f(1))
    end)

    it("should curry a function with 2 arguments", function()
        local f = p4fn.curry(add2, 2)
        assert.equals(3, f(1)(2))
    end)

    it("should curry a function with three arguments", function()
        local f = p4fn.curry(add3)
        assert.equals(6, f(1)(2)(3))
    end)

    it("should allow partial application", function()
        local f = p4fn.curry(add3)
        assert.equals(6, f(1, 2)(3))
        assert.equals(6, f(1)(2, 3))
        assert.equals(6, f(1, 2, 3))
    end)
    --
    it("should work when arity is explicitly specified", function()
        local function varargs(...)
            local sum = 0
            for _, v in ipairs({...}) do sum = sum + v end
            return sum
        end
        local f = p4fn.curry(varargs, 3)
        assert.equals(6, f(1)(2)(3))
    end)
end)

describe("p4lua.fn.const function", function()
    it("should always return the first argument", function()
        local f = p4fn.const("first")
        assert.are.equal(f("second"), "first")
        assert.are.equal(f(1), "first")
        assert.are.equal(f(nil), "first")
        assert.are.equal(f({}), "first")
    end)

    it("should works with vargs", function()
        local t = { a = 1 }
        local f = p4fn.const(t)
        assert.are.equal(f("arg1", "arg2", "arg3"), t)
    end)
end)
