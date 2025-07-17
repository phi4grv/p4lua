package = "p4lua"
version = "0.1-1"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
dependencies = {
   "lua >= 5.1, < 5.5",
   queries = {
      {
         constraints = {
            {
               op = ">=",
               version = {
                  5, 1, string = "5.1"
               }
            },
            {
               op = "<",
               version = {
                  5, 5, string = "5.5"
               }
            }
         },
         name = "lua"
      }
   }
}
build_dependencies = {
   queries = {}
}
build = {
   type = "builtin",
   modules = {}
}
test_dependencies = {
   queries = {}
}
