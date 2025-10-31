local assert = require("luassert")
local spy = require("luassert.spy")

describe("p4lua.data.Either", function()

    local Either = require("p4lua.data.Either")

    describe("Either.bind", function()

        it("Right should apply function and return new Right", function()
            local f = function(v) return Either.Right(v * 2) end
            local r = Either.Right(10)

            local actual = Either.bind(r, f)

            assert.same(Either.Right(20), actual)
        end)

        it("Left should not apply function and return original Left", function()
            local f = spy.new(function() end)
            local l = Either.Left("left")

            local actual = Either.bind(l, f)

            assert.spy(f).was_not.called()
            assert.same(Either.Left("left"), actual)
        end)

        it("bind chain works with multiple Rights", function()
            local r1 = Either.Right(5)
            local r2 = Either.bind(r1, function(v) return Either.Right(v + 3) end)
            local r3 = Either.bind(r2, function(v) return Either.Right(v * 2) end)

            assert.same(Either.Right(16), r3)
        end)

        it("bind short-circuits on Left", function()
            local r1 = Either.Right(5)
            local r2 = Either.bind(r1, function(v) return Either.Left("fail") end)
            local r3 = Either.bind(r2, function(v) return Either.Right(v * 2) end)

            assert.same(Either.Left("fail"), r3)
        end)

    end)

    describe("Either.fmap", function()

        it("Right applies the function to the inner value", function()
            local actual = Either.fmap(function(x) return x + 1 end, Either.Right(1))
            assert.same(Either.Right(2), actual)
        end)

        it("Left returns the Left unchanged", function()
            local actual = Either.fmap(function(x) return x + 1 end, Either.Left(1))
            assert.same(Either.Left(1), actual)
        end)

    end)

    describe("isLeft", function()

        it("returns true if Left is given, false otherwise", function()
            assert.is_true(Either.isLeft(Either.Left("v")))
            assert.is_false(Either.isLeft(Either.Right(true)))
        end)

    end)

    describe("isRight", function()

        it("returns true if Left is given, false otherwise", function()
            assert.is_false(Either.isRight(Either.Left("v")))
            assert.is_true(Either.isRight(Either.Right(true)))
        end)

    end)

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
