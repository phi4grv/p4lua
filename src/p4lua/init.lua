require("p4lua.compat.table")

local pub = {}

pub.require = function(mod, ks)
    local m = require(mod)

    if not ks then
        return m
    end

    local result = {}

    for i, k in ipairs(ks) do
        result[i] = m[k] -- include nil
    end

    return table.unpack(result, 1, #ks)
end

local lazyCache = {}

pub.requireLazy = function(modName)
    if lazyCache[modName] then
        return lazyCache[modName]
    end

    local loadedMod = nil
    local proxy = setmetatable({}, {
        __index = function(t, key)
            if not loadedMod then
                loadedMod = require(modName)
            end
            local val = loadedMod[key]
            rawset(t, key, val)  -- Cache the loaded value
            return val
        end,
        __newindex = function(t, key, value)
            if not loadedMod then
                loadedMod = require(modName)
            end
            loadedMod[key] = value
            rawset(t, key, value)  -- Cache the new value
        end,
    })

    lazyCache[modName] = proxy

    return proxy
end

return pub
