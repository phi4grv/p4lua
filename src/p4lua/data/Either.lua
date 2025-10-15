local adt = require("p4lua.adt")

local pub = {}

local Either, match = adt.defineSumType("Either", {
    Left = { "left" },
    Right = { "right" },
})

pub.Left = Either.Left
pub.Right = Either.Right
pub.match = match

return pub
