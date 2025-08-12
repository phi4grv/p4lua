local p4lua = require("p4lua")
local Array = p4lua.requireLazy("p4lua.data.Array")

local pub = {}

pub.id = function(x) return x end

pub.curry = function(arityOrHandlers, f)
    local arity
    local argHandlers

    if type(arityOrHandlers) == "number" then
        arity = arityOrHandlers
        if (arity <= 0) then
            error(("curry: arg#1 must be positive integer, got %s"):format(tostring(arity)))
        end
        argHandlers = {}
        for i = 1, arity - 1 do
            argHandlers[i] = pub.id
        end
    elseif type(arityOrHandlers) == "table" then
        argHandlers = arityOrHandlers
        arity = #argHandlers + 1
    else
        error(("curry: arg#1 must be number or table, got %s"):format(type(arityOrHandlers)))
    end

    local function curried(...)
        local cargs = { ... }
        if (#cargs >= arity) then
            return f(...)
        end
        if (#cargs == 0) then
            error("curried function: at least one argument required")
        end

        return function(...)
            local args = { ... }
            local nargs = Array.zipWith(argHandlers, cargs)
            table.move(args, 1, #args, #nargs + 1, nargs)
            return curried(table.unpack(nargs))
        end
    end

    return curried
end

function chain(fs, x)
    if type(fs) ~= "table" then
        error("chain expects a list of functions")
    end

    local result = x

    for _, f in ipairs(fs) do
        result = f(result)
    end

    return result
end

pub.chain = pub.curry(2, chain)

local function composeArray(fs)
    local len = Array.length(fs)

    if len == 0 then
        return pub.id
    end

    return function(...)
        local result = table.pack(...)
        for i = len, 1, -1 do
            result = table.pack(fs[i](table.unpack(result, 1, result.n)))
        end
        return table.unpack(result, 1, result.n)
    end
end

pub.compose = function(...)
    local fs = { ... }

    return composeArray(fs)
end

pub.composeArray = function(fs)
    if type(fs) ~= "table" then
        error(("bad argument #1 to 'composeArray' (table expected, got %s)"):format(type(fs)))
    end

    return composeArray(fs)
end

pub.const = function(x)
    return function(_)
        return x
    end
end

pub.flip =  function(f)
    local flipped = function(a, b, ...)
        return f(b, a, ...)
    end

    return pub.curry(2, flipped)
end

return pub
