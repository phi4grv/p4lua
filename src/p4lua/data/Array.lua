local pub = {}

pub.isEmpty = function(arr)
    return type(arr) ~= "table" or arr[1] == nil
end

pub.new = function(...)
    return { ... }
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
