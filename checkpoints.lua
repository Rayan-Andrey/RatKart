local checkpoints = {}

local checkpointA
local checkpointB

function checkpoints.load()
    -- Load sprites
    checkpointA = love.graphics.newImage("Sprites/checkpoint_A.png")
    checkpointB = love.graphics.newImage("Sprites/checkpoint_B.png")

    checkpoints.order = 1
    checkpoints.lap = 0
    checkpoints.lapLimit = 3
    checkpoints.finished = false

    checkpoints.raceTime = 0      
    checkpoints.finishedRacers = {}  

    checkpoints.list = {
        { x = 400, y = 100, w = 100, h = 100, sprite = checkpointA, id = 1, triggered = false },
        { x = 600, y = 100, w = 100, h = 100, sprite = checkpointB, id = 2, triggered = false },
        { x = 600, y = 300, w = 100, h = 100, sprite = checkpointA, id = 3, triggered = false },
        { x = 400, y = 300, w = 100, h = 100, sprite = checkpointB, id = 4, triggered = false }
    }
end

---------------------------------------------------------
-- Helper to detect collision
---------------------------------------------------------
local function inside(player, cp)
    return player.x < cp.x + cp.w and
           player.x + player.w > cp.x and
           player.y < cp.y + cp.h and
           player.y + player.h > cp.y
end

---------------------------------------------------------
-- Register a racer finishing (player or CPU)
---------------------------------------------------------
function checkpoints.finishRacer(name)
    -- Prevent duplicates
    for _, r in ipairs(checkpoints.finishedRacers) do
        if r.name == name then return end
    end

    table.insert(checkpoints.finishedRacers, {
        name = name,
        time = checkpoints.raceTime
    })

    -- Sort by time
    table.sort(checkpoints.finishedRacers, function(a, b)
        return a.time < b.time
    end)

    -- Assign positions
    for i, r in ipairs(checkpoints.finishedRacers) do
        r.position = i
    end
end

---------------------------------------------------------
-- Update checkpoints for PLAYER ONLY
---------------------------------------------------------
function checkpoints.update(player, dt)
    -- Update race timer only if race has not ended
    if not checkpoints.finished then
        checkpoints.raceTime = checkpoints.raceTime + dt
    end

    if checkpoints.finished then
        return
    end

    for _, cp in ipairs(checkpoints.list) do
        if inside(player, cp) then

            if not cp.triggered and cp.id == checkpoints.order then
                cp.triggered = true
                checkpoints.order = checkpoints.order + 1

                -- New lap?
                if checkpoints.order > #checkpoints.list then
                    checkpoints.lap = checkpoints.lap + 1
                    checkpoints.order = 1

                    -- Race finished?
                    if checkpoints.lap >= checkpoints.lapLimit then
                        checkpoints.finished = true
                        checkpoints.finishRacer("Player") -- ⬅️ Add player to ranking
                    end
                end
            end
        else
            cp.triggered = false
        end
    end
end

---------------------------------------------------------
-- DRAW
---------------------------------------------------------
function checkpoints.draw()
    for _, cp in ipairs(checkpoints.list) do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(cp.sprite, cp.x, cp.y)
    end

    -- HUD info
    love.graphics.setColor(1,1,1)
    love.graphics.print("Lap: " .. checkpoints.lap, 20, 20)
    love.graphics.print("Next CP: " .. checkpoints.order, 20, 40)
    love.graphics.print("Time: " .. string.format("%.2f", checkpoints.raceTime), 20, 60)

    -------------------------------------------------
    -- FINAL RESULT TABLE
    -------------------------------------------------
    if checkpoints.finished then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("🏁 RACE FINISHED! 🏁", 300, 120, 0, 2, 2)

        love.graphics.setColor(1, 1, 1)
        love.graphics.print("FINAL RESULTS:", 320, 170)

        for i, r in ipairs(checkpoints.finishedRacers) do
            local line = r.position .. ". " .. r.name .. " - " .. string.format("%.2f s", r.time)
            love.graphics.print(line, 320, 200 + i * 20)
        end
    end
end

return checkpoints
