function movement(dt)
    -- Turning
    if love.keyboard.isDown("left") then
        rectangle.rotation = rectangle.rotation - rectangle.turnSpeed * dt
    elseif love.keyboard.isDown("right") then
        rectangle.rotation = rectangle.rotation + rectangle.turnSpeed * dt
    end

    -- Acceleration / reverse / brake
    if love.keyboard.isDown("z") then
        rectangle.speed = math.min(rectangle.speed + rectangle.acceleration * dt, rectangle.topSpeed)
    elseif love.keyboard.isDown("x") then
        rectangle.speed = math.max(rectangle.speed - rectangle.acceleration * dt, -rectangle.topSpeed / 2)
    elseif love.keyboard.isDown("space") then
        if rectangle.speed > 0 then
            rectangle.speed = math.max(0, rectangle.speed - rectangle.brakeForce * dt)
        elseif rectangle.speed < 0 then
            rectangle.speed = math.min(0, rectangle.speed + rectangle.brakeForce * dt)
        end
    else
        if rectangle.speed > 0 then
            rectangle.speed = math.max(0, rectangle.speed - rectangle.friction * dt)
        elseif rectangle.speed < 0 then
            rectangle.speed = math.min(0, rectangle.speed + rectangle.friction * dt)
        end
    end

    -- Movement (forward direction)
    rectangle.x = rectangle.x + math.cos(rectangle.rotation) * rectangle.speed * dt
    rectangle.y = rectangle.y + math.sin(rectangle.rotation) * rectangle.speed * dt
end

function getSpriteForRotation(rotation)
    -- Normalize angle and apply offset (faces left at 0 radians)
    local offset = math.pi
    local angle = (rotation + offset) % (2 * math.pi)
    local deg = math.deg(angle)

    -- Determine 8-way direction
    if deg >= 337.5 or deg < 22.5 then
        return rectangle.sprites.left
    elseif deg < 67.5 then
        return rectangle.sprites.up_left
    elseif deg < 112.5 then
        return rectangle.sprites.up
    elseif deg < 157.5 then
        return rectangle.sprites.up_right
    elseif deg < 202.5 then
        return rectangle.sprites.right
    elseif deg < 247.5 then
        return rectangle.sprites.down_right
    elseif deg < 292.5 then
        return rectangle.sprites.down
    elseif deg < 337.5 then
        return rectangle.sprites.down_left
    end
end


function love.load()
    -- Load sprite set
    love.graphics.setDefaultFilter("nearest","nearest")
    rectangle = {
        x = 200,
        y = 200,
        speed = 0,
        acceleration = 200,
        topSpeed = 300,
        friction = 150,
        brakeForce = 400,
        rotation = 0,
        turnSpeed = 3,
        sprites = {
            up = love.graphics.newImage("car_up.png"),
            down = love.graphics.newImage("car_down.png"),
            left = love.graphics.newImage("car_left.png"),
            right = love.graphics.newImage("car_right.png"),
            up_left = love.graphics.newImage("car_up_left.png"),
            up_right = love.graphics.newImage("car_up_right.png"),
            down_left = love.graphics.newImage("car_down_left.png"),
            down_right = love.graphics.newImage("car_down_right.png")
        }
    }

    -- Use one image to get dimensions
    rectangle.w = rectangle.sprites.up:getWidth()
    rectangle.h = rectangle.sprites.up:getHeight()
end

function love.update(dt)
    movement(dt)
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    

    local currentSprite = getSpriteForRotation(rectangle.rotation)

    love.graphics.draw(
        currentSprite,
        rectangle.x,
        rectangle.y,
        nil, --rotation
        3, 3,
        rectangle.w / 2,
        rectangle.h / 2
    )
end

