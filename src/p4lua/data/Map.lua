local pub = {}

pub.new = function()
    return {}
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

-- TODO: return [Maybe a]
pub.valuesByKeys = function(m, ks)
    local result = {}
    for i, k in ipairs(ks) do
        result[i] =  m[k]
    end
    return result
end

return pub
