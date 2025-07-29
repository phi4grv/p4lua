local pub = {}

pub.isEmpty = function(arr)
    return type(arr) ~= "table" or arr[1] == nil
end

pub.new = function(...)
    return { ... }
end

return pub
