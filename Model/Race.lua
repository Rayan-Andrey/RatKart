local Car = require("Model.Car")
local Opponent = require("Model.Opponent")
local Obstacles = require("Model.Obstacles")
local Checkpoints = require("Model.Checkpoints")
local Speedup = require("Model.Speedup")

local Race = {}

function Race.load()
    Race.reset()
end

function Race.reset()
    -- Initialize Player
    Race.player = Car.new()

    -- Initialize Checkpoints
    Race.checkpoints = Checkpoints.new()
    -- Add checkpoints (Data from original checkpoints.lua)
    -- We need to know the sprite size to set w/h correctly if not hardcoded.
    -- But Model shouldn't know about sprites.
    -- Let's assume standard size 100x100 as per original code logic or pass it in.
    -- Original: w=100, h=100.
    Race.checkpoints:add(400, 100, 100, 100, 1)
    Race.checkpoints:add(600, 100, 100, 100, 2)
    Race.checkpoints:add(600, 300, 100, 100, 3)
    Race.checkpoints:add(400, 300, 100, 100, 4)

    -- Initialize Obstacles
    Race.obstacles = Obstacles.new()
    -- Original: tileW, tileH from sprite. Let's assume 32x32 or similar.
    -- Actually original used `obstacles.sprite:getWidth()`.
    -- We can hardcode or configure. Let's use 64x64 as a safe bet or 32x32.
    -- Let's use a config or magic number for now, View will handle visual size.
    local wallW, wallH = 32, 32 
    Race.obstacles:add(100, 100, wallW, wallH)
    Race.obstacles:add(200, 300, wallW, wallH)
    Race.obstacles:add(400, 180, wallW, wallH)

    -- Initialize Speedups
    Race.speedup = Speedup.new()
    Race.speedup:add(300, 150, 1)
    Race.speedup:add(500, 250, 2)

    -- Initialize Opponents
    Race.opponents = {}
    local opponentCount = 3
    for i = 1, opponentCount do
        table.insert(Race.opponents, Opponent.new(i, 250 + i * 40, 150))
    end
end

function Race.update(dt, input)
    if Race.checkpoints.finished then return end

    -- Update Player
    Race.player:update(dt, input)

    -- Update Opponents
    for _, ai in ipairs(Race.opponents) do
        Opponent.update(ai, dt, Race.checkpoints, Race.obstacles)
    end

    -- Update Obstacles (Collision with player)
    Race.obstacles:resolveCollision(Race.player)

    -- Update Speedups
    Race.speedup:update(dt, Race.player)

    -- Update Checkpoints
    Race.checkpoints:update(Race.player, dt)
end

return Race
