-- @import
local Set = sm.interop.util.Set
local assertArg = sm.interop.util.assertArgumentType

-- @private
local mods = {}
local namespaces = Set.new()

local createMod = function(namespace, name, author, uuid, version, identifyingPartUuid, modListIndex)
    return {
        getName = function(self)
            return name
        end,
        getAuthor = function(self)
            return author
        end,
        getUuid = function(self)
            return uuid
        end,
        getVersion = function(self)
            return version
        end,
        getNamespace = function(self)
            return namespace
        end,
        getIdentifyingPartUuid = function(self)
            return identifyingPartUuid
        end,
        getModListIndex = function(self)
            return modListIndex
        end
    }
end

-- @public
sm.interop.mods = {}

--- Register a new mod.
-- @param namespace The unique namespace for this mod
-- @param name      The name of the mod
-- @param author    The author(s) of this mod
-- @param uuid      Uuid (localId) of this mod
-- @param version   The version number of this mod
-- @param identifyingPartUuid Uuid of a part in the mod
function sm.interop.mods.register(namespace, name, author, uuid, version, identifyingPartUuid)
    assertArg(1, namespace, 'string')
    assertArg(2, name, 'string')
    assertArg(3, author, 'string')
    assertArg(4, uuid, 'Uuid')
    assertArg(5, version, 'string')
    assertArg(6, identifyingPartUuid, 'Uuid')

    assert(not namespaces:contains(namespace), 'This namespace is already registered by another mod')

    local index = #mods + 1
    local mod = createMod(namespace, name, author, uuid, version, identifyingPartUuid, index)
    mods[index] = mod
    namespaces:add(namespace)
    return mod
end

function sm.interop.mods.assertIsValid(mod)
    assertArg(1, mod, 'table')
    assert(mod ~= sm.interop.mods, 'Call this function without :')
    assert(sm.interop.startup.isAllowingInvalidMods or mods[mod:getModListIndex()] == mod, 'Invalid Mod object passed to mod parameter')
end

function sm.interop.mods.getName(mod)
    return mod:getName()
end

function sm.interop.mods.getNamespace(mod)
    return mod:getNamespace()
end

function sm.interop.mods.getVersion(mod)
    return mod:getVersion()
end

function sm.interop.mods.getAuthor(mod)
    return mod:getAuthor()
end

function sm.interop.mods.getUuid(mod)
    return mod:getUuid()
end

function sm.interop.mods.getIdentifyingPartUuid(mod)
    return mod:getIdentifyingPartUuid()
end

function sm.interop.mods.getRegisteredMods()
    local modlist = {}
    for i,v in ipairs(mods) do
        modlist[i] = {
            name = v:getName(),
            author = v:getAuthor(),
            version = v:getVersion(),
            namespace = v:getNamespace()
        }
    end
    return modlist
end

function sm.interop.mods.getRegisteredNamespaces()
    return namespaces:toTable()
end
