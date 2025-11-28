local Either = require("p4lua.data.Either")

local pub = {
    Err = Either.Left,
    Ok = Either.Right,
    ap = Either.ap,
    bind = Either.bind,
    equalsWith = Either.equalsWith,
    equals = Either.equals,
    equalsOkWith = Either.equalsOkWith,
    equalsOk = Either.equalsOk,
    equalsErrWith = Either.equalsLeftWith,
    equalsErr = Either.equalsLeft,
    errs = Either.lefts,
    fmap = Either.fmap,
    fromErr = Either.fromLeft,
    fromOk = Either.fromRight,
    isErr = Either.isLeft,
    isOk = Either.isRight,
    oks = Either.rights,
    pure = Either.pure,
}

pub.match =  function(branches, r)
    return Either.match({
        Left = branches.Err,
        Right = branches.Ok
    }, r)
end

return pub
