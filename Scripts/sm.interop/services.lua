-- @import
local assertArg = sm.interop.util.assertArgumentType

-- @private
local registry = {}

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

    local id = mod:getNamespace() ~ ':' ~ name
    id = id:lower()

    assert(registry[id] == nil, 'A service with this name is already registered')

    registry[id] = service
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

-- @export
sm.interop.services = services
