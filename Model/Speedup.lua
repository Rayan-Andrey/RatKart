local Speedup = {}
Speedup.__index = Speedup

function Speedup.new()
    local instance = {
        list = {},
        duration = 2,
        boostAmount = 200,
        respawnTime = 4,
        w = 32, -- Default size, will be overwritten or used
        h = 32
    }
    return setmetatable(instance, Speedup)
end

function Speedup.add(self, x, y, spriteType)
    table.insert(self.list, {
        x = x,
        y = y,
        spriteType = spriteType,
        active = true,
        timer = 0
    })
end

local function collides(a, b)
    return a.x < b.x + b.w and
           b.x < a.x + a.w and
           a.y < b.y + b.h and
           b.y < a.y + a.h
end

function Speedup.update(self, dt, player)
    -- Handle boost timer
    if player.boostTime and player.boostTime > 0 then
        player.boostTime = player.boostTime - dt
        if player.boostTime <= 0 then
            player.topSpeed = player.originalTopSpeed
        end
    end

    -- Player hitbox
    local pw = player.w
    local ph = player.h
    local px = player.x - pw/2
    local py = player.y - ph/2

    for _, obj in ipairs(self.list) do
        -- If the object is inactive, count down respawn timer
        if not obj.active then
            obj.timer = obj.timer - dt
            if obj.timer <= 0 then
                obj.active = true
            end
        end

        -- If active, check collision
        if obj.active then
            if collides(
                { x = px, y = py, w = pw, h = ph },
                { x = obj.x, y = obj.y, w = self.w, h = self.h }
            ) then
                -- Disable it
                obj.active = false
                obj.timer = self.respawnTime

                -- Apply player boost
                player.originalTopSpeed = player.originalTopSpeed or player.topSpeed
                player.topSpeed = player.originalTopSpeed + self.boostAmount
                player.boostTime = self.duration
            end
        end
    end
end

return Speedup
