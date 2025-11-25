local assert = require("luassert")
local spy = require("luassert.spy")
local String = require("p4lua.data.String")

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

    describe("equalsWith", function()
        local eqlSpy = spy.new(function(a, b)
            return a == b
        end)
        local eqrSpy = spy.new(function(a, b)
            return a == b
        end)

        before_each(function()
            eqlSpy:clear()
            eqrSpy:clear()
        end)

        it("compares Left to Left", function()
            local result = Either.equalsWith(eqlSpy, eqrSpy, Either.Left("left1"), Either.Left("left2"))

            assert.is_false(result)
            assert.spy(eqlSpy).was.called(1)
            assert.spy(eqlSpy).was.called_with("left1", "left2")
            assert.spy(eqrSpy).was.not_called(1)
        end)

        it("compares Left to Left", function()
            local result = Either.equalsWith(eqlSpy, eqrSpy, Either.Left("left"), Either.Left("left"))

            assert.is_true(result)
            assert.spy(eqlSpy).was.called(1)
            assert.spy(eqlSpy).was.called_with("left", "left")
            assert.spy(eqrSpy).was.not_called(1)
        end)

        it("compares Right to Right", function()
            local result = Either.equalsWith(eqlSpy, eqrSpy, Either.Right("right1"), Either.Right("right2"))

            assert.is_false(result)
            assert.spy(eqrSpy).was.called(1)
            assert.spy(eqrSpy).was.called_with("right1", "right2")
            assert.spy(eqlSpy).was.not_called(1)
        end)

        it("compares Right to Right", function()
            local result = Either.equalsWith(eqlSpy, eqrSpy, Either.Right("right"), Either.Right("right"))

            assert.is_true(result)
            assert.spy(eqrSpy).was.called(1)
            assert.spy(eqrSpy).was.called_with("right", "right")
            assert.spy(eqlSpy).was.not_called(1)
        end)

        it("compares Left to Right", function()
            local result = Either.equalsWith(eqlSpy, eqrSpy, Either.Left("any"), Either.Right("any"))

            assert.is_false(result)
            assert.spy(eqlSpy).was.not_called(1)
            assert.spy(eqrSpy).was.not_called(1)
        end)

        it("compares Right to Left", function()
            local result = Either.equalsWith(eqlSpy, eqrSpy, Either.Right("any"), Either.Left("any"))

            assert.is_false(result)
            assert.spy(eqlSpy).was.not_called(1)
            assert.spy(eqrSpy).was.not_called(1)
        end)

        it("supports curry", function()
            assert.is_true(Either.equalsWith(eqlSpy)(eqrSpy)(Either.Right("right"))(Either.Right("right")))
            assert.is_true(Either.equalsWith(eqlSpy)(eqrSpy)(Either.Right("right"), Either.Right("right")))
            assert.is_true(Either.equalsWith(eqlSpy, eqrSpy)(Either.Right("right"))(Either.Right("right")))
            assert.is_true(Either.equalsWith(eqlSpy, eqrSpy)(Either.Right("right"), Either.Right("right")))
            assert.is_true(Either.equalsWith(eqlSpy, eqrSpy, Either.Right("right"))(Either.Right("right")))
       end)

        describe("equalsLeftWith", function()

            it("supports curry", function()
                assert.is_true(Either.equalsLeftWith(eqlSpy)(Either.Left("left"))(Either.Left("left")))
                assert.is_true(Either.equalsLeftWith(eqlSpy, Either.Left("left"))(Either.Left("left")))
            end)

        end)

        describe("equalsLeft", function()

            it("supports curry", function()
                assert.is_true(Either.equalsLeft(Either.Left("left"))(Either.Left("left")))
            end)

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

    describe("fromLeft", function()

        it("returns left value with Left", function()
            local actual = Either.fromLeft("default", Either.Left("left"))
            assert.same("left", actual)
        end)

        it("returns default value with Right", function()
            local actual = Either.fromLeft("default", Either.Right("right"))
            assert.same("default", actual)
        end)

    end)

    describe("fromRight", function()

        it("returns right value with Right", function()
            local actual = Either.fromRight("default", Either.Right("right"))
            assert.same("right", actual)
        end)

        it("returns default value with Left", function()
            local actual = Either.fromRight("default", Either.Left("left"))
            assert.same("default", actual)
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

    describe(".left", function()

        local L, R = Either.Left, Either.Right

        local cases = {
            { "01", {}, {}, "Empty Array", },
            { "03", { R("R1") }, {}, "Right only", },
            { "02", { L("L1") }, { "L1" }, "Left only", },
            { "04", { L("L1"), R("R1") }, { "L1" }, "Left, Right" },
        }

        for _, cv in ipairs(cases) do
            local case = { id = cv[1], input = cv[2], expected = cv[3], desc = cv[4] }

            it(("case #%s%s"):format(case.id, String.optPrefix(": ", case.desc)), function()
                local actual = Either.lefts(case.input)
                assert.same(case.expected, actual)
            end)
        end

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

    describe(".rights", function()

        local L, R = Either.Left, Either.Right

        local cases = {
            { "01", {}, {}, "Empty Array", },
            { "02", { L("L1") }, {}, "Left only", },
            { "03", { R("R1") }, { "R1" }, "Right only", },
            { "04", { L("L1"), R("R1") }, { "R1" }, "Left, Right" },
        }

        for _, cv in ipairs(cases) do
            local case = { id = cv[1], input = cv[2], expected = cv[3], desc = cv[4] }

            it(("case #%s%s"):format(case.id, String.optPrefix(": ", case.desc)), function()
                local actual = Either.rights(case.input)
                assert.same(case.expected, actual)
            end)
        end
    end)

end)
