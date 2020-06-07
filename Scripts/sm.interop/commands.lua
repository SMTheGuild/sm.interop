-- @import
local assertArg = sm.interop.util.assertArgumentType
local mods = sm.interop.mods

-- @private
local commandRegistry = {}

local function chatError(message)
    sm.gui.chatMessage('#ff0000Error: #ffffff' .. message)
end

-- @public
local commands = {}

function commands.register(mod, commandName, handler)
    assertArg(1, mod, 'table')
    assertArg(2, commandName, 'string')
    assertArg(3, handler, 'function')

    mods.assertIsValid(mod)
    commandName = commandName:lower()
    local namespace = mod:getNamespace():lower()

    if commandRegistry[commandName] == nil then
        commandRegistry[commandName] = {
            ['#n'] = 0
        }
    end

    assert(commandRegistry[commandName][namespace] == nil, 'A command with this name was already registered by this mod');
    commandRegistry[commandName][namespace] = handler
    commandRegistry[commandName]['#n'] = commandRegistry[commandName]['#n'] + 1
end

function commands.call(commandName, args)
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
    handler(args)
end

-- @export
sm.interop.commands = commands
