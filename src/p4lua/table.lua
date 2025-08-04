local pub = {}

local readOnlyNewindex = function(_, key)
    error("Attempt to modify readonly field '" .. tostring(key) .. "'")
end

pub.makeReadOnly = function(t)
    if type(t) ~= "table" then
        error("makeReadOnly expects a table, got " .. type(t))
    end

    return setmetatable({}, {
        __index = t,
        __newindex = readOnlyNewindex,
        __metatable = false,  -- Protect the metatable from being accessed or changed
    })
end

return pub
