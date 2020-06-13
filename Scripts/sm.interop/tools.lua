-- @import
local assertArg = sm.interop.util.assertArgumentType
local util = sm.interop.util
local mods = sm.interop.mods

-- @private
local toolRegistry = {}
local toolShapes = {}
local toolsState = {
    creatingToolClass = nil
}

-- @public
local tools = {}

function tools.register(mod, name, fileName)
    assertArg(1, mod, 'table')
    assertArg(2, name, 'string')
    assertArg(3, fileName, 'string')

    mods.assertIsValid(mod)
    local fullName = util.getFullName(mod, name):lower()
    fileName = '$CONTENT_'..tostring(mod:getUuid())..'/'..fileName

    toolsState.creatingToolClass = nil
    dofile(fileName)
    local tool = toolsState.creatingToolClass
    assert(tool ~= nil, 'Class was not created using sm.interop.tools.createClass([parent]) in ' .. fileName)
    toolRegistry[fullName] = tool
    print('Registered tool under name "'.. fullName..'"')
end

function tools.createClass(parent)
    local cls = class(parent)
    toolsState.creatingToolClass = cls
    return cls
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
    local tool = class(toolRegistry[toolInfo[1]])
    tool.data = toolInfo[1]
    return tool
end

-- @export
sm.interop.tools = tools
