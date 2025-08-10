local inspect = require("inspect")
local p4fn = require("p4lua.fn")
local Array = require("p4lua.data.Array")

local pub = {}

pub.inspect = inspect

pub.print = p4fn.compose(print, table.unpack, Array.fmap(inspect), Array.fromVargs)

return pub
