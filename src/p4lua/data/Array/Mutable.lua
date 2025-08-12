local p4fn = require("p4lua.fn")
local Array = require("p4lua.data.Array")

local pub = {}

local function appendInto(src, dest)
    local srcLen = Array.length(src)
    local destLen = Array.length(dest)

    table.move(src, 1, srcLen, destLen + 1, dest)

    if (dest[srcLen + destLen + 1] ~= nil) then
        dest[srcLen + destLen + 1] = nil
    end

    return dest
end

pub.appendInto = p4fn.curry(2, appendInto)

local function cons(v, arr)
    table.insert(arr, 1, v)

    return arr
end

pub.cons = p4fn.curry(2, cons)

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

    table.insert(arr, pos, v)

    return arr
end

pub.insert = p4fn.curry(3, insert)

local function prependInto(src, dest)
    local srcLen = Array.length(src)
    local destLen = Array.length(dest)

    table.move(dest, 1, destLen, srcLen + 1, dest)
    table.move(src, 1, srcLen, 1, dest)

    if dest[srcLen + destLen + 1] ~= nil then
        dest[srcLen + destLen + 1] = nil
    end

    return dest
end

pub.prependInto = p4fn.curry(2, prependInto)

local function snoc(v, arr)
    table.insert(arr, v)

    return arr
end

pub.snoc = p4fn.curry(2, snoc)

return pub
