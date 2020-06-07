
CreativeGame = class( nil )
CreativeGame.enableLimitedInventory = false
CreativeGame.enableRestrictions = false

g_godMode = true

function CreativeGame.server_onCreate()
end

function CreativeGame.client_onCreate( self )
	sm.game.setTimeOfDay( 0.5 )
	sm.render.setOutdoorLighting( 0.5 )

    -- Register /mod command
    local arguments = {
        { 'string', 'command', true }
    }
    for i=1, 100 do
        arguments[i + 1] = { 'string', 'arg'..i, true }
    end
    sm.game.bindChatCommand('/mod', arguments, 'cl_onInteropCommand', 'Executes a mod command')
end

function CreativeGame.server_onPlayerJoined( self, player, newPlayer )
    if sm.interop then
        sm.interop.events.emit('scrapmechanic:playerJoined', {
            player = player,
            newPlayer = newPlayer
        })
    end
end

function CreativeGame.cl_onChatCommand( self, params )
end

function CreativeGame.cl_onInteropCommand(self, params)
    if params[1] ~= '/mod' then
        -- Whut?
        return
    end
    if sm.interop == nil then
        sm.gui.chatMessage('#ff0000Error: #ffffffMod "sm.interop" is missing, or no part using the coremod has been placed in the world yet.')
        return
    end
    if not params[2] then
        sm.gui.chatMessage('#ff0000Syntax: #ffffff/mod <commandName> [arguments...]')
        return
    end
    local commandName = params[2]
    local args = {unpack(params, 3)}
    local success, error = pcall(sm.interop.commands.call, commandName, args)
    if not success then
        sm.gui.chatMessage('#ff0000Error: #ffffffAn error occurred while executing this command')
        print(error)
        return
    end
end
