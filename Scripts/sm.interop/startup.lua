-- @import
local getFullName = sm.interop.util.getFullName
local mods = sm.interop.mods
local server = sm.interop.server
local logpcall = sm.interop.util.logpcall
local assertArg = sm.interop.util.assertArgumentType

-- @private
local RUNNER_SHAPE_UUID = sm.uuid.new('2766e836-33ab-457d-970c-e9fe62820ade')
local RUNNER_SHAPE_POSITION = sm.vec3.new(0, 0, -35)

local startupScripts = {}
local oldScripts = {}
local scriptRan = {}
local scriptsAwaitingDependencies = {}
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

local function runScript(fullName, fileName, mod)
    startupState.currentMod = mod
    scriptRan[fullName] = true
    dofile('$CONTENT_' .. tostring(mod:getUuid()) .. '/'.. fileName)
    startupState.currentMod = nil

    -- See if any scripst can be run that are dependent on this script,
    -- for example for registering tools, connection types or services
    local awaiting = scriptsAwaitingDependencies[fullName]
    if awaiting ~= nil then
        for _,v in ipairs(awaiting) do
            local missingDependency = false
            for __,dependency in ipairs(v.dependencies) do
                if not scriptRan[dependency] then
                    missingDependency = true
                    break
                end
            end
            if not missingDependency then
                startupState.currentMod = v.mod
                runScript(v.fullName, v.fileName, v.mod)
                startupState.currentMod = nil
            end
        end
    end
end

-- @public
local startup = {}

function startup.register(mod, name, fileName, dependencies)
    assertArg(1, mod, 'table')
    assertArg(2, name, 'string')
    assertArg(3, fileName, 'string')
    if dependencies ~= nil then
        assertArg(4, dependencies, 'table')
    end

    mods.assertIsValid(mod)
    local fn = getFullName(mod, name):lower()
    assert(startupScripts[fn] == nil, 'A startup script with this name is already registered')
    startupScripts[fn] = {
        fullName = fn,
        mod = mod,
        fileName = fileName,
        dependencies = dependencies
    }

    if not scriptRan[fn] then
        local awaitingDependency = false
        if dependencies ~= nil then
            for _,v in ipairs(dependencies) do
                if not scriptRan[v] then
                    awaitingDependency = true
                    break
                end
            end
        end
        if not awaitingDependency then
            logpcall(runScript, fn, fileName, mod, dependencies)
        else
            print('Delaying script '.. fn..', missing dependencies')
            for _,v in ipairs(dependencies) do
                print(' * '..v)
                local f = scriptsAwaitingDependencies[v] or {}
                scriptsAwaitingDependencies[v] = f
                f[#f + 1] = {
                    mod = mod,
                    fileName = fileName,
                    dependencies = dependencies
                }
            end
        end
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
        print('RestoreDep '..fullName, data.dependencies)
        oldScripts[fullName] = {
            dependencies = data.dependencies,
            fileName = data.fileName,
            fullName = fullName,
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
            dependencies = v.dependencies,
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
                dependencies = v.dependencies,
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
        startup.runOldScript(k, v)
    end
    startupState.ignoreInvalidMods = false
end

local dependenciesCalled = {}
function startup.runOldScript(fn, data)
    dependenciesCalled[fn] = true
    if not scriptRan[fn] then
        if data.mod:isLoaded() then
            if data.dependencies ~= nil then
                for _,dependency in ipairs(data.dependencies) do
                    if not scriptRan[dependency] then
                        if dependenciesCalled[dependency] then
                            print('[sm.interop] Cannot run '..fn ..', missing dependency at startup')
                            return
                        else
                            startup.runOldScript(dependency, oldScripts[dependency])
                        end
                    end
                end
            end
            logpcall(runScript, fn, data.fileName, data.mod)
        else
            print('[sm.interop] Did not load startup script "'..fn..'", mod\'s identifying part not found')
        end
    end
end

-- @export
sm.interop.startup = startup
