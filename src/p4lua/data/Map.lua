local p4fn = require("p4lua.fn")
local Array = require("p4lua.data.Array")
local Maybe = require("p4lua.data.Maybe")

local pub = {}

local function delete(k, m)
    local result = {}
    for key, value in pairs(m) do
        if key ~= k then
            result[key] = value
        end
    end
    return result
end

pub.delete = p4fn.curry(2, delete)

pub.empty = function()
    return {}
end

local function fold(f, acc, map)
    for k, v in pairs(map) do
        acc = f(acc, k, v)
    end
    return acc
end

pub.fold = p4fn.curry(3, fold)

local function filterByKeys(ks, m)
    local result = {}
    for _, k in ipairs(ks) do
        if m[k] then
            result[k] = m[k]
        end
    end
    return result
end

pub.filterByKeys = p4fn.curry(2, filterByKeys)

local function insert(k, v, m)
    local newMap = {}
    for key, val in pairs(m) do
        newMap[key] = val
    end
    newMap[k] = v

    return newMap
end

pub.insert = p4fn.curry(3, insert)

local function lookup(k, m)
    local v = m[k]
    if v == nil then
        return Maybe.Nothing
    else
        return Maybe.Just(v)
    end
end

pub.lookup = p4fn.curry(2, lookup)

pub.shallowCopy = function(m)
    local copy = {}

    for k, v in pairs(m) do
        copy[k] = v
    end

    return copy
end

pub.values = function(m)
    local result = {}
    for _, v in pairs(m) do
        if v ~= nil then
            table.insert(result, v)
        end
    end
    return result
end

-- valuesByKeys :: Map k v -> [k] -> [Maybe v]
local function valuesByKeys(ks, m)
    return Array.fmap(function(k)
        return pub.lookup(k, m)
    end, ks)
end

pub.valuesByKeys = p4fn.curry(2, valuesByKeys)

return pub
