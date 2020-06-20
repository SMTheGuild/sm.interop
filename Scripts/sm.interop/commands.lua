-- @import
local assertArg = sm.interop.util.assertArgumentType
local getFullName = sm.interop.util.getFullName
local mods = sm.interop.mods

-- @private
local commandRegistry = {}
local commandsToRegister = {}
local commandDescriptions = {}

local function chatError(message)
    sm.gui.chatMessage('#ff0000Error: #ffffff' .. message)
end

local function wrapNetwork(network, modName, commandName)
    return {
        setClientData = function() error('Not implemented') end,
        sendToClient = function(self, player, functionName, params)
            assertArg(2, player, 'Player')
            assertArg(3, functionName, 'string')
            network:sendToClient(player, 'sv_cl_interopCommandSubFunction', {
                modName = modName,
                commandName = commandName,
                functionName = functionName,
                params = params
            })
        end,
        sendToClients = function(self, functionName, params)
            assertArg(2, functionName, 'string')
            network:sendToClients(player, 'sv_cl_interopCommandSubFunction', {
                modName = modName,
                commandName = commandName,
                functionName = functionName,
                params = params
            })
        end,
        sendToServer = function(self, functionName, params)
            assertArg(2, functionName, 'string')
            network:sendToServer('sv_cl_interopCommandSubFunction', {
                modName = modName,
                commandName = commandName,
                functionName = functionName,
                params = params
            })
        end
    }
end

-- @public
local commands = {}

function commands.register(mod, commandName, handler, description)
    assertArg(1, mod, 'table')
    assertArg(2, commandName, 'string')

    mods.assertIsValid(mod)
    commandName = commandName:lower()

    local fn = getFullName(mod, commandName)
    assert(type(handler) == 'function' or (type(handler) == 'table' and type(handler.client_onCall) == 'function'), 'Handler for '..fn..' must be function or command handler class')

    if commandsToRegister == nil then
        commandsToRegister = {}
    end

    if commandRegistry[commandName] == nil then
        commandRegistry[commandName] = { ['#n'] = 0 }
        commandsToRegister[#commandsToRegister + 1] = commandName
    end

    local namespace = mod:getNamespace():lower()
    assert(commandRegistry[commandName][namespace] == nil, 'A command with this name was already registered by this mod');
    commandRegistry[commandName][namespace] = handler
    commandRegistry[commandName]['#n'] = commandRegistry[commandName]['#n'] + 1

    commandsToRegister[#commandsToRegister + 1] = namespace..':'..commandName
end

function commands.getCommandsToRegister()
    local f = commandsToRegister
    commandsToRegister = nil
    return f
end

function commands.call(commandName, args, network)
    local colonIndex = commandName:find(':', 0, true)
    local modName = nil
    if colonIndex ~= nil then
        modName = commandName:sub(1, colonIndex - 1)
        commandName = commandName:sub(colonIndex + 1)
    end
    if commandRegistry[commandName] == nil then
        chatError('This command does not exist.')
        return
    end
    local handler = nil
    if modName == nil then
        if commandRegistry[commandName]['#n'] > 1 then
            local commandNames = {}
            for k,v in pairs(commandRegistry[commandName]) do
                if k ~= '#n' then
                    commandNames[#commandNames + 1] = k .. ':' .. commandName
                end
            end
            chatError('Multiple mods define this command. Please specify the command name as one of the following:\n- /mod ' ..
                    table.concat(commandNames, '\n- /mod '))
            return
        end
        for k,v in pairs(commandRegistry[commandName]) do
            if k ~= '#n' then
                modName = k
                handler = v
                break
            end
        end
    else
        local command = commandRegistry[commandName]
        if command == nil or command[modName] == nil then
            chatError('This command does not exist.')
            return
        end
        handler = command[modName]
    end
    if type(handler) == 'table' then
        handler.network = wrapNetwork(network, modName, commandName)
        handler.client_onCall(handler, args)
    else
        handler(args)
    end
end

function commands.callSubFunction(modName, commandName, functionName, params)
    local obj = commandRegistry[commandName][modName]
    if type(obj) ~= 'table' then
        error('Cannot call sub function on function handler')
    end
    if type(obj[functionName]) ~= 'function' then
        error('Attempting to call non-existent '.. functionName .. ' on '.. commandName .. ' Commamnd class')
    end
    obj[functionName](obj, params)
end

-- @export
sm.interop.commands = commands
