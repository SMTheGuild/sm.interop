
-- @import
local getFullName = sm.interop.util.getFullName
local mods = sm.interop.mods
local server = sm.interop.server
local assertArg = sm.interop.util.assertArgumentType

-- @private
local RUNNER_SHAPE_UUID = sm.uuid.new('2766e836-33ab-457d-970c-e9fe62820ade')
local RUNNER_SHAPE_POSITION = sm.vec3.new(0, 0, -35)

local startupScripts = {}
local oldScripts = {}
local scriptRan = {}
local startupState = {
    ignoreInvalidMods = false,
    oldScriptsRan = false,
    currentMod = nil
}

local createTempMod = function(namespace, name, author, uuid, version, identifyingPartUuid)
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
            return -1
        end,
        isLoaded = function(self)
            return pcall(sm.item.getShapeSize, identifyingPartUuid)
        end
    }
end

local function logpcall(fnc, ...)
    local result, error = pcall(fnc, ...)
    if not result then
        sm.log.error(error)
    end
end

local function runScript(fileName, mod)
    startupState.currentMod = mod
    dofile('$CONTENT_' .. tostring(mod:getUuid()) .. '/'.. fileName)
    startupState.currentMod = nil
end

-- @public
local startup = {}

function startup.register(mod, name, fileName)
    mods.assertIsValid(mod)
    local fn = getFullName(mod, name):lower()
    assert(startupScripts[fn] == nil, 'A startup script with this name is already registered')
    startupScripts[fn] = {
        mod = mod,
        fileName = fileName
    }

    if not scriptRan[fn] then
        logpcall(runScript, fileName, mod)
        scriptRan[fn] = true
    end
    server.callStartupScriptsChanged()
end

function startup.unregister(mod, name)
    mods.assertIsValid(mod)
    local fn = getFullName(mod, name)
    if oldScripts[fn] ~= nil then
        oldScripts[fn] = nil
    end
    if startupScripts[fn] ~= nil then
        startupScripts[fn] = nil
    end
    server.callStartupScriptsChanged()
end

function startup.getCurrentMod()
    return startupState.currentMod
end

function startup.restoreStartupScripts(scripts)
    for fullName, data in pairs(scripts) do
        oldScripts[fullName] = {
            fileName = data.fileName,
            mod = createTempMod(data.mod.namespace, data.mod.name, data.mod.author, data.mod.uuid, data.mod.version, data.mod.identifyingPartUuid)
        }
    end
end

function startup.isAllowingInvalidMods()
    return startupState.ignoreInvalidMods
end

function startup.getStartupScripts()
    local scripts = {}
    for k, v in pairs(startupScripts) do
        scripts[k] = {
            fileName = v.fileName,
            mod = {
                namespace = v.mod:getNamespace(),
                name = v.mod:getName(),
                author = v.mod:getAuthor(),
                uuid = v.mod:getUuid(),
                version = v.mod:getVersion(),
                identifyingPartUuid = v.mod:getIdentifyingPartUuid(),
            }
        }
    end
    for k, v in pairs(oldScripts) do
        if scripts[k] == nil then
            scripts[k] = {
                fileName = v.fileName,
                mod = {
                    namespace = v.mod:getNamespace(),
                    name = v.mod:getName(),
                    author = v.mod:getAuthor(),
                    uuid = v.mod:getUuid(),
                    version = v.mod:getVersion(),
                    identifyingPartUuid = v.mod:getIdentifyingPartUuid(),
                }
            }
        end
    end
    return scripts
end

function startup.startRunOldScripts()
    if not startupState.oldScriptsRan then
        sm.shape.createPart(RUNNER_SHAPE_UUID, RUNNER_SHAPE_POSITION, sm.quat.identity(), false, false)
    end
end

function startup.runOldScripts()
    if startupState.oldScriptsRan then
        return
    end
    startupState.oldScriptsRan = true
    startupState.ignoreInvalidMods = true
    for k,v in pairs(oldScripts) do
        if not scriptRan[k] then
            if v.mod:isLoaded() then
                logpcall(runScript, v.fileName, v.mod)
                scriptRan[k] = true
            else
                sm.log.warning('Did not load startup script "'..k..'", mod\'s identifying part not found')
            end
        end
    end
    startupState.ignoreInvalidMods = false
end

-- @export
sm.interop.startup = startup
