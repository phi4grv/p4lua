local pub = {}

pub.insert = function(k, v, m)
    if (m == nil) then
        if (v == nil) then
            return function(v2, m2)
                return pub.insert(k, v2, m2)
            end
        end
        return function(m2)
            return pub.insert(k, v, m2)
        end
    end

    m[k] = v
    return m
end

return pub
