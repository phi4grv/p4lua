local Map = require("p4lua.data.Map")
local Array = require("p4lua.data.Array")

local pub = {}

pub.require = function(mod, ks)
    local m = require(mod)
    if not Array.isEmpty(ks) then
        return table.unpack(Map.valuesByKeys(m, ks))
    end
    return m
end

return pub
