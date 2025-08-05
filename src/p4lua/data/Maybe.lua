local adt = require("p4lua.adt")
local p4fn = require("p4lua.fn")
local Array = require("p4lua.data.Array")

local pub = {}

local Maybe, match = adt.defineSumType("Maybe", {
    Just = { "value" },
    Nothing = {},
})

pub.Just = Maybe.Just
pub.Nothing = Maybe.Nothing()
pub.match = match

pub.bind = function(m, f)
    return pub.match({
        Just = function(x) return f(x) end,
        Nothing = function() return pub.Nothing end,
    }, m)
end

pub.catMaybes = function(m)
    return Array.foldl(function(acc, a)
        return match({
            Just = function(v)
                acc[#acc + 1] = v
                return acc
            end,
            Nothing = function()
                return acc
            end
        }, a)
    end, {}, m)
end

pub.equalsWith = function(eq, ma, mb)
    if (mb == nil) then
        if (ma == nil) then
            return function(ma2, mb2)
                return pub.equalsWith(eq, ma2, mb2)
            end
        end
        return function(mb2)
            return pub.equalsWith(eq, ma, mb2)
        end
    end
    return match({
        Just = function(a)
            return match({
                Just = function(b) return eq(a, b) end,
                Nothing = p4fn.const(false)
            }, mb)
        end,
        Nothing = function()
            return match({
                Just = p4fn.const(false),
                Nothing = p4fn.const(true)
            }, mb)
        end
    }, ma)
end

pub.equals = pub.equalsWith(function(a, b) return a == b end)

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

pub.mapMaybe = function(f, arr)
    if arr == nil then
        return function(arr2)
            return pub.mapMaybe(f, arr2)
        end
    end

    return Array.foldl(function(acc, a)
        return match({
            Just = function(v)
                acc[#acc + 1] = v
                return acc
            end,
            Nothing = function()
                return acc
            end
        }, f(a))
    end, {}, arr)
end

return pub
