local Ring = {}

function Ring.init(_size, read_offset, default_value)
    local ring = {}
    local size = _size
    local read_pointer = read_offset % size or 0
    local write_pointer = 0

    for i = 0, size - 1 do
        ring[i] = default
    end

    return {
        write = function(self, value)
            ring[write_pointer] = value
            write_pointer = (write_pointer + 1) % size
        end,

        move = function(self)
            read_pointer = (read_pointer + 1) % size
        end,

        read = function(self, offset)
            offset = offset or 0
            return ring[(read_pointer + offset) % size]
        end
    }
end

function Ring:write(value)
    return self:write(value)
end

function Ring:move()
    return self:move()
end

function Ring:read(offset)
    return self:read(offset)
end

-- @export
sm.interop.util.Ring = Ring
