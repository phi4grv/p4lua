local p4fn = require("p4lua.fn")

local pub = {}

local function at(i, arr)
    if i >= 1 and i <= #arr then
        return require("p4lua.data.Maybe").Just(arr[i])
    else
        return require("p4lua.data.Maybe").Nothing
    end
end

pub.at = p4fn.curry(2, at)

local function concat(arr1, arr2)
    local result, len = pub.fromTableWithLength(arr1)

    table.move(arr2, 1, pub.length(arr2), len + 1, result)

    return result
end

pub.concat = p4fn.curry(2, concat)

local function cons(v, arr)
    local result = { v }
    for i = 1, #arr do
        result[i + 1] = arr[i]
    end
    return result
end

pub.cons = p4fn.curry(2, cons)

local function equalsWith(eq, arr1, arr2)
    local i = 1

    while true do
        local v1 = arr1[i]
        local v2 = arr2[i]

        if v1 == nil then
            if v2 == nil then
                return true
            end
            return false
        end
        if (v2 == nil) then
            return false
        end

        if not eq(v1, v2) then
            return false
        end

        i = i + 1
    end
end

pub.equalsWith = p4fn.curry(3, equalsWith)

pub.equals = pub.equalsWith(function(a, b) return a == b end)

local function fmap(f, arr)
    if (arr == nil) then
        return function(arr2)
            return pub.fmap(f, arr2)
        end
    end

    local result = {}
    for i = 1, #arr do
        result[i] = f(arr[i])
    end
    return result
end

pub.fmap = p4fn.curry(2, fmap)

local function foldl(ff, acc, arr)
    local result = acc
    for i = 1, #arr do
        result = ff(result, arr[i])
    end
    return result
end

pub.foldl = p4fn.curry(3, foldl)

local function foldr(ff, acc, arr)
    local result = acc
    for i = #arr, 1, -1 do
        result = ff(arr[i], result)
    end
    return result
end

pub.foldr = p4fn.curry(3, foldr)

local function insert(i, v, arr)
    local n = #arr
    local pos
    if i < 1 then
        pos = 1
    elseif i > n + 1 then
        pos = n + 1
    else
        pos = i
    end

    local result = {}
    for j = 1, pos - 1 do
        result[j] = arr[j]
    end

    result[pos] = v

    for j = pos, n do
        result[j + 1] = arr[j]
    end

    return result
end

pub.fromTable = function(arr)
    return select(1, pub.fromTableWithLength(arr))
end

pub.fromTableWithLength = function(arr)
    local result = {}
    local i = 1

    while arr[i] ~= nil do
        result[i] = arr[i]
        i = i + 1
    end
    return result, i - 1
end

pub.fromVargs = function(...)
    local result = {}
    local i = 1

    while true do
        local v = select(i, ...)
        if v == nil then
            break
        end
        result[i] = v
        i = i + 1
    end
    return result
end

pub.insert = p4fn.curry(3, insert)

pub.isEmpty = function(arr)
    return type(arr) ~= "table" or arr[1] == nil
end

pub.length = function(arr)
    local i = 1
    while arr[i] ~= nil do
        i = i + 1
    end
    return i - 1
end

local function snoc(v, arr)
    local result = {}
    for i = 1, #arr do
        result[i] = arr[i]
    end
    result[#arr + 1] = v
    return result
end

pub.snoc = p4fn.curry(2, snoc)

pub.zipWith = function(fs, ...)
    local args = { ... }
    local result = {}
    local i = 1

    while true do
        local f = fs[i]
        if not f then break end

        local argList = {}
        local anyNil = false

        for _, arr in ipairs(args) do
            local v = arr[i]
            if v == nil then anyNil = true break end
            table.insert(argList, v)
        end

        if anyNil then break end

        result[i] = f(table.unpack(argList))
        i = i + 1
    end

    return result
end

return pub
