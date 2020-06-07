-- @import
local Set = sm.interop.util.Set;
local assertArg = sm.interop.util.assertArgumentType

-- @private
local events = {}
local listeners = {}
local instanceToEventName = {}

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
events.listen = function(event, listenerFunction, priority, listenerClass)
    assertArg(1, event, 'string')
    assertArg(2, listenerFunction, 'function')

    event = event:lower()

    -- Register listener
    local listener = { listenerClass, listenerFunction }
    if not listeners[event] then
        listeners[event] = { listener }
    else
        if priority ~= nil then
            table.insert(listeners[event], priority, listener)
        else
            table.insert(listeners[event], listener)
        end
    end
end

---
-- @param event string
-- @param data  mixed
events.emit = function(event, data)
    assertArg(1, event, 'string')
    event = event:lower()

    local handlers = listeners[event] or {}
    local errors = {}
    local errorIndex = 1
    for i=1,#handlers do
        local handler = handlers[i]
        local result, error
        if handler[1] == nil then
            result, error = pcall(handler[2], data)
        else
            result, error = pcall(handler[2], handler[1], data)
        end
        if not result then
            errors[errorIndex] = error
            errorIndex = errorIndex + 1
        end
    end
    if errorIndex ~= 1 then
        print(errors, 'eee')
    end
end

-- @export
sm.interop.events = events
