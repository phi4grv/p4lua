local pub = {}

pub.fmap = function(f, arr)
    if (arr == nil) then
        return function(arr2)
            return pub.fmap(f, arr2)
        end
    end

    local result = {}
    for i = 1, #arr do
        result[i] = f(arr[i])
    end
    return result
end

pub.foldl = function(ff, acc, arr)
    if arr == nil then
        if (acc == nil) then
            return function(acc2, arr2)
                return pub.foldl(ff, acc2, arr2)
            end
        end
        return function(arr2)
            return pub.foldl(ff, acc, arr2)
        end
    end

    local result = acc
    for i = 1, #arr do
        result = ff(result, arr[i])
    end
    return result
end

pub.foldr = function(ff, acc, arr)
    if arr == nil then
        if (acc == nil) then
            return function(acc2, arr2)
                return pub.foldr(ff, acc2, arr2)
            end
        end
        return function(arr2)
            return pub.foldr(ff, acc, arr2)
        end
    end

    local result = acc
    for i = #arr, 1, -1 do
        result = ff(arr[i], result)
    end
    return result
end

pub.isEmpty = function(arr)
    return type(arr) ~= "table" or arr[1] == nil
end

pub.zipWith = function(fs, ...)
    local args = { ... }
    local result = {}
    local i = 1

    while true do
        local f = fs[i]
        if not f then break end

        local argList = {}
        local anyNil = false

        for _, arr in ipairs(args) do
            local v = arr[i]
            if v == nil then anyNil = true break end
            table.insert(argList, v)
        end

        if anyNil then break end

        result[i] = f(table.unpack(argList))
        i = i + 1
    end

    return result
end

return pub
