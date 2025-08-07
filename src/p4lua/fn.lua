require("p4lua.compat.table")

local pub = {}

pub.chain = function(fs, x)
    if x == nil then
        return function(actualX)
            return pub.chain(fs, actualX)
        end
    end

    if type(fs) ~= "table" then
        error("chain expects a list of functions")
    end

    local result = x
    for _, f in ipairs(fs) do
        result = f(result)
    end
    return result
end

pub.compose = function(...)
    local fs = {...}
    return pub.composeArray(fs)
end

pub.composeArray = function(fs)
    if type(fs) ~= "table" then
        error(("bad argument #1 to 'composeArray' (table expected, got %s)"):format(type(fs)))
    end

    if #fs == 0 then
        return pub.id
    end
    return function(...)
        local fio = ...
        for i = #fs, 1, -1 do
            fio = fs[i](fio)
        end
        return fio
    end
end

pub.const = function(x)
    return function(...)
        return x
    end
end

pub.curry = function(arity, f)
    if (arity <= 0) then
        error(("curry: arg#1 must be positive integer, got %s"):format(tostring(arity)))
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
            local nargs = { table.unpack(cargs) }
            table.move(args, 1, #args, #nargs + 1, nargs)
            return curried(table.unpack(nargs))
        end
    end

    return curried
end

pub.flip = function(f)
    return function(a, b, ...)
        if (a == nil) then
            return pub.flip(f)
        end
        if (b == nil) then
            return function(b2, ...)
                return f(b2, a, ...)
            end
        end
        return f(b, a, ...)
    end
end

pub.id = function(x) return x end

return pub
