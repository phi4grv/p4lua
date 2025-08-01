local adt = require("p4lua.adt")

local pub = {}

local Maybe, match = adt.defineSumType("Maybe", {
    Just = { "value" },
    Nothing = {},
})

pub.Just = Maybe.Just
pub.Nothing = Maybe.Nothing()
pub.match = match

return pub
