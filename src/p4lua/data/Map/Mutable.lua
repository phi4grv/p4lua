local p4fn = require("p4lua.fn")

local pub = {}

local function delete(k, m)
    m[k] = nil

    return m
end

pub.delete = p4fn.curry(2, delete)

local function insert(k, v, m)
    m[k] = v

    return m
end

pub.insert = p4fn.curry(3, insert)

return pub
