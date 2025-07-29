rockspec_format = "3.0"
package = "p4lua"
version = "0.1-1"
source = {
   url = "git+https://github.com/phi4grv/p4lua.git"
}
description = {
   homepage = "https://github.com/phi4grv/p4lua",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1, < 5.5",
}
build_dependencies = {
   "inspect >= 3.1.0"
}
build = {
   type = "builtin",
   modules = {
      ["p4lua"] = "src/p4lua/init.lua",
      ["p4lua.adt"] = "src/p4lua/adt.lua",
      ["p4lua.compat"] = "src/p4lua/compat.lua",
      ["p4lua.data.Array"] = "src/p4lua/data/Array.lua",
      ["p4lua.data.Map"] = "src/p4lua/data/Map.lua",
      ["p4lua.debug"] = "src/p4lua/debug.lua",
      ["p4lua.fn"] = "src/p4lua/fn.lua",
   }
}
test_dependencies = {
   "busted >= 2.2.0",
}
test = {
   type = "busted",
}
