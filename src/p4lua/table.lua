local pub = {}

local sealNewindex = function(_, key)
    error("Attempt to modify readonly field '" .. tostring(key) .. "'")
end

--- Makes a table immutable and prevents iteration.
--- @param t table The table to seal.
--- @return table A sealed proxy table.
pub.seal = function(t)
    if type(t) ~= "table" then
        error("p4lua.table.seal expects a table, got " .. type(t))
    end

    return setmetatable({}, {
        __index = t,
        __newindex = sealNewindex,
        __metatable = false,  -- Protect the metatable from being accessed or changed
    })
end

return pub
