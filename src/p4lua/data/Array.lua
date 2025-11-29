local p4lua = require("p4lua")
local p4fn = require("p4lua.fn")
local Map = p4lua.requireLazy("p4lua.data.Map")
local Maybe = p4lua.requireLazy("p4lua.data.Maybe")

local pub = {}

pub.ap = function(...)
    local prod = pub.product(...)

    return pub.fmap(function(c)
        local f = c[1]
        return f(table.unpack(c, 2))
    end, prod)
end

local function at(i, arr)
    local idx = 1

    while(arr[idx] ~= nil) do
        if (idx == i) then
            return Maybe.Just(arr[i])
        end
        idx = idx + 1
    end

    return Maybe.Nothing
end

pub.at = p4fn.curry(2, at)

pub.bind = function(arr, f)
    local result = {}

    pub.each(function(a)
        local rs = f(a)
        assert(type(rs) == "table", "Array.bind: function must return Array")
        pub.each(function(r)
            table.insert(result, r)
        end, rs)
    end, arr)

    return result
end

pub.concat = function(...)
    local result = {}

    for _, arg in ipairs({ ... }) do
        local i = 1
        while arg[i] ~= nil do
            table.insert(result, arg[i])
            i = i + 1
        end
    end

    return result
end

local function cons(v, arr)
    local result = { v }
    local i = 1

    while(arr[i] ~= nil) do
        result[i + 1] = arr[i]
        i = i + 1
    end

    return result
end

pub.cons = p4fn.curry(2, cons)

local function copyDeep(arr, seen)
    if seen[arr] then
        return seen[arr]
    end

    local i = 1
    local result = {}

    seen[arr] = result

    while arr[i] ~= nil do
        if type(arr[i]) == "table" then
            result[i] = copyDeep(arr[i], seen)
        else
            result[i] = arr[i]
        end
        i = i + 1
    end

    return result
end

pub.copyDeep = function(arr)
    if type(arr) ~= "table" then
        return arr
    end

    return copyDeep(arr, {})
end

pub.copyShallow = function(arr)
    local result = {}
    local i = 1

    while arr[i] ~= nil do
        result[i] = arr[i]
        i = i + 1
    end

    return result
end

local function each(f, arr)
    local i = 1

    while arr[i] ~= nil do
        f(arr[i], i, arr)
        i = i + 1
    end
end

pub.each = p4fn.curry(2, each)

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

function filter(pred, arr)
    local result = {}
    local i = 1

    while(arr[i] ~= nil) do
        if pred(arr[i], i) then
            table.insert(result, arr[i])
        end
        i = i + 1
    end

    return result
end

pub.filter = p4fn.curry(2, filter)

local function fmap(f, arr)
    local result = {}
    local i = 1

    while arr[i] ~= nil do
        result[i] = f(arr[i])
        i = i + 1
    end

    return result
end

pub.fmap = p4fn.curry(2, fmap)

local function foldl(ff, acc, arr)
    local i = 1

    while arr[i] ~= nil do
        acc = ff(acc, arr[i])
        i = i + 1
    end

    return acc
end

pub.foldl = p4fn.curry({ p4fn.id, Map.copyDeepOrId }, foldl)

local function foldr(ff, acc, arr)
    local len = pub.length(arr)

    for i = len, 1, -1 do
        acc = ff(arr[i], acc)
    end

    return acc
end

pub.foldr = p4fn.curry({ p4fn.id, Map.copyDeepOrId }, foldr)

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

local function groupBy(keyf, arr)
    local result = {}
    local idx = 1

    while(arr[idx] ~= nil) do
        local key = keyf(arr[idx])
        result[key] = result[key] or {}
        table.insert(result[key], arr[idx])
        idx = idx + 1
    end

    return result
end

pub.groupBy = p4fn.curry(2, groupBy)

local function insert(i, v, arr)
    local result = {}
    local idx = 1

    if (i < 1) then
        i = 1
    end

    while(arr[idx] ~= nil and idx < i) do
        result[idx] = arr[idx]
        idx = idx + 1
    end

    result[idx] = v
    if (i < idx) then
        return result
    end

    while(arr[idx] ~= nil) do
        result[idx+1] = arr[idx]
        idx = idx + 1
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

pub.product = function(xs, ...)
    if select("#", ...) == 0 then
        assert(xs ~= nil, "Array.product require parameter")
        return pub.fmap(pub.pure, xs)
    end

    local subprod = pub.product(...)

    return pub.bind(xs, function(x)
        return pub.fmap(pub.cons(x), subprod)
    end)
end

pub.pure = function(x)
    return { x }
end

local function sequence(Applicative, arr)
    local f = function(...)
        return { ... }
    end

    local mf = Applicative.pure(f)

    return Applicative.ap(mf, table.unpack(arr))
end

pub.sequence = p4fn.curry(2, sequence)

local function snoc(v, arr)
    local result = {}
    local i = 1

    while(arr[i] ~= nil) do
        result[i] = arr[i]
        i = i + 1
    end
    result[i] = v

    return result
end

pub.snoc = p4fn.curry(2, snoc)

pub.vpairs = function(arr)
    local i = 0

    return function(_)
        i = i + 1
        if arr[i] == nil then
            return nil
        end
        return arr[i], i
    end
end

pub.zip = function(...)
    local args = { ... }
    local result = {}
    local idx = 1

    for i = 1, #args do
        if (type(args[i]) ~= "table") then
            error("zip: arg#" .. i .." must be table, got " .. type(args[1]))
        end
    end

    while true do
        local z = {}
        for i = 1, #args do
            if (args[i][idx] == nil) then
                return result
            end
            table.insert(z, args[i][idx])
        end
        table.insert(result, z)
        idx = idx + 1
    end
end

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
