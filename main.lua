require("pause")
player = require("player")
opponents = require("opponents")
obstacles = require("obstacles")
speedup = require("speedup")
checkpoints = require("checkpoints")
endmenu = require("endmenu")
startmenu = require("startmenu")

function love.load()
    startmenu.load()
    player.load()
    opponents.load(3)
    checkpoints.load()    
    obstacles.load()
    speedup.load()  
end

function love.update(dt)
    
    if startmenu.active then
        return
    end

    if checkpoints.finished then
        endmenu.show()
        return
    end
    player.update(dt)
    opponents.update(dt, checkpoints, obstacles)
    obstacles.resolveCollision(player)
    speedup.update(dt, player)
    checkpoints.update(player, dt)
    
end

function love.mousepressed(x, y, button)
    if startmenu.active then
        startmenu.mousepressed(x, y, button)
        return
    end

    endmenu.mousepressed(x, y, button)
end

function love.draw()

    if startmenu.active then
        startmenu.draw()
        return  -- stop here, do NOT draw the game yet
    end

    obstacles.draw()
    opponents.draw()
    speedup.draw()
    player.draw()
    endmenu.draw() 
    checkpoints.draw() 
    
end