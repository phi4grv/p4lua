local assert = require("luassert")
local spy = require("luassert.spy")
local p4fn = require("p4lua.fn")

describe ("p4lua", function()

    local p4lua = require("p4lua")

    describe("p4lua.require", function()

        it("loads specified functions from module", function()
            local f1, f2 = p4lua.require("p4lua.fn", { "compose", "composeArray" })
            assert.is_not_nil(f1)
            assert.equal(f1, p4fn.compose)
            assert.is_not_nil(f2)
            assert.equal(f2, p4fn.composeArray)
        end)

        it("assign nil if function is not found", function()
            local f1, f2, f3 = p4lua.require("p4lua.fn", { "compose", "not_exist", "composeArray" })
            assert.is_not_nil(f1)
            assert.equal(f1, p4fn.compose)
            assert.is_nil(f2)
            assert.is_not_nil(f3)
            assert.equal(f3, p4fn.composeArray)
        end)

    end)

    describe("p4lua.requireLazy", function()

        expose("expose package.preload and package.loaded", function()

            teardown(function()
                package.preload["fake.module"] = nil
                package.loaded["fake.module"] = nil
                package.preload["fake.empty"] = nil
                package.loaded["fake.empty"] = nil
            end)

            it("should lazily require the module only once upon first access", function()
                local fakeModule = {
                    foo = 123,
                    bar = function() return "hello" end,
                }
                -- Spy function to track require calls
                local requireSpy = spy.new(function()
                    return fakeModule
                end)
                package.preload["fake.module"] = function(...)
                    return requireSpy(...)
                end

                local lazyMod = p4lua.requireLazy("fake.module")
                local lazyMod2 = p4lua.requireLazy("fake.module")
                assert.equals(lazyMod, lazyMod2)

                -- Require should not be called yet
                assert.spy(requireSpy).was_not_called()

                -- Require should be called on first field access
                assert.equal(123, lazyMod.foo)
                assert.spy(requireSpy).was_called(1)

                -- Require should not be called again on subsequent accesses
                assert.equal("hello", lazyMod.bar())
                assert.spy(requireSpy).was_called(1)

                -- New property assignment should work
                lazyMod.newField = "newValue"
                assert.equal("newValue", lazyMod.newField)
                assert.equal("newValue", package.loaded["fake.module"].newField)
            end)
        end)

        it("returns nil for missing keys without error", function()
            package.preload["fake.empty"] = function()
                return {}
            end

            local lazyMod = p4lua.requireLazy("fake.empty")

            -- Accessing non-existent key returns nil
            assert.is_nil(lazyMod.nonexistent)
        end)

    end)
end)
