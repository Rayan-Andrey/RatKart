local obstacles = {}
local player = require("player")
obstacles.list = {}
obstacles.sprite = nil

-- Create a new obstacle
function obstacles.new(x, y, w, h)
    table.insert(obstacles.list, {
        x = x,
        y = y,
        w = w,
        h = h
    })
end

-- Basic AABB collision check
local function checkCollision(a, b)
    return a.x < b.x + b.w and
           b.x < a.x + a.w and
           a.y < b.y + b.h and
           b.y < a.y + a.h
end

-- Load obstacle sprite and create sample obstacles
function obstacles.load()
    obstacles.sprite = love.graphics.newImage("Sprites/wall.png")  -- your sprite file

    local tileW = obstacles.sprite:getWidth()
    local tileH = obstacles.sprite:getHeight()

    -- Example walls (you add more as you want)
    obstacles.new(100, 100, tileW, tileH)
    obstacles.new(200, 300, tileW, tileH)
    obstacles.new(400, 180, tileW, tileH)
end

-- Prevent player from going inside obstacles
function obstacles.resolveCollision(player)
    local px = player.x
    local py = player.y
    local pw = player.w * 3   -- because you scaled sprite (3x)
    local ph = player.h * 3

    for _, o in ipairs(obstacles.list) do
        if checkCollision(
            {x = px - pw/2, y = py - ph/2, w = pw, h = ph},
            o
        ) then
            -- Push player out (simple but works)
            if px < o.x then player.x = o.x - pw/2 end
            if px > o.x + o.w then player.x = o.x + o.w + pw/2 end
            if py < o.y then player.y = o.y - ph/2 end
            if py > o.y + o.h then player.y = o.y + o.h + ph/2 end
        end
    end
end

-- Draw obstacles
function obstacles.draw()
    for _, o in ipairs(obstacles.list) do
        love.graphics.draw(obstacles.sprite, o.x, o.y)
    end
end

return obstacles
