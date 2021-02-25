-- @import
local util = sm.interop.util
local bits = sm.interop.util.bits
local assertArg = util.assertArgumentType

-- @both
local connections = {}

-- @private
local partByInteractableId = {}
local typeDefinitions = {}
local uuidToInterfaces = {}
local partTypeWrappers = {}
local connectionTypeNum = sm.interop.connectionType

local function emptyFunction() end

local originalFixedUpdates = {}
local nParents = {}
local function onFixedUpdate(self, dt)
    local interactable = self.interactable
    local parents = interactable:getParents()
    -- Only update when parents change
    local nParentsNow = #parents
    if nParentsNow ~= nParents[self] then
        nParents[self] = nParentsNow
        local connectionInput = self.connectionInput
        local moddedConnectionInput = self.moddedConnectionInput
        for i,parent in ipairs(parents) do
            -- If there is no overlap in vanilla connection types, compare moddedConnectionInput/Output
            if bits._and(parent:getConnectionOutputType(), connectionInput) == connectionTypeNum then
                local parentPart = partByInteractableId[parent.id]
                local found = false

                -- Find overlapping moddedConnectionInput/Output
                if parentPart then
                    local parentPartOutput = parentPart.moddedConnectionOutput
                    for _,type in ipairs(moddedConnectionInput) do
                        if parentPartOutput[type] then
                            found = true
                            break
                        end
                    end
                end
                if not found then
                    parent:disconnect(interactable)
                end
            end
        end
    end
    return originalFixedUpdates[self](self, dt)
end
local function onFixedUpdateNoInputs(self, dt)
    local interactable = self.interactable
    local parents = interactable:getParents()
    local nParentsNow = #parents
    -- Only update when parents change
    if nParentsNow ~= nParents[self] then
        nParents[self] = nParentsNow
        local connectionInput = self.connectionInput
        for i,parent in ipairs(parents) do
            -- No only connection overlap is modded, disconnect
            if bits._and(parent:getConnectionOutputType(), connectionInput) == connectionTypeNum then
                parent:disconnect(interactable)
            end
        end
    end
    return originalFixedUpdates[self](self, dt)
end

local function createInterop(interactable)
    return {
        interactable = interactable,
        getParentsByType = connections.getParentsByType,
        getSingleParentByType = connections.getSingleParentByType,
        getChildrenByType = connections.getChildrenByType,
        getOutputTypes = connections.getOutputTypes,
        getInputTypes = connections.getInputTypes
    }
end

local function getInteractable(interactable)
    if type(interactable) == 'Interactable' then
        return interactable
    end
    if type(interactable) == 'table' and type(interactable.interactable) == 'Interactable' then
        return interactable.interactable
    end
    return nil
end

local function assertArgInteractable(n, interactable)
    assert(getInteractable(interactable) ~= nil, 'Argument #'..n..' expected Interactable or compatible type, got ' .. type(interactable))
end

local function getPartClass(interactable)
    interactable = getInteractable(interactable)
    return partByInteractableId[interactable.id]
end

--- Creates a wrapper that uses the interactable->part cache
-- to make functions callable using interactable instead of shape class
-- fnc(interactable, ...) --> fnc(self, ...)
local function wrapInterfaces(p)
    -- TODO Check if all methods are defined, etc.
    local wrappers = {}
    for k,v in pairs(p.moddedConnectionOutput or {}) do
        local wrapper = {}
        for methodName,fnc in pairs(v) do
            wrapper[methodName] = function(interactable, ...)
                return fnc(getPartClass(interactable), ...)
            end
        end
        wrappers[k] = wrapper
    end
    return wrappers
end

local function getPartTypeInterface(part, interactableType)
    assertArg(2, interactableType, 'string')

    interactableType = interactableType:lower()
    -- If it exists in cache, return
    if partTypeWrappers[part] and partTypeWrappers[part][interactableType] then
        return partTypeWrappers[part][interactableType]
    end

    -- Otherwise, create
    print('[sm.interop] Creating ' .. interactableType .. ' interface for Interactable #' .. part.interactable.id)

    if
        type(part) == 'table' and
        type(part.moddedConnectionOutput) == 'table' and
        part.moddedConnectionOutput[interactableType] ~= nil
    then
        -- Get wrapped interface for this shape type
        local uuidstr = tostring(part.shape.uuid)
        if uuidToInterfaces[uuidstr] ~= nil then
            interface = class(uuidToInterfaces[uuidstr][interactableType])
            interface.interactable = part.interactable

            -- Cache
            if not partTypeWrappers[part] then
                partTypeWrappers[part] = { [interactableType] = interface }
            else
                partTypeWrappers[part][interactableType] = interface
            end
            return interface
        end
    end
end

-- @public
function connections.register(mod, name, definition)
    sm.interop.mods.assertIsValid(mod)
    local fn = util.getFullName(mod, name):lower()
    assert(typeDefinitions[fn] == nil, 'A type with this name was already registered by this mod')
    typeDefinitions[fn] = definition
end

function connections.registerShape(mod, partClass)
    assertArg(1, mod, 'table')
    assertArg(2, partClass, 'table')

    sm.interop.server.createIfNecessary()
    sm.interop.mods.assertIsValid(mod)
    -- TODO: Decide whether registerShape must be able to overwrite
    -- if partByInteractableId[partClass.interactable] ~= nil then
        -- error('This shape was already registered')
    -- end
    partByInteractableId[partClass.interactable.id] = partClass

    -- Register interfaces if they don't exist yet
    local uuidstr = tostring(partClass.shape.uuid)
    if uuidToInterfaces[uuidstr] == nil then
        uuidToInterfaces[uuidstr] = wrapInterfaces(partClass)
    end

    -- Add Parent check to server_onFixedUpdate
    if partClass.connectionInput and bits.has(partClass.connectionInput, connectionTypeNum) then
        originalFixedUpdates[partClass] = partClass.server_onFixedUpdate or emptyFunction

        -- Edge case: no inputs defined: remove all modded connections
        if partClass.moddedConnectionInput == nil or #partClass.moddedConnectionInput == 0 then
            partClass.server_onFixedUpdate = onFixedUpdateNoInputs
        else
            partClass.server_onFixedUpdate = onFixedUpdate
        end
    end

    return createInterop(partClass.interactable)
end

function connections.getVanillaTypes(interactable)
    local part = getPartClass(interactable)
    local types = {}
    local n = part.connectionOutput
    for k,v in pairs(sm.interactable.connectionType) do
        if bits.has(n, v) then
            types[#types + 1] = k
        end
    end
    return types
end

function connections.simpleInterface(mapping)
    -- Validate argument types
    assertArg(1, mapping, 'table')

    -- Create interface
    local interface = {}
    for fncInterface,fncPart in pairs(mapping) do
        interface[fncInterface] = function(part, ...)
            return part[fncPart](part, ...)
        end
    end
    return interface
end

function connections.getTypes(interactable)
    local part = getPartClass(interactable)
    local types = connections.getVanillaTypes(interactable)
    for k,v in pairs(part.moddedConnectionOutput) do
        types[#types + 1] = k
    end
    return types
end

function connections.getParentsByType(interactable, interactableType)
    assertArgInteractable(1, interactable)
    assertArg(2, interactableType, 'string')

    interactableType = interactableType:lower()
    interactable = getInteractable(interactable)

    -- TODO Decide whether getParentsByType() must also be available for non-scripted objects
    assert(interactable:getType() == 'scripted', 'This interactable is not scripted')

    local part = getPartClass(interactable)
    assert(part ~= nil, 'Could not find sm.interop data for this interactable')
    assert(type(part.moddedConnectionInput) == 'table' and util.contains(part.moddedConnectionInput, type) ~= nil, 'Type "'.. interactableType ..'" is not in moddedConnectionInput for this interactable')

    local parents = {}
    for k,v in ipairs(part.interactable:getParents()) do
        -- If <type> is a vanilla type (logic, engine, seat, scripted, w/e)
        -- use v:getType() check
        if v:getType() == interactableType then
            parents[#parents + 1] = v

        -- If it is a custom type, get part class moddedConnectionOutput and
        -- use that for check
        else
            local p = getPartTypeInterface(getPartClass(v), interactableType)
            if p ~= nil then
                parents[#parents + 1] = p
            end
        end
    end
    return parents
end

function connections.getInterfaceByType(interactable, interactableType)
    assertArgInteractable(1, interactable)
    assertArg(2, interactableType, 'string')

    interactableType = interactableType:lower()
    interactable = getInteractable(interactable)

    -- TODO Decide whether getParentsByType() must also be available for non-scripted objects
    assert(interactable:getType() == 'scripted', 'This interactable is not scripted')

    local part = getPartClass(interactable)
    assert(part ~= nil, 'Could not find sm.interop data for this interactable')
    assert(type(part.moddedConnectionOutput) == 'table' and util.contains(part.moddedConnectionOutput, type) ~= nil, 'Type "'.. interactableType ..'" is not in moddedConnectionOutput for this interactable')

    return getPartTypeInterface(part, interactableType)
end

function connections.getChildrenByType(interactable, interactableType)
    assertArgInteractable(1, interactable)
    assertArg(2, interactableType, 'string')

    interactableType = interactableType:lower()
    interactable = getInteractable(interactable)

    -- TODO Decide whether getParentsByType() must also be available for non-scripted objects
    assert(interactable:getType() == 'scripted', 'This interactable is not scripted')

    local part = getPartClass(interactable)
    assert(part ~= nil, 'Could not find sm.interop data for this interactable')
    assert(type(part.moddedConnectionOutput) == 'table' and util.contains(part.moddedConnectionOutput, type) ~= nil, 'Type "'.. interactableType ..'" is not in moddedConnectionOutput for this interactable')

    local children = {}
    for k,v in ipairs(part.interactable:getChildren()) do
        -- If <type> is a vanilla type (logic, engine, seat, scripted, w/e)
        -- use v:getType() check
        if v:getType() == interactableType then
            parents[#parents + 1] = v

        -- If it is a custom type, get part class moddedConnectionOutput and
        -- use that for check
        else
            local p = getPartTypeInterface(getPartClass(v), interactableType)
            if p ~= nil then
                children[#children + 1] = p
            end
        end
    end
    return children
end

function connections.getSingleParentByType(interactable, interactableType)
    assertArgInteractable(1, interactable)
    assertArg(2, interactableType, 'string')

    interactable = getInteractable(interactable)
    assert(interactable:getMaxParentCount() == 1, 'getSingleParentByType can only be used for interactables that have maxParentCount = 1')
    local parents = connections.getParentsByType(interactable, interactableType)
    return parents[1]
end

-- @export
sm.interop.connections = connections
