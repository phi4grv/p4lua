local adt = require("p4lua.adt")

local pub = {}

local Maybe, match = adt.defineSumType("Maybe", {
    Just = { "value" },
    Nothing = {},
})

pub.Just = Maybe.Just
pub.Nothing = Maybe.Nothing()
pub.match = match

pub.fmap = function(f, m)
    return match({
        Just = function(v) return pub.Just(f(v)) end,
        Nothing = function() return pub.Nothing end,
    }, m)
end

pub.fromMaybe = function(default, m)
    return match({
        Just = function(v) return v end,
        Nothing = function() return default end,
    }, m)
end

pub.bind = function(m, f)
    return pub.match({
        Just = function(x) return f(x) end,
        Nothing = function() return pub.Nothing end,
    }, m)
end

return pub
