local p4lua = require("p4lua")
local adt = require("p4lua.adt")
local p4fn = require("p4lua.fn")
local Array = p4lua.requireLazy("p4lua.data.Array")

local pub = {}

local Either, match = adt.defineSumType("Either", {
    Left = { "left" },
    Right = { "right" },
})

pub.Left = Either.Left
pub.Right = Either.Right
pub.match = match

pub.bind = function(e, f)
    return match({
        Left = function(_) return e end,
        Right = function(r) return f(r) end,
    }, e)
end

local function equalsWith(eql, eqr, ea, eb)
    return match({
        Left = function(al)
            return match({
                Left = function(bl) return eql(al, bl) end,
                Right = p4fn.const(false)
            }, eb)
        end,
        Right = function(ar)
            return match({
                Left = p4fn.const(false),
                Right = function(br) return eqr(ar, br) end,
            }, eb)
        end
    }, ea)
end

pub.equalsWith = p4fn.curry(4, equalsWith)
pub.equals = pub.equalsWith(p4fn.eq, p4fn.eq)
pub.equalsRightWith = pub.equalsWith(p4fn.const(false))
pub.equalsRight = pub.equalsWith(p4fn.const(false), p4fn.eq)
pub.equalsLeftWith = function(eql, ea, eb)
    return equalsWith(eql, p4fn.const(false), ea, eb)
end
pub.equalsLeft = pub.equalsLeftWith(p4fn.eq)

local function fmap(f, e)
    return match({
        Left = function(_) return e end,
        Right = function(r) return Either.Right(f(r)) end
    }, e)
end

pub.fmap = fmap

pub.fromLeft = function(v, e)
    return match({
        Left = function(l) return l end,
        Right = function(_) return v end
    }, e)
end

pub.fromRight = function(v, e)
    return match({
        Left = function(_) return v end,
        Right = function(r) return r end
    }, e)
end

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

local leftsFolder = function(acc, item)
    return match({
        Left = function(l) return Array.snoc(l, acc) end,
        Right = function(_) return acc end,
    }, item)
end

pub.pure = function(x)
    return pub.Right(x)
end

local rightsFolder = function(acc, item)
    return match({
        Left = function(_) return acc end,
        Right = function(r) return Array.snoc(r, acc) end,
    }, item)
end

pub.lefts = Array.foldl(leftsFolder, {})

pub.rights = Array.foldl(rightsFolder, {})

return pub
