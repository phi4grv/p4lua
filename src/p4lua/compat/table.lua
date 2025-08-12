local pub = {}

pub.move = function(a1, f, e, t, a2)
    a2 = a2 or a1
    if t > e or t <= f then
        -- forward copy
        for i = f, e do
            a2[t + i - f] = a1[i]
        end
    else
        -- backward copy
        for i = e, f, -1 do
            a2[t + i - f] = a1[i]
        end
    end
    return a2
end

if table.move == nil then
    table.move = pub.move
end

pub.pack = function(...)
    return { n = select('#', ...), ... }
end

if table.pack == nil then
    table.pack = pub.pack
end

pub.unpack = function(t, i, j)
    i = i or 1
    j = j or #t -- not work with holes

    return unpack(t, i, j)
end

if table.unpack == nil then
    table.unpack = pub.unpack
end

if unpack == nil then
    unpack = table.unpack
end

return pub
