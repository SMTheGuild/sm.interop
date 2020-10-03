-- Don't load if already loaded
if sm.interop ~= nil then
    return
end

-- Don't load if not actually selected as mod
-- Check by seeing if the server part shape is registered
local modPartsLoaded, err = pcall(sm.item.getShapeSize, sm.uuid.new('cf73bdd4-caab-440d-b631-2cac12c17904'))
if not modPartsLoaded then
    error('sm.interop is not enabled for this world')
end

sm.interop = {
    version = '0.2.0',
    connectionType = 4096,
    gamefileModVersion = 3
}

if not sm.interopGamefileModVersion or sm.interopGamefileModVersion < sm.interop.gamefileModVersion then
    if not sm.isServerMode() then
        sm.gui.chatMessage('#ff0000Error: #ffffffYou need to Update the Game file part of the sm.interop mod. Visit the Steam Workshop page for sm.interop to read about how to do this.')
    end
    sm.log.error('You need to Update the Game file part of the sm.interop mod. Visit the Steam Workshop page for sm.interop to read about how to do this.')
end

-- Load all files
dofile 'sm.interop/util.lua'
dofile 'sm.interop/mods.lua'
dofile 'sm.interop/permissions.lua'
dofile 'sm.interop/events.lua'
dofile 'sm.interop/connections.lua'
dofile 'sm.interop/commands.lua';
dofile 'sm.interop/tools.lua'
dofile 'sm.interop/server.lua'
dofile 'sm.interop/services.lua'
dofile 'sm.interop/startup.lua'
dofile 'sm.interop/storage.lua'
dofile 'sm.interop/scheduler.lua'
