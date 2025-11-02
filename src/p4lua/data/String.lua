local p4fn = require("p4lua.fn")

local pub = {}

local function isEmpty(s)
    return s == nil or s == ""
end

pub.isEmpty = isEmpty

local function optPrefix(prefix, s)
    if isEmpty(s) then
        return ""
    end
    return (prefix or "") .. s
end

pub.optPrefix = optPrefix

local function optSuffix(suffix, s)
    if isEmpty(s) then
        return ""
    end
    return s .. (suffix or "")
end

pub.optSuffix = optSuffix

return pub
