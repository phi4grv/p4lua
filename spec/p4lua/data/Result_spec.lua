local assert = require("luassert")
local spy = require("luassert.spy")

describe("p4lua.data.Result", function()

    local Result = require("p4lua.data.Result")

    describe("Result.bind", function()

        it("Ok should apply function and return new Ok", function()
            local f = function(v) return Result.Ok(v * 2) end
            local r = Result.Ok(10)

            local actual = Result.bind(r, f)

            assert.same(Result.Ok(20), actual)
        end)

        it("Err should not apply function and return original Err", function()
            local f = spy.new(function() end)
            local l = Result.Err("left")

            local actual = Result.bind(l, f)

            assert.spy(f).was_not.called()
            assert.same(Result.Err("left"), actual)
        end)

        it("bind chain works with multiple Oks", function()
            local r1 = Result.Ok(5)
            local r2 = Result.bind(r1, function(v) return Result.Ok(v + 3) end)
            local r3 = Result.bind(r2, function(v) return Result.Ok(v * 2) end)

            assert.same(Result.Ok(16), r3)
        end)

        it("bind short-circuits on Err", function()
            local r1 = Result.Ok(5)
            local r2 = Result.bind(r1, function(v) return Result.Err("fail") end)
            local r3 = Result.bind(r2, function(v) return Result.Ok(v * 2) end)

            assert.same(Result.Err("fail"), r3)
        end)

    end)

    describe("Result.fmap", function()

        it("Ok applies the function to the inner value", function()
            local actual = Result.fmap(function(x) return x + 1 end, Result.Ok(1))
            assert.same(Result.Ok(2), actual)
        end)

        it("Err returns the Err unchanged", function()
            local actual = Result.fmap(function(x) return x + 1 end, Result.Err(1))
            assert.same(Result.Err(1), actual)
        end)

    end)

    describe("fromErr", function()

        it("returns left value with Err", function()
            local actual = Result.fromErr("default", Result.Err("left"))
            assert.same("left", actual)
        end)

        it("returns default value with Ok", function()
            local actual = Result.fromErr("default", Result.Ok("right"))
            assert.same("default", actual)
        end)

    end)

    describe("fromOk", function()

        it("returns right value with Ok", function()
            local actual = Result.fromOk("default", Result.Ok("right"))
            assert.same("right", actual)
        end)

        it("returns default value with Err", function()
            local actual = Result.fromOk("default", Result.Err("left"))
            assert.same("default", actual)
        end)

    end)

    describe("isErr", function()

        it("returns true if Err is given, false otherwise", function()
            assert.is_true(Result.isErr(Result.Err("v")))
            assert.is_false(Result.isErr(Result.Ok(true)))
        end)

    end)

    describe("isOk", function()

        it("returns true if Err is given, false otherwise", function()
            assert.is_false(Result.isOk(Result.Err("v")))
            assert.is_true(Result.isOk(Result.Ok(true)))
        end)

    end)

    describe("Result.match", function()

        it("Ok should call right function once with correct value", function()
            local leftSpy  = spy.new(function(l) return "Err: "..l end)
            local rightSpy = spy.new(function(r) return "Ok: "..r end)

            local r = Result.Ok(42)
            local actual = Result.match({ Err = leftSpy, Ok = rightSpy }, r)

            assert.equal("Ok: 42", actual)
            assert.spy(rightSpy).was.called(1)
            assert.spy(rightSpy).was.called_with(42)
            assert.spy(leftSpy).was_not.called()
        end)

        it("Err should call left function once with correct value", function()
            local leftSpy  = spy.new(function(l) return "Err: "..l end)
            local rightSpy = spy.new(function(r) return "Ok: "..r end)

            local l = Result.Err("error")
            local actual = Result.match({ Err = leftSpy, Ok = rightSpy }, l)

            assert.equal("Err: error", actual)
            assert.spy(leftSpy).was.called(1)
            assert.spy(leftSpy).was.called_with("error")
            assert.spy(rightSpy).was_not.called()
        end)
    end)

end)
