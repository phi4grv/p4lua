local p4tbl = require("p4lua.table")
local Array = require("p4lua.data.Array")

local pub = {}

local function createCtor(typeName, tag, keys)
    if (Array.isEmpty(keys)) then
        local value = p4tbl.seal({ _tag = tag })
        return function()
            return value
        end
    end
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

local function match(typeName, valueKeys, branches, value)
    local tag = value._tag
    local handler = branches[tag]
    if not handler then
        error(("Match error: unmatched tag '%s' in type '%s'"):format(tag or "<nil>", typeName))
    end
    local ks = valueKeys[tag]
    local args = {}
    for i, v in ipairs(ks) do
        args[i] = value[v]
    end
    return handler(table.unpack(args, 1, #ks))
end

local function makeMatch(typeName, valueKeys)
    return function(branches, value)
        if value == nil then
            return function(v)
                return match(typeName, valueKeys, branches, v)
            end
        end
        return match(typeName, valueKeys, branches, value)
    end
end

pub.defineSumType = function(typeName, typeSpec)
    local ctors = {}
    local valueKeys = {}

    for tag, keys in pairs(typeSpec) do
        ctors[tag] = createCtor(typeName, tag, keys)
        valueKeys[tag] = keys
    end

    return ctors, makeMatch(typeName, valueKeys)
end

return pub
