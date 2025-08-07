local assert = require("luassert")

describe("p4lua.fn", function()

    local p4fn = require("p4lua.fn")

    describe("p4lua.fn.compose and p4lua.fn.composeArray", function()

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
                    assert.equal(4, f(1))
                end)

                it("should compose three functions", function()
                    local f = case.apply(square, mul2, add1)
                    assert.equal(16, f(1))
                end)

                it("returns identity when no functions given", function()
                    local f = case.apply()
                    assert.equal("identity", f("identity"))
                end)

                it("works with single function", function()
                    local f = case.apply(add1)
                    assert.equal(2, f(1))
                end)

            end)
        end
    end)

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

    describe("p4lua.fn.chain", function()

        it("applies a single function to a value", function()
            local f = function(x) return x + 1 end
            local result = p4fn.chain({ f }, 1)
            assert.equal(2, result)
        end)

        it("applies multiple functions from left to right", function()
            local f1 = function(x) return x + 2 end
            local f2 = function(x) return x * 3 end
            local f3 = function(x) return x - 5 end

            -- f3(f2(f1(4))) = f3(f2(6)) = f3(18) = 13
            local result = p4fn.chain({ f1, f2, f3 }, 4)
            assert.equal(13, result)
        end)

        it("returns the value unchanged if no functions are given", function()
            local result = p4fn.chain({}, 42)
            assert.equal(42, result)
        end)

        it("is curried: chain(fns)(x)", function()
            local f1 = function(x) return x + 1 end
            local f2 = function(x) return x * 2 end

            local curried = p4fn.chain({ f1, f2 })
            local result = curried(3)
            assert.equal(8, result)
        end)

    end)

    describe("p4lua.fn.const function", function()

        it("should always return the first argument", function()
            local f = p4fn.const("first")
            assert.equal(f("second"), "first")
            assert.equal(f(1), "first")
            assert.equal(f(nil), "first")
            assert.equal(f({}), "first")
        end)

        it("should works with vargs", function()
            local t = { a = 1 }
            local f = p4fn.const(t)
            assert.equal(f("arg1", "arg2", "arg3"), t)
        end)

    end)

    describe("p4lua.fn.curry", function()

        local function f1(a) return a end
        local function f2(a, b) return a + b end
        local function f3(a, b, c) return a + b + c end

        it("should curry a function with 1 arguments", function()
            local f = p4fn.curry(1, f1)
            assert.equal(1, f(1))
        end)

        it("should curry a function with 2 arguments", function()
            local f = p4fn.curry(2, f2)
            assert.equal(3, f(1)(2))
        end)

        it("should curry a function with three arguments", function()
            local f = p4fn.curry(3, f3)
            assert.equal(6, f(1)(2)(3))
            assert.equal(6, f(1)(2, 3))
            assert.equal(6, f(1, 2)(3))
        end)

        it("should not share args between curried functions", function()
            local f = p4fn.curry(2, f2)

            local add1 = f(1)
            assert.same(3, add1(2))  -- OK: 1 + 2 = 3

            -- Problem: if `add1` shares `args` internally, the next result won't be 4
            assert.same(4, add1(3))  -- Expected: 1 + 3 = 4
            -- If implemented incorrectly, this might become 1 + 2 + 3 = 6 (which is wrong)
        end)

        it("throws error when arity is 0", function()
            assert.error_matches(function()
                p4fn.curry(0, f1)
            end, "curry: arg#1 must be positive integer, got 0")
        end)

        it("throws error when curried function is called with no arguments", function()
            local curried = p4fn.curry(2, f2)
            assert.error_matches(function()
                curried()
            end, "curried function: at least one argument required")
        end)

    end)

    describe("p4lua.fn.flip", function()

        it("flips arguments of a normal two-argument function", function()
            local function f(a, b) return a - b end
            local flipped = p4fn.flip(f)

            assert.equal(flipped(5, 3), -2)
        end)

        it("works with 3 arguments", function()
            local function f(a, b, c) return a - b + c end
            local flipped = p4fn.flip(f)

            assert.equal(flipped(5, 3, 1), -1)
        end)

        it("works with curried function", function()
            local function f(a, b) return a - b end
            local curried = p4fn.curry(2, f)
            local flipped = p4fn.flip(curried)

            assert.equal(flipped(5)(3), -2)
        end)

        it("works with curried function with 3 arguments", function()
            local function f(a, b, c) return a - b + c end
            local curried = p4fn.curry(3, f)
            local flipped = p4fn.flip(curried)

            assert.equal(flipped(5, 3, 1), -1)
            assert.equal(flipped(5)(3)(1), -1)
            assert.equal(flipped(5)(3, 1), -1)
            assert.equal(flipped(5, 3)(1), -1)
        end)

    end)

    describe("p4lua.fn.id function", function()

        it("returns the input value unchanged", function()
            assert.equal(5, p4fn.id(5))
            assert.equal("hello", p4fn.id("hello"))
            assert.equal(true, p4fn.id(true))

            local tbl = { a = 1 }
            assert.equal(tbl, p4fn.id(tbl))
        end)

    end)
end)
