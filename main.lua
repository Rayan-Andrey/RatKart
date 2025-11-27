----------------------------------------------------
-- MOVIMIENTO DEL AUTO
----------------------------------------------------
function movement(dt)
    
    if gameFinished then
        return -- Desactiva movimiento completamente
    end

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

    -- Guardar posición para colisión
    local oldX, oldY = rectangle.x, rectangle.y

    -- Movement
    rectangle.x = rectangle.x + math.cos(rectangle.rotation) * rectangle.speed * dt
    rectangle.y = rectangle.y + math.sin(rectangle.rotation) * rectangle.speed * dt

    -- Hitbox del coche
    local carBox = {
        x = rectangle.x - rectangle.w/2,
        y = rectangle.y - rectangle.h/2,
        w = rectangle.w,
        h = rectangle.h
    }

    ----------------------------------------------------
    -- COLISION CON MUROS
    ----------------------------------------------------
    for _, wall in ipairs(walls) do
        if rectOverlap(carBox, wall) then
            rectangle.x = oldX
            rectangle.y = oldY
            rectangle.speed = 0
        end
    end

    ----------------------------------------------------
    -- CHECKPOINTS EN ORDEN
    ----------------------------------------------------
    checkCheckpointPass(carBox)
end


----------------------------------------------------
-- SISTEMA 8 DIRECCIONES MEJORADO
----------------------------------------------------
function angleToDegrees(a)
    a = (a + 2 * math.pi) % (2 * math.pi)
    return math.deg(a)
end

function getSpriteForRotation(rotation)
    local offset = math.pi
    local deg = angleToDegrees(rotation + offset)

    local sectors = {
        {22.5,  rectangle.sprites.left},
        {67.5,  rectangle.sprites.up_left},
        {112.5, rectangle.sprites.up},
        {157.5, rectangle.sprites.up_right},
        {202.5, rectangle.sprites.right},
        {247.5, rectangle.sprites.down_right},
        {292.5, rectangle.sprites.down},
        {337.5, rectangle.sprites.down_left},
        {360,   rectangle.sprites.left}
    }

    for _, sec in ipairs(sectors) do
        if deg < sec[1] then
            return sec[2]
        end
    end
end


----------------------------------------------------
-- COLISION AABB
----------------------------------------------------
function rectOverlap(a, b)
    return not (
        a.x + a.w < b.x or
        a.x > b.x + b.w or
        a.y + a.h < b.y or
        a.y > b.y + b.h
    )
end


----------------------------------------------------
-- CHECKPOINTS Y VUELTAS
----------------------------------------------------
function createCheckpoint(x, y, w, h)
    table.insert(checkpoints, {x=x, y=y, w=w, h=h})
end

function checkCheckpointPass(carBox)
    local cp = checkpoints[currentCheckpoint]

    if rectOverlap(carBox, cp) then
        print("Checkpoint " .. currentCheckpoint .. " OK")

        currentCheckpoint = currentCheckpoint + 1

        if currentCheckpoint > #checkpoints then
            completeLap()
        end
    end
end

function checkFinishLine(carBox)
    -- Solo cuenta si el coche debe pasar primero por CP1
    if currentCheckpoint == 1 and rectOverlap(carBox, finishLine) then
        print("META CRUZADA")
    end
end


function completeLap()
    lap = lap + 1

    -- Verificar si ya ganó
    if lap >= maxLaps then
        gameFinished = true
        print("¡¡VICTORIA!! Se completaron las " .. maxLaps .. " vueltas.")
        return
    end

    -- Guardar tiempo de vuelta
    local now = love.timer.getTime()
    local lapTime = now - lapStartTime

    print("VUELTA COMPLETADA! Tiempo:", lapTime)

    if not bestLap or lapTime < bestLap then
        bestLap = lapTime
        print("NUEVO MEJOR TIEMPO:", bestLap)
    end

    lapStartTime = now
    currentCheckpoint = 1
end



----------------------------------------------------
-- MUROS
----------------------------------------------------
function createWall(x, y, w, h)
    table.insert(walls, {x=x, y=y, w=w, h=h})
end


----------------------------------------------------
-- LOAD
----------------------------------------------------
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

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

    rectangle.w = rectangle.sprites.up:getWidth()
    rectangle.h = rectangle.sprites.up:getHeight()

    ----------------------------------------------------
    -- INICIALIZAR MUROS Y CHECKPOINTS
    ----------------------------------------------------
    walls = {}
    checkpoints = {}

    currentCheckpoint = 1
    lap = 0
    lapStartTime = love.timer.getTime()
    bestLap = nil

    -- EJEMPLO DE MUROS
    createWall(100, 100, 500, 20)
    createWall(100, 100, 20, 300)
    createWall(580, 100, 20, 300)
    createWall(100, 380, 500, 20)

    -- CHECKPOINTS EN ORDEN (CP1 = META)
    createCheckpoint(120, 220, 30, 50)  -- META
    createCheckpoint(350, 120, 50, 30)
    createCheckpoint(550, 220, 30, 50)
    createCheckpoint(350, 350, 50, 30)

    maxLaps = 3         -- Límite de vueltas (modificable)
    gameFinished = false

    -- Línea de meta dedicada (posición y tamaño)
    finishLine = { x = 120, y = 220, w = 30, h = 50 } 


        ----------------------------------------------------
    -- MINIMAPA (CONFIGURACIÓN)
    ----------------------------------------------------
    minimap = {
        x = 650,      -- posición en pantalla
        y = 20,
        w = 200,      -- tamaño del minimapa
        h = 200,

        -- área total del circuito (ajusta si tu pista es más grande)
        world = {
            x = 0,
            y = 0,
            w = 800,
            h = 600
        }
    }

end




----------------------------------------------------
-- UPDATE
----------------------------------------------------
function love.update(dt)
    movement(dt)
end


----------------------------------------------------
-- DRAW
----------------------------------------------------
function love.draw()
    love.graphics.setColor(1, 1, 1)

    local currentSprite = getSpriteForRotation(rectangle.rotation)

    love.graphics.draw(
        currentSprite,
        rectangle.x,
        rectangle.y,
        nil,
        2, 2,
        rectangle.w / 2,
        rectangle.h / 2
    )

    ----------------------------------------------------
    -- DIBUJAR MUROS
    ----------------------------------------------------
    love.graphics.setColor(1, 0, 0)
    for _, wall in ipairs(walls) do
        love.graphics.rectangle("fill", wall.x, wall.y, wall.w, wall.h)
    end

    ----------------------------------------------------
    -- DIBUJAR CHECKPOINTS
    ----------------------------------------------------
    love.graphics.setColor(0, 1, 0, 0.5)
    for _, cp in ipairs(checkpoints) do
        love.graphics.rectangle("fill", cp.x, cp.y, cp.w, cp.h)
    end

    ----------------------------------------------------
    -- LINEA DE META
    ----------------------------------------------------
    love.graphics.setColor(1, 1, 0, 0.8)
    love.graphics.rectangle("fill", finishLine.x, finishLine.y, finishLine.w, finishLine.h)


    ----------------------------------------------------
    -- UI
    ----------------------------------------------------
    love.graphics.setColor(1,1,1)
    love.graphics.print("Vuelta: " .. lap, 10, 10)
    love.graphics.print("Checkpoint: " .. currentCheckpoint .. "/" .. #checkpoints, 10, 30)

    if bestLap then
        love.graphics.print("Mejor vuelta: " .. string.format("%.2f", bestLap), 10, 50)
    end

    ----------------------------------------------------
    -- MINIMAPA
    ----------------------------------------------------
    local mm = minimap

    -- borde del minimapa
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", mm.x - 2, mm.y - 2, mm.w + 4, mm.h + 4)

    -- fondo
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", mm.x, mm.y, mm.w, mm.h)

    -- escala del minimapa
    local scaleX = mm.w / mm.world.w
    local scaleY = mm.h / mm.world.h

    ----------------------------------------------------
    -- MUROS EN EL MINIMAPA
    ----------------------------------------------------
    love.graphics.setColor(1, 0, 0)
    for _, wall in ipairs(walls) do
        love.graphics.rectangle(
            "fill",
            mm.x + wall.x * scaleX,
            mm.y + wall.y * scaleY,
            wall.w * scaleX,
            wall.h * scaleY
        )
    end

    ----------------------------------------------------
    -- CHECKPOINTS
    ----------------------------------------------------
    love.graphics.setColor(0, 1, 0)
    for _, cp in ipairs(checkpoints) do
        love.graphics.rectangle(
            "fill",
            mm.x + cp.x * scaleX,
            mm.y + cp.y * scaleY,
            cp.w * scaleX,
            cp.h * scaleY
        )
    end

    ----------------------------------------------------
    -- COCHE EN EL MINIMAPA
    ----------------------------------------------------
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle(
        "fill",
        mm.x + rectangle.x * scaleX,
        mm.y + rectangle.y * scaleY,
        4
    )

    if gameFinished then
        love.graphics.setColor(1, 1, 0)
        love.graphics.setFont(love.graphics.newFont(40))
        love.graphics.print("¡GANASTE!", 280, 260)
    end



end
