local pub = {
    lua_version = _VERSION:match("%d+%.%d+")
}

if not table.unpack and unpack then
    table.unpack = unpack
end

if not table.pack then
    table.pack = function(...)
        return { n = select('#', ...), ... }
    end
end

return pub
