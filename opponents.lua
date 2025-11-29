local opponents = {}

local opponentSprite

function opponents.load(count)
    opponentSprite = love.graphics.newImage("Sprites/Oponent.png")

    opponents.list = {}

    for i = 1, count do
        opponents.list[i] = {
            name = "CPU " .. i,   -- CPU name for ranking table

            x = 250 + i * 40,
            y = 150,
            w = 32,
            h = 32,

            rotation = 0,
            speed = 0,
            maxSpeed = 150,
            accel = 80,
            turnSpeed = 2,

            nextCP = 1,    -- checkpoint index they must hit next
            lap = 0,       -- current lap
            finished = false
        }
    end
end


-------------------------------------------------------------
-- Utility: compute angle from (x1,y1) -> (x2,y2)
-------------------------------------------------------------
local function angleTo(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end


-------------------------------------------------------------
-- UPDATE
-- Handles movement, steering, obstacles, checkpoints, laps
-------------------------------------------------------------
function opponents.update(dt, checkpoints, obstacles)
    for _, ai in ipairs(opponents.list) do

        -- If CPU already finished, skip AI logic
        if ai.finished then
            goto continue
        end

        -----------------------------------------------------
        -- Move toward next checkpoint
        -----------------------------------------------------
        local cp = checkpoints.list[ai.nextCP]

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


        -----------------------------------------------------
        -- Obstacle collision (shared with player)
        -----------------------------------------------------
        if obstacles and obstacles.resolveCollisionSingle then
            obstacles.resolveCollisionSingle(ai)
        end


        -----------------------------------------------------
        -- Checkpoint collision
        -----------------------------------------------------
        if ai.x < cp.x + cp.w and
           ai.x + ai.w > cp.x and
           ai.y < cp.y + cp.h and
           ai.y + ai.h > cp.y then

            -- Advance to next checkpoint
            ai.nextCP = ai.nextCP + 1

            -- Finished all checkpoints → new lap
            if ai.nextCP > #checkpoints.list then
                ai.nextCP = 1
                ai.lap = ai.lap + 1

                -------------------------------------------------
                -- FINISHED THE RACE!
                -------------------------------------------------
                if ai.lap >= checkpoints.lapLimit then
                    ai.finished = true

                    -- Register CPU finish time + ranking
                    checkpoints.finishRacer(ai.name)
                end
            end
        end

        ::continue::
    end
end


-------------------------------------------------------------
-- DRAW
-------------------------------------------------------------
function opponents.draw()
    for _, ai in ipairs(opponents.list) do
        love.graphics.setColor(1, 0.2, 0.2)

        love.graphics.draw(
            opponentSprite,
            ai.x,
            ai.y,
            ai.rotation,
            1, 1,
            ai.w / 2,
            ai.h / 2
        )
    end
end

return opponents
