local pub = {}

pub.makeChainBind = function(bind)
    local function chainBind(fs, m)
        if m == nil then
            return function(actualM)
                return chainBind(fs, actualM)
            end
        end

        if (type(fs) ~= "table") then
            fs = { fs } -- wrap single function or nil as a table
        end

        local result = m
        for _, f in ipairs(fs) do
            result = bind(result, f)
        end
        return result
    end

    return chainBind
end

local function kleisliCompose(bind, f, g)
    return function(x)
        return bind(f(x), g)
    end
end

pub.makeKleisliCompose = function(bind, unit)
    local composeArray = pub.makeKleisliComposeArray(bind, unit)
    return function(...)
        return composeArray({...})
    end
end

pub.makeKleisliComposeArray = function(bind, unit)
    return function(fs)
        if type(fs) ~= "table" then
            error(("bad argument #1 to 'makeKleisliComposeArray' (table expected, got %s)"):format(type(fs)))
        end

        local n = #fs
        if n == 0 then
            return unit
        elseif n == 1 then
            return fs[1]
        end

        local composed = fs[1]
        for i = 2, n do
            composed = kleisliCompose(bind, composed, fs[i])
        end
        return composed
    end
end

return pub
