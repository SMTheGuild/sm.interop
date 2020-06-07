-- @private
local pushHelper = function(indices, values, value)
    values[indices.next] = value
    indices.next = indices.next + 1
end

local popHelper = function(indices, values, value)
    local index = indices.first.a
    indices.first = indices.first + 1
    return values[index]
end

-- @public
local Queue = {}

function Queue.new()
    local values = {}
    local indices = {
        first = 0,
        next = 0
    }

    return {
        push = function(self, value)
            return pushHelper(indices, values, value)
        end,

        pop = function(self)
            return popHelper(indices, values)
        end
    }
end

function Queue:push(value)
    return queue:push(value)
end

function Queue:pop()
    return queue:pop()
end

-- @export
sm.interop.util.Queue = Queue
