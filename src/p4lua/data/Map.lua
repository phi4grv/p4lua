local p4lua = require("p4lua")
local p4fn = require("p4lua.fn")
local Array = p4lua.requireLazy("p4lua.data.Array")
local Maybe = p4lua.requireLazy("p4lua.data.Maybe")

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

local function deepCopy(m)
    local copy = {}

    for k, v in pairs(m) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end

    return copy
end

pub.deepCopy = function(m)
    if type(m) ~= "table" then
        return m
    end

    return deepCopy(m)
end

pub.deepCopyOrId = function(arg)
    if type(arg) == "table" then
        return deepCopy(arg)
    end

    return arg
end

pub.empty = function()
    return {}
end

local function equalsWith(eq, m1, m2)
    if m1 == m2 then
        return true
    end
    if type(m1) ~= "table" or type(m2) ~= "table" then
        return false
    end

    local count = 0

    for k, v1 in pairs(m1) do
        local v2 = m2[k]
        if not eq(v1, v2) then
            return false
        end
        count = count + 1
    end

    return count == pub.size(m2)
end

pub.equalsWith = p4fn.curry(3, equalsWith)

pub.equals = pub.equalsWith(function(v1, v2) return v1 == v2 end)

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

pub.keys = function(m)
    local result = {}

    for k, _ in pairs(m) do
        table.insert(result, k)
    end

    return result
end

pub.lookup = p4fn.curry(2, lookup)

pub.shallowCopy = function(m)
    local copy = {}

    for k, v in pairs(m) do
        copy[k] = v
    end

    return copy
end

pub.size = function(m)
    local count = 0

    for _, _ in pairs(m) do
        count = count + 1
    end

    return count
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
