local adt = require("p4lua.adt")

local pub = {}

local Maybe, match = adt.defineSumType("Maybe", {
    Just = { "value" },
    Nothing = {},
})

pub.Just = Maybe.Just
pub.Nothing = Maybe.Nothing()
pub.match = match

pub.fmap = function(m, f)
    return match(m, {
        Just = function(v) return pub.Just(f(v)) end,
        Nothing = function() return pub.Nothing end,
    })
end

return pub
