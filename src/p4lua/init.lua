require("p4lua.compat")

local pub = {}

pub.require = function(mod, ks)
    local m = require(mod)

    if not ks then
        return m
    end

    local result = {}
    for i, k in ipairs(ks) do
        result[i] = m[k] -- include nil
    end
    return table.unpack(result, 1, #ks)
end

return pub
