-- @private
local storageData = {}
local STORAGE_CHANNEL = 1

-- @public
local storage = {}
local storageLoaded = false

function storage.loadModData()
    data = sm.storage.load(STORAGE_CHANNEL)
    if not storageLoaded and data ~= nil then
        storageData = data
        print('[sm.interop] Loaded mod data ('..#storageData..' mods)')
        storageLoaded = true
        return true
    else
        return false
    end
end

function storage.storeModData()
    sm.storage.save(STORAGE_CHANNEL, storageData)
end

function storage.load(mod, key)
    local namespace = mod:getNamespace()
    if storageData[namespace] == nil then
        return nil
    end
    return storageData[namespace][key]
end

function storage.save(mod, key, value)
    local namespace = mod:getNamespace()
    if storageData[namespace] == nil then
        storageData[namespace] = {}
    end
    storageData[namespace][key] = value
    sm.interop.server.callStartupScriptsChanged();
end

-- @export
sm.interop.storage = storage
