local Opponent = {}

function Opponent.new(index, startX, startY)
    return {
        name = "CPU " .. index,
        x = startX,
        y = startY,
        w = 32,
        h = 32,
        rotation = 0,
        speed = 0,
        maxSpeed = 150,
        accel = 80,
        turnSpeed = 2,
        nextCP = 1,
        lap = 0,
        finished = false
    }
end

local function angleTo(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function Opponent.update(ai, dt, checkpoints, obstacles)
    if ai.finished then return end

    -- Move toward next checkpoint
    local cp = checkpoints.list[ai.nextCP]
    if not cp then return end -- Safety check

    -- Rotate AI toward checkpoint center
    local targetAngle = angleTo(ai.x, ai.y, cp.x + cp.w / 2, cp.y + cp.h / 2)
    local diff = targetAngle - ai.rotation

    -- Normalize angle
    if diff > math.pi then diff = diff - 2 * math.pi end
    if diff < -math.pi then diff = diff + 2 * math.pi end

    -- Turn left/right
    if diff > 0 then
        ai.rotation = ai.rotation + ai.turnSpeed * dt
    else
        ai.rotation = ai.rotation - ai.turnSpeed * dt
    end

    -- Accelerate
    ai.speed = math.min(ai.speed + ai.accel * dt, ai.maxSpeed)

    -- Movement (forward)
    ai.x = ai.x + math.cos(ai.rotation) * ai.speed * dt
    ai.y = ai.y + math.sin(ai.rotation) * ai.speed * dt

    -- Obstacle collision
    if obstacles and obstacles.resolveCollisionSingle then
        obstacles:resolveCollisionSingle(ai)
    end

    -- Checkpoint collision
    if ai.x < cp.x + cp.w and
       ai.x + ai.w > cp.x and
       ai.y < cp.y + cp.h and
       ai.y + ai.h > cp.y then

        -- Advance to next checkpoint
        ai.nextCP = ai.nextCP + 1

        -- Finished all checkpoints -> new lap
        if ai.nextCP > #checkpoints.list then
            ai.nextCP = 1
            ai.lap = ai.lap + 1

            -- FINISHED THE RACE!
            if ai.lap >= checkpoints.lapLimit then
                ai.finished = true
                checkpoints:finishRacer(ai.name)
            end
        end
    end
end

return Opponent
