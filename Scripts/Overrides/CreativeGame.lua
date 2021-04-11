dofile '$CONTENT_e94ac99f-393e-4816-abe3-353435a1edf4/Scripts/Overrides/attach.lua'

attachFunctionToObject(CreativeGame, 'client_onCreate', function(self)
    -- Register /mod command
    local arguments = {
        { 'string', 'command', true }
    }
    local nca = {}
    for i=1, 100 do
        local t = { 'string', 'arg'..i, true }
        arguments[i + 1] = t
        nca[i] = t
    end

    self.interop_newCommandArguments = nca

    sm.game.bindChatCommand('/mod', arguments, 'cl_onInteropCommand', 'Executes a mod command')
end)

attachFunctionToObject(CreativeGame, 'server_onPlayerJoined', function(self, player, newPlayer)
    if sm.interop ~= nil then
        -- Load startup scripts for this person
        self.network:sendToClient(player, 'cl_interopLoadStartups', {
            startupScripts = sm.interop.startup.getStartupScripts()
        })

        -- Emit playerJoined event
        sm.interop.events.emit('scrapmechanic:playerJoined', {
            player = player,
            newPlayer = newPlayer
        }, 'both', true)
    end
end)

attachFunctionToObject(CreativeGame, 'cl_interopLoadStartups', function(self, params)
    sm.interop.startup.restoreStartupScripts(params.startupScripts)
    self.network:sendToServer('sv_interopLoadStartups', {})
end)

attachFunctionToObject(CreativeGame, 'sv_interopLoadStartups', function(self, params)
    sm.interop.startup.startRunOldScripts()
end)

attachFunctionToObject(CreativeGame, 'client_onUpdate', function(self, dt)
    if sm.interop ~= nil then
        local toRegister = sm.interop.commands.getCommandsToRegister()
        if toRegister ~= nil then
            if v ~= 'mod' then
                for i,commandName in ipairs(toRegister) do
                    sm.game.bindChatCommand('/'..commandName, self.interop_newCommandArguments, 'cl_onInteropCommand2', 'Executes the '..commandName..' command')
                end
            end
        end
    end
end)

attachFunctionToObject(CreativeGame, 'cl_onInteropCommand', function(self, params)
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
    local world = sm.localPlayer.getPlayer():getCharacter():getWorld()
    self.network:sendToServer('sv_interopCommandExecute', {
        player = sm.localPlayer.getPlayer(),
        commandName = commandName,
        args = args
    })
    if sm.interopGamefileModVersion < 3 then
        sm.gui.chatMessage('#ff0000Error: Due to a bug, custom mod commands do not work in custom creative worlds. You have to update sm.interop in order to fix this. Go to the sm.interop Steam Workshop page to read how to do this.')
    end
end)

attachFunctionToObject(CreativeGame, 'cl_onInteropCommand2', function(self, params)
    if sm.interop == nil then
        sm.gui.chatMessage('#ff0000Error: #ffffffMod "sm.interop" is missing, or no part using the coremod has been placed in the world yet.')
        return
    end
    local commandName = params[1]:sub(2)
    local args = {unpack(params, 2)}
    self.network:sendToServer('sv_interopCommandExecute', {
        player = sm.localPlayer.getPlayer(),
        commandName = commandName,
        args = args
    })
    if sm.interopGamefileModVersion < 3 then
        sm.gui.chatMessage('#ff0000Error: Due to a bug, custom mod commands do not work in custom creative worlds. You have to update sm.interop in order to fix this. Go to the sm.interop Steam Workshop page to read how to do this.')
    end
end)

attachFunctionToObject(CreativeGame, 'sv_interopCommandExecute', function(self, params)
    local world = params.player:getCharacter():getWorld()
    sm.event.sendToWorld(world, 'sv_interopCommandExecute', params)
end)
