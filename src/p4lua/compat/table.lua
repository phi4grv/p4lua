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

---@diagnostic disable: deprecated
if (table.unpack == nil) and unpack then
    ---@diagnostic disable-next-line: deprecated
    table.unpack = unpack
end
---@diagnostic enable: deprecated

pub.unpack = table.unpack

return pub
