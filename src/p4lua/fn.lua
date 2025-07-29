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
    local function curried(...)
        local args = table.pack(...)
        if args.n >= arity then
            return fn(table.unpack(args))
        end
        return function(...)
            for _, v in ipairs(table.pack(...)) do
                table.insert(args, v)
            end
            return curried(table.unpack(args))
        end
    end
    return curried
end

pub.id = function(x) return x end

return pub
