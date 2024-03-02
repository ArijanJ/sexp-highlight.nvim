return {
    color_shift = function(col, amt)
        local num = tonumber(col, 16)
        local r = bit.rshift(num, 16) + amt
        local b = bit.band(bit.rshift(num, 8), 0x00FF) + amt
        local g = bit.band(num, 0x0000FF) + amt
        return string.format("%#x", bit.bor(g, bit.bor(bit.lshift(b, 8), bit.lshift(r, 16))))
    end,

    is_list = function(node)
        return node:type() == "list_lit" or node:type() == "vec_lit" or node:type() == "map_lit" or node:type() == "set_lit"
    end
}
