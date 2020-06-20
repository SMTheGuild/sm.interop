local oldCreate = CreativeGame.client_onCreate

function CreativeGame.client_onCreate(self)
    oldCreate(self)

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
    local success, error = pcall(sm.interop.commands.call, commandName, args, self.network)
    if not success then
        sm.gui.chatMessage('#ff0000Error: #ffffffAn error occurred while executing this command')
        print(error)
        return
    end
end

function CreativeGame.sv_cl_commandSubFunction(self, params)
    sm.interop.commands.callSubFunction(params.modName, params.commandName, params.functionName, params.params)
end