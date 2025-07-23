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
