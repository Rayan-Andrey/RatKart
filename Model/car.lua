local Car = {}
Car.__index = Car

function Car.new()
    local instance = {
        x = 200,
        y = 200,
        speed = 0,
        acceleration = 200,
        topSpeed = 300,
        friction = 150,
        brakeForce = 400,
        rotation = 0,
        turnSpeed = 3,
        originalTopSpeed = 300,
        boostTime = 0,
        w = 0, -- Will be set by View or config, but for collision we need it. 
               -- Let's assume standard size for now or set it from outside.
        h = 0
    }
    -- We can hardcode dimensions if we know them, or pass them in. 
    -- Original player.lua got them from sprite. 
    -- Let's assume 32x32 roughly or wait for View to set them? 
    -- Better: Model defines physics size. 
    -- Original: player.w = player.sprites.up:getWidth() (which is likely around 30-40)
    -- Let's set a default and allow override.
    instance.w = 20 -- Approximate physics width
    instance.h = 30 -- Approximate physics height
    
    return setmetatable(instance, Car)
end

function Car.update(self, dt, input)
    -- Turning
    if input.left then
        self.rotation = self.rotation - self.turnSpeed * dt
    elseif input.right then
        self.rotation = self.rotation + self.turnSpeed * dt
    end

    -- Acceleration / reverse / brake
    if input.accelerate then
        self.speed = math.min(self.speed + self.acceleration * dt, self.topSpeed)
    elseif input.reverse then
        self.speed = math.max(self.speed - self.acceleration * dt, -self.topSpeed / 2)
    elseif input.brake then
        if self.speed > 0 then
            self.speed = math.max(0, self.speed - self.brakeForce * dt)
        elseif self.speed < 0 then
            self.speed = math.min(0, self.speed + self.brakeForce * dt)
        end
    else
        if self.speed > 0 then
            self.speed = math.max(0, self.speed - self.friction * dt)
        elseif self.speed < 0 then
            self.speed = math.min(0, self.speed + self.friction * dt)
        end
    end

    -- Movement (forward direction)
    self.x = self.x + math.cos(self.rotation) * self.speed * dt
    self.y = self.y + math.sin(self.rotation) * self.speed * dt
end

return Car
