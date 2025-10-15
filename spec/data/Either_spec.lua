local assert = require("luassert")
local spy = require("luassert.spy")
local p4debug = require("p4lua.debug")

describe("p4lua.data.Either", function()

    local Either = require("p4lua.data.Either")

    describe("Either.match", function()

        it("Right should call right function once with correct value", function()
            local leftSpy  = spy.new(function(l) return "Left: "..l end)
            local rightSpy = spy.new(function(r) return "Right: "..r end)

            local r = Either.Right(42)
            local actual = Either.match({ Left = leftSpy, Right = rightSpy }, r)

            assert.equal("Right: 42", actual)
            assert.spy(rightSpy).was.called(1)
            assert.spy(rightSpy).was.called_with(42)
            assert.spy(leftSpy).was_not.called()
        end)

        it("Left should call left function once with correct value", function()
            local leftSpy  = spy.new(function(l) return "Left: "..l end)
            local rightSpy = spy.new(function(r) return "Right: "..r end)

            local l = Either.Left("error")
            local actual = Either.match({ Left = leftSpy, Right = rightSpy }, l)

            assert.equal("Left: error", actual)
            assert.spy(leftSpy).was.called(1)
            assert.spy(leftSpy).was.called_with("error")
            assert.spy(rightSpy).was_not.called()
        end)

    end)
end)
