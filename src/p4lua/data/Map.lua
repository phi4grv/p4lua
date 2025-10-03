local p4lua = require("p4lua")
local p4fn = require("p4lua.fn")
local Array = p4lua.requireLazy("p4lua.data.Array")
local Maybe = p4lua.requireLazy("p4lua.data.Maybe")

local pub = {}

local function copyDeep(m, seen)
    if seen[m] then
        return seen[m]
    end

    local copy = {}
    seen[m] = copy

    for k, v in pairs(m) do
        if type(v) == "table" then
            copy[k] = copyDeep(v, seen)
        else
            copy[k] = v
        end
    end

    return copy
end

pub.copyDeep = function(m)
    if type(m) ~= "table" then
        return m
    end

    return copyDeep(m, {})
end

pub.copyDeepOrId = function(arg)
    if type(arg) == "table" then
        return copyDeep(arg, {})
    end

    return arg
end

pub.copyShallow = function(m)
    if type(m) ~= "table" then
        return m
    end

    local copy = {}

    for k, v in pairs(m) do
        copy[k] = v
    end

    return copy
end

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

local function each(f, m)
    for k, v in pairs(m) do
        f(v, k, m)
    end
end

pub.each = p4fn.curry(2, each)

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

local function fromKeysAndValues(ks, vs)
    local result = {}
    local i = 1

    while(ks[i] ~= nil and vs[i] ~= nil) do
        result[ks[i]] = vs[i]
        i = i + 1
    end

    return result
end

pub.fromKeysAndValues = p4fn.curry(2, fromKeysAndValues)

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

pub.size = function(m)
    local count = 0

    for _, _ in pairs(m) do
        count = count + 1
    end

    return count
end

pub.union = function(original, override)
    local result = {}

    for k, v in pairs(original) do
        result[k] = v
    end

    for k, v in pairs(override) do
        result[k] = v
    end

    return result
end

pub.unionCopy = function(original, override)
    local result = {}

    for k, v in pairs(original) do
        if override[k] == nil then
            result[k] = pub.copyDeep(v)
        end
    end

    for k, v in pairs(override) do
        result[k] = pub.copyDeep(v)
    end

    return result
end

pub.unionCopyWith = function(f, m1, m2)
    local result = {}

    for k, v in pairs(m1) do
        if m2[k] == nil then
            result[k] = pub.copyDeep(v)
        end
    end

    for k, v in pairs(m2) do
        if m1[k] ~= nil then
            result[k] = f(m1[k], v, k)
        else
            result[k] = pub.deepCopy(v)
        end
    end

    return result
end

pub.unionWith = function(f, m1, m2)
    local result = {}

    for k, v in pairs(m1) do
        result[k] = v
    end

    for k, v in pairs(m2) do
        local v1 = result[k]
        if v1 ~= nil then
            result[k] = f(v1, v, k)
        else
            result[k] = v
        end
    end

    return result
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
