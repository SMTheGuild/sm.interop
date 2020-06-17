-- @import
local assertArg = sm.interop.util.assertArgumentType
local logpcall = sm.interop.util.logpcall
local getFullName = sm.interop.util.getFullName

-- @private
local registry = {}
local awaiting = {}

-- @public
local services = {}

-- Registers a service
-- @param mod Mod
-- @param name The name of this service
-- @param service Table with public API functions
-- @return The full name of the service
function services.register(mod, name, service)
    assertArg(1, mod, 'table')
    assertArg(2, name, 'string')
    assertArg(3, service, 'table')

    sm.interop.mods.assertIsValid(mod)

    local id = getFullName(mod, name)
    id = id:lower()

    assert(registry[id] == nil, 'A service with this name is already registered')

    registry[id] = service

    -- Run functions that called services.use(service, fnc) before the service
    -- was registered
    if awaiting[id] then
        for i,v in ipairs(awaiting[id]) do
            logpcall(v, service)
        end
    end

    return id
end

--- Gets a service object
-- @parram name The full name of the service (including mod namespace)
-- @return The service object or nil if it is not registered
function services.get(name)
    assertArg(1, name, 'string')

    name = name:lower()
    return registry[name]
end

function services.use(name, fnc)
    assertArg(1, name, 'string')
    assertArg(2, fnc, 'function')

    name = name:lower()
    if registry[name] then
        fnc(registry[name])
    else
        local t = awaiting[name] or {}
        awaiting[name] = t
        t[#t + 1] = fnc
    end
end

-- @export
sm.interop.services = services
