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

pub.valuesByKeys = function(m, ks)
    local result = {}
    for _, k in ipairs(ks) do
        if m[k] ~= nil then
            table.insert(result, m[k])
        end
    end
    return result
end

return pub
