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
   "inspect >= 3.1.0",
   "p4lua_rust >= 0.1",
}
build = {
   type = "builtin",
   modules = {
      ["p4lua.debug"] = "src/p4lua/debug.lua",
      ["p4lua.hash"] = "src/p4lua/hash.lua",
   }
}
test_dependencies = {
   "busted >= 2.2.0",
}
test = {
   type = "busted",
}
