local startmenu = {}

startmenu.active = true   -- show at game start

startmenu.buttons = {
    start = { w = 250, h = 70, text = "START RACE" },
    exit  = { w = 250, h = 70, text = "EXIT GAME" }
}

--------------------------------------------------------
-- Center buttons on screen
--------------------------------------------------------
local function centerButtons()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local startY = sh / 2 - 60
    local i = 0

    for _, btn in pairs(startmenu.buttons) do
        btn.x = (sw - btn.w) / 2
        btn.y = startY + i * 100
        i = i + 1
    end
end

--------------------------------------------------------
function startmenu.load()
    centerButtons()
end

--------------------------------------------------------
local function mouseInButton(btn, mx, my)
    if not btn then return false end
    return mx > btn.x and mx < btn.x + btn.w and
           my > btn.y and my < btn.y + btn.h
end

--------------------------------------------------------
function startmenu.mousepressed(x, y, button)
    if not startmenu.active then return end
    if button ~= 1 then return end

    local startBtn = startmenu.buttons.start
    local exitBtn  = startmenu.buttons.exit

    if mouseInButton(startBtn, x, y) then
        startmenu.active = false   -- CLOSE MENU
    end

    if mouseInButton(exitBtn, x, y) then
        love.event.quit()
    end
end

--------------------------------------------------------
function startmenu.draw()
    if not startmenu.active then return end

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("TOP-DOWN RACER", 0, 100, love.graphics.getWidth(), "center", 0, 2, 2)

    -- Buttons
    for _, btn in pairs(startmenu.buttons) do
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 10)

        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h, 10)

        love.graphics.printf(btn.text, btn.x, btn.y + 23, btn.w, "center")
    end
end

return startmenu
