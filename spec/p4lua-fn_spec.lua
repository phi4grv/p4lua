local p4fn = require("p4lua.fn")

describe("p4lua.fn.compose", function()
    local add1 = function(x) return x + 1 end
    local mul2 = function(x) return x * 2 end
    local square = function(x) return x ^ 2 end

    it("should compose two functions", function()
        local f = p4fn.compose(mul2, add1)
        assert.equals(4, f(1))
    end)

    it("should compose three functions", function()
        local f = p4fn.compose(square, mul2, add1)
        assert.equals(16, f(1))
    end)

    it("returns identity when no functions given", function()
        local f = p4fn.compose()
        assert.equals("identity", f("identity"))
    end)

    it("works with single function", function()
        local f = p4fn.compose(add1)
        assert.equals(2, f(1))
    end)
end)
