local player = {}
local checkpoints = require("checkpoints")

function player.movement(dt)
    -- Turning
    if love.keyboard.isDown("left") then
        player.rotation = player.rotation - player.turnSpeed * dt
    elseif love.keyboard.isDown("right") then
        player.rotation = player.rotation + player.turnSpeed * dt
    end

    -- Acceleration / reverse / brake
    if love.keyboard.isDown("z") then
        player.speed = math.min(player.speed + player.acceleration * dt, player.topSpeed)
    elseif love.keyboard.isDown("x") then
        player.speed = math.max(player.speed - player.acceleration * dt, -player.topSpeed / 2)
    elseif love.keyboard.isDown("space") then
        if player.speed > 0 then
            player.speed = math.max(0, player.speed - player.brakeForce * dt)
        elseif player.speed < 0 then
            player.speed = math.min(0, player.speed + player.brakeForce * dt)
        end
    else
        if player.speed > 0 then
            player.speed = math.max(0, player.speed - player.friction * dt)
        elseif player.speed < 0 then
            player.speed = math.min(0, player.speed + player.friction * dt)
        end
    end

    -- Movement (forward direction)
    player.x = player.x + math.cos(player.rotation) * player.speed * dt
    player.y = player.y + math.sin(player.rotation) * player.speed * dt
end

function player.getSpriteForRotation(rotation)
    local offset = math.pi
    local angle = (rotation + offset) % (2 * math.pi)
    local deg = math.deg(angle)

    if deg >= 337.5 or deg < 22.5 then
        return player.sprites.left
    elseif deg < 67.5 then
        return player.sprites.up_left
    elseif deg < 112.5 then
        return player.sprites.up
    elseif deg < 157.5 then
        return player.sprites.up_right
    elseif deg < 202.5 then
        return player.sprites.right
    elseif deg < 247.5 then
        return player.sprites.down_right
    elseif deg < 292.5 then
        return player.sprites.down
    elseif deg < 337.5 then
        return player.sprites.down_left
    end
end


function player.load()
    love.graphics.setDefaultFilter("nearest","nearest")

    -- DO NOT overwrite the module table
    player.x = 200
    player.y = 200
    player.speed = 0
    player.acceleration = 200
    player.topSpeed = 300
    player.friction = 150
    player.brakeForce = 400
    player.rotation = 0
    player.turnSpeed = 3
    player.originalTopSpeed = player.topSpeed
    player.boostTime = 0

    player.sprites = {
        up = love.graphics.newImage("Sprites/car_up.png"),
        down = love.graphics.newImage("Sprites/car_down.png"),
        left = love.graphics.newImage("Sprites/car_left.png"),
        right = love.graphics.newImage("Sprites/car_right.png"),
        up_left = love.graphics.newImage("Sprites/car_up_left.png"),
        up_right = love.graphics.newImage("Sprites/car_up_right.png"),
        down_left = love.graphics.newImage("Sprites/car_down_left.png"),
        down_right = love.graphics.newImage("Sprites/car_down_right.png")
    }

    player.w = player.sprites.up:getWidth()
    player.h = player.sprites.up:getHeight()
end

function player.update(dt)
        -- Stop all gameplay once checkpoints.finish = true
    if checkpoints.finished then
        return 
    end
    player.movement(dt)
end

function player.draw()
    love.graphics.setColor(1, 1, 1)
    local currentSprite = player.getSpriteForRotation(player.rotation)
    love.graphics.draw(
        currentSprite,
        player.x,
        player.y,
        nil,
        2, 2,--Scale
        player.w / 2,
        player.h / 2
    )
end

return player
