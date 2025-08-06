local pub = {}

pub.cons = function(v, arr)
    if (arr == nil) then
        return function(arr2)
            return pub.cons(v, arr2)
        end
    end

    table.insert(arr, 1, v)
    return arr
end

pub.insert = function(i, v, arr)
    if (arr == nil) then
        if (v == nil) then
            return function(v2, arr2)
                return pub.insert(i, v2, arr2)
            end
        end
        return function(arr2)
            return pub.insert(i, v, arr2)
        end
    end

    local n = #arr
    local pos
    if i < 1 then
        pos = 1
    elseif i > n + 1 then
        pos = n + 1
    else
        pos = i
    end

    table.insert(arr, pos, v)

    return arr
end

pub.snoc = function(v, arr)
    if (arr == nil) then
        return function(arr2)
            return pub.snoc(v, arr2)
        end
    end

    table.insert(arr, v)
    return arr
end

return pub
