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
