local pub = {}

local function createCtor(typeName, tag, keys)
    return function(...)
        local args = table.pack(...)
        if args.n ~= #keys then
            error(("Constructor error: %s.%s expected %d argument(s), got %d")
                :format(typeName, tag, #keys, args.n))
        end
        local value = { _tag = tag }
        for i, key in ipairs(keys) do
            value[key] = args[i]
        end
        return value
    end
end

pub.defineSumType = function(typeName, typeSpec)
    local ctors = {}
    local valueKeys = {}

    for tag, keys in pairs(typeSpec) do
        ctors[tag] = createCtor(typeName, tag, keys)
        valueKeys[tag] = keys
    end

    local function match(value, branches)
        local tag = value._tag
        local handler = branches[value._tag]
        if (not handler) then
            error(("Match error: unmatched tag '%s' in type '%s'") :format(tag or "<nil>", typeName))
        end

        local ks = valueKeys[tag]
        local args = {}
        for i, v in ipairs(ks) do
            args[i] = value[v]
        end
        return handler(table.unpack(args, 1, #ks))
    end

    return ctors, match
end

return pub
