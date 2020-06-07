-- @public
local bits = {}

function bits.has(a, bit)
    return a % (bit + bit) >= bit
end

function bits.size(a)
    return math.floor(math.log(a, 2)) + 1
end

function bits._and(a, b)
    local res = 0
    local bit = 1
    local continue = true
    while continue do
        continue = false
        if bits.has(a, bit) and bits.has(b, bit) then
            res = res + bit
        end
        if bit < a or bit < b then
            bit = bit + bit
            continue = true
        end
    end
    return res
end

function bits.nand(a, b)
    local res = 0
    local bit = 1
    local continue = true
    while continue do
        continue = false
        if not (bits.has(a, bit) and bits.has(b, bit)) then
            res = res + bit
        end
        if bit < a or bit < b then
            bit = bit + bit
            continue = true
        end
    end
    return res
end

function bits._or(a, b)
    local res = 0
    local bit = 1
    local continue = true
    while continue do
        continue = false
        if bits.has(a, bit) or bits.has(b, bit) then
            res = res + bit
        end
        if bit < a or bit < b then
            bit = bit + bit
            continue = true
        end
    end
    return res
end

function bits.nor(a, b)
    local res = 0
    local bit = 1
    local continue = true
    while continue do
        continue = false
        if not (bits.has(a, bit) or bits.has(b, bit)) then
            res = res + bit
        end
        if bit < a or bit < b then
            bit = bit + bit
            continue = true
        end
    end
    return res
end

function bits.xor(a, b)
    local res = 0
    local bit = 1
    local continue = true
    while continue do
        continue = false
        if bits.has(a, bit) ~= bits.has(b, bit) then
            res = res + bit
        end
        if bit < a or bit < b then
            bit = bit + bit
            continue = true
        end
    end
    return res
end

function bits.xnor(a, b)
    local res = 0
    local bit = 1
    local continue = true
    while continue do
        continue = false
        if bits.has(a, bit) == bits.has(b, bit) then
            res = res + bit
        end
        if bit < a or bit < b then
            bit = bit + bit
            continue = true
        end
    end
    return res
end

function bits.toString(a, len)
    -- If len is specified, pad to len
    if len ~= nil then
        local bit = 1
        local str = ''
        for i=1, len do
            if bits.has(a, bit) then
                str = '1' .. str
            else
                str = '0' .. str
            end
            bit = bit + bit
        end
        return str

    -- Otherwise, go as long as possible/necessary
    else
        local str = ''
        local bit = 1
        while bit <= a do
            if bits.has(a, bit) then
                str = '1' .. str
            else
                str = '0' .. str
            end
            bit = bit + bit
        end
        return str
    end
end

function bits.lshift(x, n)
    return x * 2 ^ n
end

function bits.rshift(x, n)
    return math.floor(x / 2 ^ n)
end

-- @export
sm.interop.util.bits = bits
