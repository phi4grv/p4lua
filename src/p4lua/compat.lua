local pub = { }

pub.lua_version = _VERSION:match("%d+%.%d+")
pub.table = require("p4lua.compat.table")

return pub
