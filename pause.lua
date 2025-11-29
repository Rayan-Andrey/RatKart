-- ============================
-- SISTEMA DE PAUSA RATA CARD XD
-- ============================

Pause = {}

function Pause:load()
    self.active = false

    -- Botones del menú
    self.buttons = {
        {text = "Continuar", action = function() Pause:toggle() end},
        {text = "Reiniciar", action = function() love.event.quit("restart") end},
        {text = "Salir", action = function() love.event.quit() end},
    }

    self.buttonWidth = 200
    self.buttonHeight = 40
    self.spacing = 15
end

function Pause:toggle()
    self.active = not self.active
end

function Pause:update(dt)
    if not self.active then return end
end

function Pause:draw()
    if not self.active then return end

    -- Fondo oscurecido
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Menú
    love.graphics.setColor(1, 1, 1)
    local startY = love.graphics.getHeight()/2 - (#self.buttons * (self.buttonHeight + self.spacing))/2

    for i, btn in ipairs(self.buttons) do
        local x = love.graphics.getWidth()/2 - self.buttonWidth/2
        local y = startY + (i-1)*(self.buttonHeight + self.spacing)

        -- Botón
        love.graphics.rectangle("line", x, y, self.buttonWidth, self.buttonHeight)

        -- Texto centrado
        love.graphics.printf(btn.text, x, y + 10, self.buttonWidth, "center")
    end
end

function Pause:mousepressed(x, y)
    if not self.active then return end

    local startY = love.graphics.getHeight()/2 - (#self.buttons * (self.buttonHeight + self.spacing))/2

    for i, btn in ipairs(self.buttons) do
        local bx = love.graphics.getWidth()/2 - self.buttonWidth/2
        local by = startY + (i-1)*(self.buttonHeight + self.spacing)

        if x > bx and x < bx + self.buttonWidth and y > by and y < by + self.buttonHeight then
            btn.action()
        end
    end
end
