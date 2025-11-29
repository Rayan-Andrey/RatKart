local endmenu = {}

endmenu.active = false

-- Button definitions (static sizes + text)
endmenu.buttons = {
    restart = { w = 200, h = 60, text = "RESTART" },
    exit    = { w = 200, h = 60, text = "EXIT GAME" }
}

--------------------------------------------------------
-- Center all buttons safely
--------------------------------------------------------
local function centerButtons()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    local startY = screenH / 2 - 80
    local idx = 0

    for _, btn in pairs(endmenu.buttons) do
        btn.x = (screenW - btn.w) / 2
        btn.y = startY + idx * 100
        idx = idx + 1
    end
end

--------------------------------------------------------
function endmenu.show()
    endmenu.active = true
    centerButtons()
end

--------------------------------------------------------
-- Safe click test
--------------------------------------------------------
local function mouseInButton(btn, mx, my)
    if not btn then return false end  -- PREVENTS CRASH
    return mx > btn.x and mx < btn.x + btn.w and
           my > btn.y and my < btn.y + btn.h
end

--------------------------------------------------------
function endmenu.mousepressed(x, y, button)
    if not endmenu.active then return end
    if button ~= 1 then return end

    local restartBtn = endmenu.buttons.restart
    local exitBtn    = endmenu.buttons.exit

    if mouseInButton(restartBtn, x, y) then
        love.event.quit("restart")
    end
    
    if mouseInButton(exitBtn, x, y) then
        love.event.quit()
    end
end

--------------------------------------------------------
function endmenu.draw()
    if not endmenu.active then return end

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    for _, btn in pairs(endmenu.buttons) do
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 10)

        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h, 10)

        love.graphics.printf(btn.text, btn.x, btn.y + 20, btn.w, "center")
    end
end

--------------------------------------------------------
return endmenu
