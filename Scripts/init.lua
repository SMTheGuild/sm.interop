-- Don't load if already loaded
if sm.interop ~= nil then
    return
end

-- Don't load if not actually selected as mod
-- Check by seeing if the server part shape is registered
local modPartsLoaded, error = pcall(sm.item.getShapeSize, sm.uuid.new('cf73bdd4-caab-440d-b631-2cac12c17904'))
if not modPartsLoaded then
    print('Error occurred: ' .. error)
    error('sm.interop is not enabled for this world')
end

sm.interop = {
    version = '0.1.0-alpha',
    connectionType = 4096
}

-- Load all files
dofile 'sm.interop/util.lua'
dofile 'sm.interop/mods.lua'
dofile 'sm.interop/permissions.lua'
dofile 'sm.interop/events.lua'
dofile 'sm.interop/connections.lua'
dofile 'sm.interop/commands.lua';
dofile 'sm.interop/tools.lua'
dofile 'sm.interop/server.lua'
dofile 'sm.interop/startup.lua'
dofile 'sm.interop/scheduler.lua'

-- Create server part
if sm.isServerMode() then
    print('Servermode: createIfNecessary')
    sm.interop.server.createIfNecessary()
end
