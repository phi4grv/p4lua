local assert = require("luassert")

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
        name = "p4lua.fn.composeArray",
        apply = function(...) return p4fn.composeArray({ ... }) end
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

describe("pub.composeArray", function()

    it("throws error if input is not a table", function()
        assert.has_error(function()
            p4fn.composeArray(nil)
        end, "bad argument #1 to 'composeArray' (table expected, got nil)")

        assert.has_error(function()
            p4fn.composeArray(123)
        end, "bad argument #1 to 'composeArray' (table expected, got number)")

        assert.has_error(function()
            p4fn.composeArray("not a table")
        end, "bad argument #1 to 'composeArray' (table expected, got string)")
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

    it("should work when arity is explicitly specified", function()
        local function varargs(...)
            local sum = 0
            for _, v in ipairs({...}) do sum = sum + v end
            return sum
        end
        local f = p4fn.curry(varargs, 3)
        assert.equals(6, f(1)(2)(3))
    end)

    it("should not share args between curried functions", function()
        local f = p4fn.curry(add2, 2)

        local add1 = f(1)
        assert.same(3, add1(2))  -- OK: 1 + 2 = 3

        -- Problem: if `add1` shares `args` internally, the next result won't be 4
        assert.same(4, add1(3))  -- Expected: 1 + 3 = 4
        -- If implemented incorrectly, this might become 1 + 2 + 3 = 6 (which is wrong)
    end)

end)

describe("p4lua.fn.flip", function()

    it("flips arguments of a normal two-argument function", function()
        local function f(a, b) return a - b end
        local flipped = p4fn.flip(f)
        assert.are.equal(flipped(5, 3), -2)
    end)

    it("works with 3 arguments", function()
        local function f(a, b, c) return a - b + c end
        local flipped = p4fn.flip(f)
        assert.are.equal(flipped(5, 3, 1), -1)
    end)

    it("works with curried function", function()
        local function f(a, b) return a - b end
        local curried = p4fn.curry(f)
        local flipped = p4fn.flip(curried)

        assert.are.equal(flipped(5)(3), -2)
    end)

    it("works with curried function with 3 arguments", function()
        local function f(a, b, c) return a - b + c end
        local curried = p4fn.curry(f)
        local flipped = p4fn.flip(curried)
        assert.are.equal(flipped(5, 3, 1), -1)
        assert.are.equal(flipped(5)(3)(1), -1)
    end)

    it("returns itself when called with no arguments (acts like id)", function()
        local function f(a, b) return a .. b end
        local flipped = p4fn.flip(f)

        -- When called with no arguments, it should return itself (like an identity function)
        local again = flipped()
        assert.are.equal(type(again), "function")

        -- The returned function should still work correctly when given arguments
        assert.are.equal(again("world", "hello "), "hello world")
    end)
end)

describe("p4lua.fn.id function", function()

    it("returns the input value unchanged", function()
        assert.are.equal(5, p4fn.id(5))
        assert.are.equal("hello", p4fn.id("hello"))
        assert.are.equal(true, p4fn.id(true))

        local tbl = { a = 1 }
        assert.are.same(tbl, p4fn.id(tbl))
    end)

end)
