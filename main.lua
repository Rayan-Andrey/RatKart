
function movement(dt)
    -- Turning
    if love.keyboard.isDown("left") then
        rectangle.rotation = rectangle.rotation - rectangle.turnSpeed * dt
    elseif love.keyboard.isDown("right") then
        rectangle.rotation = rectangle.rotation + rectangle.turnSpeed * dt
    end

    -- Acceleration / reverse
    if love.keyboard.isDown("up") then
        rectangle.speed = math.min(rectangle.speed + rectangle.acceleration * dt, rectangle.topSpeed)
    elseif love.keyboard.isDown("down") then
        rectangle.speed = math.max(rectangle.speed - rectangle.acceleration * dt, -rectangle.topSpeed / 2)
    else
        -- Apply friction when no key is pressed
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

function love.load()
    rectangle = {
    x=20, 
    y=20, 
    w=60, 
    h=20 ,
    speed = 0,          --Base speed
    acceleration = 200, --Acceleration Value
    topSpeed = 300,
    friction = 100,     -- Slowdown Value
    rotation = 0,       -- in radians
    turnSpeed = 3       -- radians per second
}
end


function love.update(dt)
    movement(dt)
end

function love.draw()
	love.graphics.setColor(0.5, 0.5,1)
    love.graphics.print("!!Rat Kart!!")
	love.graphics.push()
    love.graphics.translate(rectangle.x, rectangle.y)
    love.graphics.rotate(rectangle.rotation)
    love.graphics.setColor(0.2, 0.4, 1)
    love.graphics.rectangle("fill", -rectangle.w/2, -rectangle.h/2, rectangle.w, rectangle.h)
    love.graphics.pop()
end