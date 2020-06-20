-- @import
local Set = sm.interop.util.Set;
local assertArg = sm.interop.util.assertArgumentType

-- @private
local events = {}
local listeners = {}
local instanceToEventName = {}
local toServerEvents = {}
local toClientEvents = {}

local eventId = 1
local removedEventIds = {}

local getInstanceEventsSet = function(instance)
    local set = instanceToEventName[instance]
    if set == nil then
        instanceToEventName = Set.new()
    end
    return set
end

-- @public

--- Register a listener
-- @param event    string   The event this listener listens for
-- @param listener function The function that is to be executed when this event
-- @param priority Order in which it should be called
--                          is called.
function events.listen(event, listenerFunction, priority, listenerClass, targetEnvironment)
    assertArg(1, event, 'string')
    assertArg(2, listenerFunction, 'function')

    event = event:lower()

    -- Register listener
    local thisEventId = eventId
    eventId = eventId + 1
    local listener = { listenerClass, listenerFunction, thisEventId, targetEnvironment }
    if not listeners[event] then
        listeners[event] = { listener }
    else
        if priority ~= nil then
            table.insert(listeners[event], priority, listener)
        else
            table.insert(listeners[event], listener)
        end
    end
    return thisEventId
end

function events.remove(eventId)
    sm.log.warning('sm.interop.events.remove is deprecated, use .removeListener instead')
    events.removeListener(eventId)
end

function events.removeListener(eventId)
    removedEventIds[eventId] = true
end

function events.emit(event, data, targetEnvironment, sendAcrossNetwork)
    -- Arguments
    assertArg(1, event, 'string')
    event = event:lower()

    if targetEnvironment == nil then
        targetEnvironment = 'both'
    end
    assertArg(3, targetEnvironment, 'string')
    assert(targetEnvironment == 'client' or targetEnvironment == 'server' or targetEnvironment == 'both', 'targetEnvironment must be client, server or both (default)')

    if sendAcrossNetwork == nil then
        sendAcrossNetwork = false
    end
    assertArg(4, sendAcrossNetwork, 'boolean')

    local correctEnvironment = targetEnvironment == 'both' or (targetEnvironment == 'server') == sm.isServerMode()
    if correctEnvironment then
        local handlers = listeners[event] or {}
        for i=1,#handlers do
            local handler = handlers[i]
            if not removedEventIds[handler[3]] then
                if handler[4] == 'both' or sm.isServerMode() == (handler[4] == 'server') then
                    local result, error
                    if handler[1] == nil then
                        result, error = pcall(handler[2], data)
                    else
                        result, error = pcall(handler[2], handler[1], data)
                    end
                    if not result then
                        sm.log.error(error)
                    end
                end
            else
                handlers[i] = nil
            end
        end
    end

    local sendToDifferentEnvironment = targetEnvironment == 'both' or (targetEnvironment == 'client') == sm.isServerMode()
    if sendAcrossNetwork and sendToDifferentEnvironment then
        if sm.isServerMode() then
            toClientEvents[#toClientEvents + 1] = {
                name = event,
                data = data,
                targetEnvironment = targetEnvironment
            }
        else
            toServerEvents[#toServerEvents + 1] = {
                name = event,
                data = data,
                targetEnvironment = targetEnvironment
            }
        end
    end
end

function events.getSendToClientsEvents()
    local f = toClientEvents
    toClientEvents = {}
    return f
end

function events.getSendToServerEvents()
    local f = toServerEvents
    toServerEvents = {}
    return f
end

-- @export
sm.interop.events = events
