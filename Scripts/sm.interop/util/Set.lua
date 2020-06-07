-- @public
local Set = {}

function Set.new(values)
    local map = {}

    -- Initiate
    for _,v in ipairs(values or {}) do
        map[v] = true
    end

    return {
        add = function(self, value)
            map[value] = true
        end,

        remove = function(self, value)
            map[value] = nil
        end,

        contains = function(self, value)
            return map[value] ~= nil
        end,

        toTable = function(self, value)
            local tbl = {}
            local index = 1
            for k,_ in pairs(map) do
                tbl[index] = k
                index = index + 1
            end
            return tbl
        end
    }
end

function Set:add(set, value)
    return set:add(value)
end

function Set:remove(value)
    return set:remove(value)
end

function Set:contains(value)
    return set:contains(value)
end

function Set:toTable()
    return set:toTable()
end

-- @export
sm.interop.util.Set = Set
