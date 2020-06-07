-- @import
local contains = sm.interop.util.contains

-- @private
local function iterator(array, index)
    local value = array[index]
    if value ~= nil then
        return index + 1, value
    end
end

-- @public
local Array = {}

function Array:iterator()
    return iterator, self, 1
end

function Array:add(value)
    self[#self + 1] = value
end

function Array:addAll(array)
    local offset = #self
    for i,v in ipairs(array) do
        self[offset + i] = v
    end
end

function Array:insertAt(position, value)
    assert(type(position) == 'number', 'Position must be a number')
    local old = self[position]
    self[position] = value
    while old ~= nil do
        local new = old
        position = position + 1
        old = self[position]
        self[position] = new
    end
end

function Array:removeAt(position)
    assert(type(position) == 'number' and position > 0, 'Position must be a number and must be at least 1')
    local ret = self[position]
    self[position] = nil
    while self[position + 1] ~= nil do
        self[position] = self[position + 1]
        position = position + 1
    end
    self[position] = nil
    return ret
end

function Array:indexOf(value)
    for k,v in ipairs(self) do
        if value == v then
            return k
        end
    end
end

function Array:remove(value)
    local position = Array.indexOf(self, value)
    if position ~= nil then
        return Array.removeAt(self, position)
    end
end

Array.contains = contains

function Array.new(...)
    local base = {...}
    base.addAll = Array.addAll
    base.add = Array.add
    base.iterator = Array.iterator
    base.insertAt = Array.insertAt
    base.removeAt = Array.removeAt
    base.indexOf = Array.index
    base.remove = Array.remove
    return base
end

-- @export
sm.interop.util.Array = Array
