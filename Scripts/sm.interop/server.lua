-- @import
local events = sm.interop.events

-- @private
local serverData = {
    serverClass = nil
}

local SERVER_SHAPE_UUID = sm.uuid.new('cf73bdd4-caab-440d-b631-2cac12c17904');
local SERVER_SHAPE_POSITION = sm.vec3.new(0, 0, -30)
local SERVER_SHAPE_OFFSET = sm.vec3.new(.125, .125, .125)
local SERVER_SHAPE_POSITION_CALC = SERVER_SHAPE_POSITION + SERVER_SHAPE_OFFSET

local function isServerShapeValid(shape)
    return
        sm.exists(shape) and
        shape:getShapeUuid() == SERVER_SHAPE_UUID and
        shape:getWorldPosition() == SERVER_SHAPE_POSITION_CALC and
        not shape.body:isDynamic()
end

local function mustCreateNewShape()
    return serverData.serverClass == nil or not isServerShapeValid(serverData.serverClass.shape)
end

-- @public
local server = {}

-- function server.destroy()
--     if serverData.serverClass then
--         serverData.serverClass.shape:destroyShape()
--     end
-- end

function server.serverPartCreated(serverClass)
    if isServerShapeValid(serverClass.shape) then
        serverData.serverClass = serverClass
    end
end

function server.isValid(shape)
    return isServerShapeValid(shape)
end

function server.createIfNecessary()
    if mustCreateNewShape() then
        local shape = sm.shape.createPart(SERVER_SHAPE_UUID, SERVER_SHAPE_POSITION, sm.quat.identity(), false, false)
    end
end

function server.createNewShape()
    local shape = sm.shape.createPart(SERVER_SHAPE_UUID, SERVER_SHAPE_POSITION, sm.quat.identity(), false, false)
end

function server.callStartupScriptsChanged()
    if serverData.serverClass then
        serverData.serverClass:interop_notifyOfStartupChange()
    else
        sm.log.error('Startup scripts changed, no Server')
    end
end
function server.callStorageChanged()
    if serverData.serverClass then
        serverData.serverClass:interop_notifyOfStorageChange()
    end
end

function server.exists()
    return serverData.shape ~= nil and sm.exists(serverData.shape) and not serverData.shape.body:isDynamic()
end

-- @export
sm.interop.server = server
