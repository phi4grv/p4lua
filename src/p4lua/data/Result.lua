local Either = require("p4lua.data.Either")

local pub = {
    Err = Either.Left,
    Ok = Either.Right,
    bind = Either.bind,
    fmap = Either.fmap,
    fromErr = Either.fromLeft,
    fromOk = Either.fromRight,
    isErr = Either.isLeft,
    isOk = Either.isRight,
}

pub.match =  function(branches, r)
    return Either.match({
        Left = branches.Err,
        Right = branches.Ok
    }, r)
end

return pub
