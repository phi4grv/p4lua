local pub = {}

local empty = {}

pub.empty = function()
    return empty
end

pub.fromMutable = function(tbl)
    local f = function(acc, k, v)
        acc[k] = v
        return acc
    end
    return pub.fold(f, {}, tbl)
end

pub.fold = function(f, acc, map)
    if map == nil then
        if acc == nil then
            return function(a, m)
                return pub.fold(f, a, m)
            end
        end
        return function(m)
            return pub.fold(f, acc, m)
        end
    end

    for k, v in pairs(map) do
        acc = f(acc, k, v)
    end
    return acc
end

pub.filterByKeys = function(m, ks)
    local result = {}
    for _, k in ipairs(ks) do
        if m[k] then
            result[k] = m[k]
        end
    end
    return result
end

pub.values = function(m)
    local result = {}
    for _, v in pairs(m) do
        if v ~= nil then
            table.insert(result, v)
        end
    end
    return result
end

-- TODO: return [Maybe a]
pub.valuesByKeys = function(m, ks)
    local result = {}
    for i, k in ipairs(ks) do
        result[i] =  m[k]
    end
    return result
end

return pub
