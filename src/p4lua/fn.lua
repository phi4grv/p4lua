local pub = {}

pub.compose = function(...)
    local fs = {...}
    if #fs == 0 then
        return function(x) return x end
    end
    return function(...)
        local fio = ...
        for i = #fs, 1, -1 do
            fio = fs[i](fio)
        end
        return fio
    end
end

return pub
