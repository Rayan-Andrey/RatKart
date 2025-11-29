local RaceView = {}

function RaceView.load()
    -- Load Sprites
    RaceView.sprites = {
        car = {
            up = love.graphics.newImage("Sprites/car_up.png"),
            down = love.graphics.newImage("Sprites/car_down.png"),
            left = love.graphics.newImage("Sprites/car_left.png"),
            right = love.graphics.newImage("Sprites/car_right.png"),
            up_left = love.graphics.newImage("Sprites/car_up_left.png"),
            up_right = love.graphics.newImage("Sprites/car_up_right.png"),
            down_left = love.graphics.newImage("Sprites/car_down_left.png"),
            down_right = love.graphics.newImage("Sprites/car_down_right.png")
        },
        opponent = love.graphics.newImage("Sprites/Oponent.png"),
        wall = love.graphics.newImage("Sprites/wall.png"),
        checkpointA = love.graphics.newImage("Sprites/checkpoint_A.png"),
        checkpointB = love.graphics.newImage("Sprites/checkpoint_B.png"),
        speedup = love.graphics.newImage("Sprites/speedup_vertical.png")
    }

    -- Set dimensions in Models if needed (optional, but good for consistency)
    -- For now, we assume Models have reasonable defaults or we just draw at Model positions.
end

local function getPlayerSprite(rotation, sprites)
    local offset = math.pi
    local angle = (rotation + offset) % (2 * math.pi)
    local deg = math.deg(angle)

    if deg >= 337.5 or deg < 22.5 then return sprites.left
    elseif deg < 67.5 then return sprites.up_left
    elseif deg < 112.5 then return sprites.up
    elseif deg < 157.5 then return sprites.up_right
    elseif deg < 202.5 then return sprites.right
    elseif deg < 247.5 then return sprites.down_right
    elseif deg < 292.5 then return sprites.down
    elseif deg < 337.5 then return sprites.down_left
    end
    return sprites.down -- Default
end

function RaceView.draw(Race)
    -- Draw Obstacles
    for _, o in ipairs(Race.obstacles.list) do
        love.graphics.draw(RaceView.sprites.wall, o.x, o.y)
    end

    -- Draw Checkpoints
    for _, cp in ipairs(Race.checkpoints.list) do
        local sprite = (cp.id % 2 == 0) and RaceView.sprites.checkpointB or RaceView.sprites.checkpointA
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(sprite, cp.x, cp.y)
    end

    -- Draw Speedups
    for _, obj in ipairs(Race.speedup.list) do
        if obj.active then
            love.graphics.draw(RaceView.sprites.speedup, obj.x, obj.y)
        end
    end

    -- Draw Opponents
    for _, ai in ipairs(Race.opponents) do
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.draw(
            RaceView.sprites.opponent,
            ai.x, ai.y,
            ai.rotation,
            1, 1,
            ai.w / 2, ai.h / 2
        )
    end

    -- Draw Player
    love.graphics.setColor(1, 1, 1)
    local playerSprite = getPlayerSprite(Race.player.rotation, RaceView.sprites.car)
    love.graphics.draw(
        playerSprite,
        Race.player.x, Race.player.y,
        nil,
        2, 2, -- Scale 2x
        Race.player.w / 2, Race.player.h / 2
    )

    -- HUD
    love.graphics.setColor(1,1,1)
    love.graphics.print("Lap: " .. Race.checkpoints.lap, 20, 20)
    love.graphics.print("Next CP: " .. Race.checkpoints.order, 20, 40)
    love.graphics.print("Time: " .. string.format("%.2f", Race.checkpoints.raceTime), 20, 60)

    -- Final Results
    if Race.checkpoints.finished then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("🏁 RACE FINISHED! 🏁", 300, 120, 0, 2, 2)

        love.graphics.setColor(1, 1, 1)
        love.graphics.print("FINAL RESULTS:", 320, 170)

        for i, r in ipairs(Race.checkpoints.finishedRacers) do
            local line = r.position .. ". " .. r.name .. " - " .. string.format("%.2f s", r.time)
            love.graphics.print(line, 320, 200 + i * 20)
        end
    end
end

return RaceView
