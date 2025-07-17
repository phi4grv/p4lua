local p4debug = require("p4lua.debug")
local inspect = require("inspect")

describe("p4lua.debug.inspect", function()
  it("should be the same function as inspect", function()
    assert.is_true(p4debug.inspect == inspect)
  end)
end)
