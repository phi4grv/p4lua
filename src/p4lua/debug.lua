local inspect = require("inspect")
local Array = require("p4lua.data.Array")

local pub = {}

pub.inspect = inspect

pub.print = function(...)
    local args = { ... }
    local inspected = Array.fmap(pub.inspect, args)

    ---@cast inspected string[]
    print(table.unpack(inspected))
end

return pub
