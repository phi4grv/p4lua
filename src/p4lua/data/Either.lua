local adt = require("p4lua.adt")

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

return pub
