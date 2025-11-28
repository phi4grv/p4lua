local assert = require("luassert")
local spy = require("luassert.spy")
local String = require("p4lua.data.String")

describe("p4lua.data.Result", function()

    local Result = require("p4lua.data.Result")
    local Ok, Err = Result.Ok, Result.Err

    describe(".ap", function()

        local function add1(x) return x + 1 end
        local function add(x, y) return x + y end

        ---@diagnostic disable: need-check-nil
        local cases = {
            { "01", { Ok(add1), Ok(1) }, Ok(2) },
            { "02", { Err("_"), Ok(1) }, Err("_") },
            { "03", { Ok(add1), Err("_") }, Err("_") },
            { "04", { Ok(add), Ok(1), Ok(2) }, Ok(3) },
            { "05", { Err("_"), Ok(1), Ok(2) }, Err("_") },
            { "06", { Ok(add), Err("_"), Ok(2) }, Err("_") },
            { "07", { Ok(add), Ok(1), Err("_") }, Err("_") },
        }
        ---@diagnostic enable: need-check-nil

        for _, cv in ipairs(cases) do
            local case = { id = cv[1], input = cv[2], expected = cv[3], desc = cv[4] }

            it(("case #%s%s"):format(case.id, String.optPrefix(": ", case.desc)), function()
                local actual = Result.ap(table.unpack(case.input))
                assert.same(case.expected, actual)
            end)
        end

    end)

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

    describe(".errs", function()

        it("returns errs", function()
            local actual = Result.errs({ Result.Ok("Ok"), Result.Err("Err") })
            assert.same({ "Err" }, actual)
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

    describe(".oks", function()

        it("returns oks", function()
            local actual = Result.oks({ Result.Ok("Ok"), Result.Err("Err") })
            assert.same({ "Ok" }, actual)
        end)

    end)

    describe(".pure", function()

        it("pure should wrap a single value into a Right", function()
            assert.same(Result.Ok("_"), Result.pure("_"))
        end)

    end)
end)
