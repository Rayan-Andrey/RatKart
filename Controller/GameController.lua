local Race = require("Model.Race")
local RaceView = require("View.RaceView")
local endmenu = require("endmenu")
local startmenu = require("startmenu")

local GameController = {}

function GameController.load()
    startmenu.load()
    Race.load()
    RaceView.load()
    -- endmenu doesn't need explicit load if it's just a table, but good practice if it did.
end

function GameController.resetRace()
    Race.reset()
    -- Also reset endmenu active state if needed, though endmenu.show() sets it true.
    -- We need to hide it.
    endmenu.active = false
end

function GameController.update(dt)
    if startmenu.active then
        return
    end

    if Race.checkpoints.finished then
        endmenu.show()
        return
    end

    -- Collect Input
    local input = {
        left = love.keyboard.isDown("left"),
        right = love.keyboard.isDown("right"),
        accelerate = love.keyboard.isDown("z"),
        reverse = love.keyboard.isDown("x"),
        brake = love.keyboard.isDown("space")
    }

    Race.update(dt, input)
end

function GameController.draw()
    if startmenu.active then
        startmenu.draw()
        return
    end

    RaceView.draw(Race)
    endmenu.draw()
end

function GameController.mousepressed(x, y, button)
    if startmenu.active then
        startmenu.mousepressed(x, y, button)
        return
    end

    local action = endmenu.mousepressed(x, y, button)
    if action == "restart" then
        GameController.resetRace()
    elseif action == "exit" then
        love.event.quit()
    end
end

return GameController
