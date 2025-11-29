local Obstacles = {}
Obstacles.__index = Obstacles

function Obstacles.new()
    local instance = {
        list = {}
    }
    return setmetatable(instance, Obstacles)
end

function Obstacles.add(self, x, y, w, h)
    table.insert(self.list, {
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

function Obstacles.resolveCollision(self, entity)
    local px = entity.x
    local py = entity.y
    -- Assuming entity has w/h, or we use a default size for collision if not set
    -- Original code used player.w * 3 because of scaling. 
    -- We should probably handle scaling in View, but Model needs to know physical size.
    -- Let's assume entity.w/h are the PHYSICAL sizes (already scaled if needed).
    local pw = entity.w or 30
    local ph = entity.h or 30

    for _, o in ipairs(self.list) do
        if checkCollision(
            {x = px - pw/2, y = py - ph/2, w = pw, h = ph}, -- Centered anchor assumption from original code?
            -- Original: player.x is top-left? No, player.draw uses offset w/2, h/2, so x,y is center.
            -- Original resolveCollision: {x = px - pw/2 ...} -> Yes, x,y is center.
            o
        ) then
            -- Push entity out
            if px < o.x then entity.x = o.x - pw/2 end
            if px > o.x + o.w then entity.x = o.x + o.w + pw/2 end
            if py < o.y then entity.y = o.y - ph/2 end
            if py > o.y + o.h then entity.y = o.y + o.h + ph/2 end
        end
    end
end

function Obstacles.resolveCollisionSingle(self, entity)
    self:resolveCollision(entity)
end

return Obstacles
