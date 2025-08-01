require("p4lua.compat")

local pub = {}

pub.compose = function(...)
    local fs = {...}
    if #fs == 0 then
        return function(x) return x end
    end
    return function(...)
        local fio = ...
        for i = #fs, 1, -1 do
            fio = fs[i](fio)
        end
        return fio
    end
end

pub.compose_table = function(t)
    return pub.compose(table.unpack(t))
end

pub.const = function(x)
    return function(...)
        return x
    end
end

pub.curry = function(fn, arity)
    arity = arity or debug.getinfo(fn, "u").nparams or 1

    local function curried(argsSoFar)
        return function(...)
            -- copy previous args to avoid shared mutation
            local args = {}
            for i = 1, #argsSoFar do
                args[i] = argsSoFar[i]
            end

            -- append new args
            local newArgs = table.pack(...)
            for i = 1, newArgs.n do
                args[#args + 1] = newArgs[i]
            end

            if #args >= arity then
                return fn(table.unpack(args, 1, arity))
            else
                return curried(args)
            end
        end
    end
    return curried({})
end

pub.id = function(x) return x end

return pub
