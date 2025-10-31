local adt = require("p4lua.adt")
local p4fn = require("p4lua.fn")

local pub = {}

local Either, match = adt.defineSumType("Either", {
    Left = { "left" },
    Right = { "right" },
})

pub.Left = Either.Left
pub.Right = Either.Right
pub.match = match

pub.bind = function(e, f)
    return pub.match({
        Left = function(_) return e end,
        Right = function(r) return f(r) end,
    }, e)
end

local function fmap(f, e)
    return match({
        Left = function(_) return e end,
        Right = function(r) return Either.Right(f(r)) end
    }, e)
end

pub.fmap = fmap

pub.isLeft = function(e)
    return match({
        Left = p4fn.const(true),
        Right = p4fn.const(false)
    }, e)
end

pub.isRight = function(e)
    return match({
        Left = p4fn.const(false),
        Right = p4fn.const(true)
    }, e)
end

return pub
