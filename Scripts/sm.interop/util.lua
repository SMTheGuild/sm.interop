sm.interop.util = {}

function sm.interop.util.getGamemode()
    if sm.event.sendToGame('server_loadLevel', {}) then
        return 'challenge'
    end

    if sm.event.sendToGame('sv_killPlayer', {}) then
        return 'survival'
    end

    return 'creative'
end

function sm.interop.util.clone(value, recursionLevel, scopeIndependentFunctions)
    recursionLevel = recursionLevel or 1
    scopeIndependentFunctions = scopeIndependentFunctions or false

    if recursionLevel > 255 then
        error('Recursion error in sm.interop.util.clone')
    end

    local vtype = type(value)
    if vtype == 'table' then
        local newTable = {}
        for k,v in pairs(value) do
            recursionLevel = recursionLevel + 1
            newTable[sm.interop.util.clone(k, recursionLevel)] = sm.interop.util.clone(v, recursionLevel)
        end
        return newTable
    elseif vtype == 'function' and not scopeIndependentFunctions then
        error('Can only deep-clone functions when scopeIndependentFunctions is set to true')
    end

    return value
end

function sm.interop.util.default(variable, default)
    if variable == nil then
        return default
    end
    return variable
end

function sm.interop.util.round(number, precision)
    precision = precision or 1
    return math.floor((number / precision) + 0.5) * precision
end

function sm.interop.util.wrapNumber(min, max, value)
    return min + ((value - min) % (max - min))
end

function sm.interop.util.contains(table, value)
    if type(table) ~= 'table' then
        error('Argument #1 to sm.interop.util.contains must be a table')
    end
    for _,v in pairs(table) do
        if value == v then
            return true
        end
    end
    return false
end

function sm.interop.util.assertArgumentType(n, argument, expectedType)
    local argumentType = type(argument)
    if type(expectedType) == 'string' then
        assert(argumentType == expectedType, 'Argument #' .. n .. ' expected ' .. expectedType .. ', got ' .. argumentType)
    elseif type(expectedType) == 'table' then
        local found = false
        for i,v in ipairs(expectedType) do
            if argumentType == v then
                found = true
                break
            end
        end
        if not found then
            error('Argument #' .. n .. ' expected any of ' .. table.concat(expectedType, ', ') .. ', got ' .. argumentType)
        end
    end
end

function sm.interop.util.getFullName(mod, name)
    return (mod:getNamespace() .. ':' .. name):lower()
end

function sm.interop.util.logpcall(...)
    local result, error = pcall(...)
    if not result then
        sm.log.error(error)
    end
end

dofile 'util/bits.lua'
dofile 'util/color.lua'
dofile 'util/Queue.lua'
dofile 'util/Set.lua'
dofile 'util/Ring.lua'
dofile 'util/Array.lua'
