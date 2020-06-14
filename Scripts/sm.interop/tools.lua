-- @import
local assertArg = sm.interop.util.assertArgumentType
local util = sm.interop.util
local mods = sm.interop.mods

-- @private
local toolRegistry = {}
local toolShapes = {}
local toolsState = {
    createToolClasses = {},
    createToolClassVars = {},
    currentModNamespace = nil
}

-- @public
local tools = {}

function tools.register(mod, name, fileName, className)
    assertArg(1, mod, 'table')
    assertArg(2, name, 'string')
    assertArg(3, fileName, 'string')
    assertArg(4, className, 'string')

    mods.assertIsValid(mod)
    local fullName = util.getFullName(mod, name):lower()
    fileName = '$CONTENT_'..tostring(mod:getUuid())..'/'..fileName

    local ns = mod:getNamespace():lower()
    toolsState.currentModNamespace = ns
    local createdClasses = toolsState.createToolClasses[ns]
    if createdClasses == nil then
        createdClasses = {}
        toolsState.createToolClasses[ns] = createdClasses
    end

    dofile(fileName)
    local tool = createdClasses[className]
    assert(tool ~= nil, 'Class was not created using sm.interop.tools.createClass(className, [parent]) in ' .. fileName)

    toolRegistry[fullName] = tool
    print('Registered tool under name "'.. fullName..'"')
end

function tools.createClass(name, parent)
    assertArg(1, name, 'string')
    if parent ~= nil then
        assertArg(2, parent, 'table')
    end

    local createdClasses = toolsState.createToolClasses[toolsState.currentModNamespace]
    if createdClasses == nil then
        createdClasses = {}
        toolsState.createToolClasses[toolsState.currentModNamespace] = createdClasses
    end

    local toolClass = createdClasses[name]
    if toolClass == nil then
        toolClass = class(parent)
        createdClasses[name] = toolClass
    end
    return toolClass
end

function tools.attach(name, shapeUuid, data)
    assertArg(1, name, 'string')
    assertArg(2, shapeUuid, 'Uuid')
    data = data or {}

    local uuidString = tostring(shapeUuid)
    name = name:lower()

    assert(toolRegistry[name] ~= nil, '"' .. name .. '" is not a registered tool')
    assert(toolShapes[uuidString] == nil, sm.shape.getShapeTitle(shapeUuid) .. ' is already attached to a tool')

    toolShapes[uuidString] = { name, data }
end

function tools.getToolClass(shapeUuid)
    assertArg(1, shapeUuid, 'Uuid')

    local uuidString = tostring(shapeUuid)
    local toolInfo = toolShapes[uuidString]
    if toolInfo == nil or not toolRegistry[toolInfo[1]] then
        return nil
    end
    local tool = toolRegistry[toolInfo[1]]
    tool.data = toolInfo[2]
    return tool
end

function tools.getToolData(shapeUuid)
    assertArg(1, shapeUuid, 'Uuid')

    local uuidString = tostring(shapeUuid)
    local toolInfo = toolShapes[uuidString]
    if toolInfo == nil or not toolRegistry[toolInfo[1]] then
        return nil
    end
    return toolInfo[2]
end

-- @export
sm.interop.tools = tools
