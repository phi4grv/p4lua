local assert = require("luassert")
local String = require("p4lua.data.String")
local Result = require("p4lua.data.Result")

describe("p4lua.fs.path", function()

    local path = require("p4lua.fs.path")

    after_each(function()
        path.separator = package.config:sub(1,1)
    end)

    describe(".join", function()

        it("joins simple relative paths", function()
            path.separator = "/"
            assert.equal("foo/bar", path.join("foo", "bar"))
            assert.equal("foo/bar/baz", path.join("foo", "bar", "baz"))
        end)

        it("keeps existing separators as is", function()
            path.separator = "/"
            assert.equal("foo//bar", path.join("foo//", "bar"))
            assert.equal("foo/bar", path.join("foo/", "bar"))
            assert.equal("foo//bar//baz", path.join("foo//", "bar//", "baz"))
        end)

        it("ignores empty parts", function()
            path.separator = "/"
            assert.equal("foo/bar", path.join("foo", "", "bar"))
            assert.equal("foo", path.join("", "foo", ""))
        end)

        it("leaves trailing separators", function()
            path.separator = "/"
            assert.equal("/local/bin/", path.join("/local/", "bin/"))
        end)

        it("resets when encountering an absolute path", function()
            path.separator = "/"
            assert.equal("/bar", path.join("foo/", "/bar"))
            assert.equal("/etc/config", path.join("/home/user", "/etc/config"))
        end)

        it("works with Windows-style separators", function()
            path.separator = "\\"
            assert.equal("foo\\bar", path.join("foo", "bar"))
            assert.equal("foo\\\\bar", path.join("foo\\\\", "bar"))
            assert.equal("\\etc\\config", path.join("C:\\home", "\\etc\\config"))
        end)

        it("returns empty string when all parts are empty or nil", function()
            assert.equal("", path.join("", nil, ""))
        end)
    end)

    describe(".relativeTo", function()

        local cases = {
            { "01", { "/absolute/common/a1/a2", "/absolute/common/b1/b2" }, Result.Ok("../b1/b2") },
            { "02", { "/absolute/a1/a2", "/no/common/b1/b2" }, Result.Ok("../../no/common/b1/b2") },
            { "03", { "/absolute/same/file", "/absolute/same/file" }, Result.Ok("file") },
            { "04", { "/", "/absolute/file" }, Result.Ok("absolute/file") },
            { "05", { "relative/a1/a2", "relative/b1/b2" }, Result.Ok("../b1/b2") },
            { "06", { "relative/a1/a2", "no/common/b1/b2" }, Result.Ok("../../no/common/b1/b2") },
        }

        for _, cv in ipairs(cases) do
            local case = { id = cv[1], input = cv[2], expected = cv[3], desc = cv[4] }

            it(("case #%s%s"):format(case.id, String.optPrefix(": ", case.desc)), function()
                local actual = path.relativeTo(case.input[1], case.input[2])
                assert.same(case.expected, actual)
            end)
        end

        it("returns Result.Err when absolute and relative paths are mixed", function()
            assert.is_true(Result.isErr(path.relativeTo("/absolute/path", "relative/path")))
            assert.is_true(Result.isErr(path.relativeTo("relative/path", "/absolute/path")))
        end)

        it("handles empty from", function()
            assert.same(Result.Ok("relative/path"), path.relativeTo("", "relative/path"))
            assert.same(Result.Ok("relative/path"), path.relativeTo(nil, "relative/path"))
            assert.is_true(Result.isErr(path.relativeTo("", "/absolute/path")))
            assert.is_true(Result.isErr(path.relativeTo(nil, "/absolute/path")))
        end)

        it("handles empty to", function()
            assert.same(Result.Ok(".."), path.relativeTo("relative/path", ""))
            assert.same(Result.Ok(".."), path.relativeTo("relative/path", nil))
            assert.is_true(Result.isErr(path.relativeTo("/absolute/path", "")))
            assert.is_true(Result.isErr(path.relativeTo("/absolute/path", nil)))
        end)

    end)

    describe(".rstripSeparator", function()

        it("removes a single trailing separator on Unix style paths", function()
            path.separator = "/"
            assert.equal("foo/bar", path.rstripSeparator("foo/bar/"))
            assert.equal("foo/bar/", path.rstripSeparator("foo/bar//"))  -- only one removed
            assert.equal("foo/bar", path.rstripSeparator("foo/bar"))
        end)

        it("removes a single trailing separator on Windows style paths", function()
            path.separator = "\\"
            assert.equal("foo\\bar", path.rstripSeparator("foo\\bar\\"))
            assert.equal("foo\\bar\\", path.rstripSeparator("foo\\bar\\\\"))
            assert.equal("foo\\bar", path.rstripSeparator("foo\\bar"))
        end)

        it("returns root path unchanged", function()
            path.separator = "/"
            assert.equal("/", path.rstripSeparator("/"))
            assert.equal("/", path.rstripSeparator("//"))
            path.separator = "\\"
            assert.equal("\\", path.rstripSeparator("\\"))
            assert.equal("\\", path.rstripSeparator("\\\\"))
        end)

        it("returns nil when input is nil", function()
            assert.is_nil(path.rstripSeparator(nil))
        end)

        it("does not modify paths without trailing separator", function()
            path.separator = "/"
            assert.equal("foo/bar", path.rstripSeparator("foo/bar"))
            path.separator = "\\"
            assert.equal("foo\\bar", path.rstripSeparator("foo\\bar"))
        end)

    end)
end)
