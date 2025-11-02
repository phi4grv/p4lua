local Result = require("p4lua.data.Result")

local pub = {}

pub.separator = package.config:sub(1, 1)

local function splitPath(path)
    local result = {}
    if not path then
        return result
    end

    for part in string.gmatch(path, ("[^%s]+"):format(pub.separator)) do
        table.insert(result, part)
    end
    return result
end

local function isAbsolute(path)
    if not path or path == "" then
        return false
    end
    return path:sub(1, 1) == pub.separator
end

pub.isAbsolute = isAbsolute

local function join(...)
    local sep = pub.separator
    local parts = { ... }
    local result = {}

    for _, part in ipairs(parts) do
        if part and part ~= "" then
            if pub.isAbsolute(part) then
                -- If an absolute path is encountered, discard previous.
                result = { part }
            else
                table.insert(result, part)
            end
        end
    end

    if #result == 0 then
        return ""
    end

    local joined = result[1]
    for i = 2, #result do
        local part = result[i]
        -- Only add a separator if needed.
        -- If the previous part ends with one or the next part starts with one, keep them as-is.
        if joined:sub(-1) == sep or part:sub(1, 1) == sep then
            joined = joined .. part
        else
            joined = joined .. sep .. part
        end
    end

    return joined
end

pub.join = join

local function relativeTo(from, to)
    from = pub.rstripSeparator(from)
    to = pub.rstripSeparator(to)

    if pub.isAbsolute(from) ~= pub.isAbsolute(to) then
        return Result.Err("relativeTo: cannot mix absolute and relative paths")
    end

    local fromParts = splitPath(from)
    local toParts = splitPath(to)

    -- Remove filename for 'from' (assume last part is file)
    table.remove(fromParts)

    -- Find common prefix
    local i = 1
    while i <= #fromParts and i <= #toParts and fromParts[i] == toParts[i] do
        i = i + 1
    end

    local rs = {}
    for _ = i, #fromParts do
        table.insert(rs, "..")
    end
    for j = i, #toParts do
        table.insert(rs, toParts[j])
    end

    return Result.Ok(table.concat(rs, pub.separator))
end

pub.relativeTo = relativeTo

local function rstripSeparator(p)
    if not p then
        return p
    end
    local sep = pub.separator

    if p == sep then
        return p
    end

    return (p:gsub(sep .. "$", ""))
end

pub.rstripSeparator = rstripSeparator

return pub
