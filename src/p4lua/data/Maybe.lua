local p4lua = require("p4lua")
local adt = require("p4lua.adt")
local p4fn = require("p4lua.fn")
local Array = p4lua.requireLazy("p4lua.data.Array")

local pub = {}

local Maybe, match = adt.defineSumType("Maybe", {
    Just = { "value" },
    Nothing = {},
})

pub.Just = Maybe.Just
pub.Nothing = Maybe.Nothing()
pub.match = match

pub.ap = function(mf, ...)
    local margs = { ... }

    return pub.match({
        Just = function(f)
            local args = {}
            for i = 1, #margs do
                local isJust = pub.match({
                    Just = function(arg)
                        args[#args+1] = arg
                        return true
                    end,
                    Nothing = p4fn.const(false)
                }, margs[i])
                if not isJust then
                    return pub.Nothing
                end
            end
            return pub.Just(f(table.unpack(args)))
        end,
        Nothing = p4fn.const(pub.Nothing)
    }, mf)
end

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

local function equalsWith(eq, ma, mb)
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

pub.equalsWith = p4fn.curry(3, equalsWith)

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

pub.isJust = function(e)
    return match({
        Just = p4fn.const(true),
        Nothing = p4fn.const(false)
    }, e)
end

pub.isNothing = function(e)
    return match({
        Just = p4fn.const(false),
        Nothing = p4fn.const(true)
    }, e)
end

pub.mapMaybe = function(f, arr)
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

pub.pure = function(x)
    return pub.Just(x)
end

return pub
