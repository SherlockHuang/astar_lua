local map = {
--    1  2  3  4  5  6  7  8  9  10 x/y
    { 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, }, -- 1
    { 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, }, -- 2
    { 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, }, -- 3
    { 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, }, -- 4
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, }, -- 5
    { 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, }, -- 6
    { 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, }, -- 7
    { 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, }, -- 8
    { 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, }, -- 9
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, }, -- 10
}

local max_x = 10
local max_y = 10

local function is_in_map(x, y)
    return x > 0 and x <= max_x
        and y > 0 and y <= max_y
end

local function get_H(p, ep)
    return math.abs(ep.x - p.x) + math.abs(ep.y - p.y)
end

local function get_F(p, ep)
    return get_H(p, ep) + p.G
end

local function pos(x, y, parent)
    local G = 0
    if parent then
        G = parent.G + 1
    end

    return {
        x = x,
        y = y,
        parent = parent,
        G = G,
    }
end


local function equal(p1, p2)
    return p1.x == p2.x and p1.y == p2.y
end

local function is_end(p, ep)
    return equal(p, ep)
end

local function is_start(p, sp)
    return equal(p, sp)
end

local function is_empty(x, y)
    return map[y][x] == 0
end

local function is_barrier(x, y)
    return map[y][x] == 1
end

local function hash(x, y)
    return (x - 1) * 10 + y - 1
end

local function is_close(close, x, y)
    local k = hash(x, y)
    return close[k] ~= nil
end

local function add_close(close, p)
    local k = hash(p.x, p.y)
    close[k] = p
end

local function is_open(open, x, y)
    local k = hash(x, y)
    return open[k] ~= nil
end

local function add_open(open, p)
    local k = hash(p.x, p.y)
    open[k] = p
end

local function get_open(open, x, y)
    local k = hash(x, y)
    return open[k]
end

-- use a priority queue will be better
local function pick(open, ep)
    local f, ret, idx
    for k, p in pairs(open) do
        local pf = get_F(p, ep)
        if not f or pf < f then
            f = pf
            ret = p
            idx = k
        end
    end

    open[idx] = nil

    return ret
end

local function visit(picked, i, j, close, open)
    local x = picked.x + i
    local y = picked.y + j

    local in_map = is_in_map(x, y)
    local empty = in_map and is_empty(x, y)
    local not_close = empty and not is_close(close, x, y)

    if not_close then
        local p = pos(x, y, picked)

        if is_open(open, p.x, p.y) then
            local op = get_open(open, x, y)
            if op.G > p.G then
                op.G = p.G
                op.parent = p.parent
            end
        else
            add_open(open, p)
        end
    end
end

local function mark_from_to(map, from, to)
    map[from.y][from.x] = '*'
    map[to.y][to.x] = '$'
end

local function mark_path(map, to)
    local p = to.parent
    while p.parent do
        map[p.y][p.x] = '#'
        p = p.parent
    end
end

local function draw(map)
    for y, arr_x in ipairs(map) do
        for x, v in ipairs(arr_x) do
            io.write((v) .. ' ')
        end
        io.write('\n')
    end
end

local function astar(from, to)
    assert(is_empty(from.x, from.y))
    assert(is_empty(to.y, to.y))

    local close = {}
    local open = {}
    add_open(open, from)

    local count = 0
    while next(open) do
        local picked = pick(open, to)
        if not picked then
            break
        end

        if is_end(picked, to) then
            to.G = picked.G
            to.parent = picked.parent

            break
        end

        visit(picked,  0, -1, close, open)
        visit(picked,  0,  1, close, open)
        visit(picked, -1,  0, close, open)
        visit(picked,  1,  0, close, open)

        add_close(close, picked)
        count = count + 1
    end

    if equal(from, to) then
        print('from == to')
        return
    end

    if not to.parent then
        print('no path')
        return
    end

    print(string.format('G = %d, count = %d', to.G, count))
    mark_from_to(map, from, to)
    draw(map)

    print('--------------------------')

    mark_path(map, to)
    draw(map)
end

local pf = pos(3, 3)
local pt = pos(9, 8)
astar(pf, pt)
