local Checkpoints = {}
Checkpoints.__index = Checkpoints

function Checkpoints.new()
    local instance = {
        list = {},
        order = 1,
        lap = 0,
        lapLimit = 3,
        finished = false,
        raceTime = 0,
        finishedRacers = {}
    }
    return setmetatable(instance, Checkpoints)
end

function Checkpoints.add(self, x, y, w, h, id)
    table.insert(self.list, {
        x = x,
        y = y,
        w = w,
        h = h,
        id = id,
        triggered = false
    })
end

local function inside(entity, cp)
    -- Entity x,y is center? Checkpoints x,y is top-left?
    -- Original code: player.x < cp.x + cp.w ...
    -- If player.x is center, this works if player is small enough or we account for size.
    -- Original code used player.x directly. Let's assume point collision for simplicity or add width.
    -- Original: player.x + player.w > cp.x ... implies player.x is top-left?
    -- Wait, player.draw uses offset. So player.x is center of rotation.
    -- But collision check in original `checkpoints.lua` used `player.x + player.w`.
    -- If player.x is center, `player.x + player.w` is `center + width`.
    -- This effectively makes the hitbox `[center, center+width]`. A bit weird but let's stick to it or improve.
    -- Actually, let's use a proper centered box check if possible, or stick to original logic to "not alter race logic".
    -- Original: `player.x < cp.x + cp.w`
    return entity.x < cp.x + cp.w and
           entity.x + entity.w > cp.x and
           entity.y < cp.y + cp.h and
           entity.y + entity.h > cp.y
end

function Checkpoints.finishRacer(self, name)
    -- Prevent duplicates
    for _, r in ipairs(self.finishedRacers) do
        if r.name == name then return end
    end

    table.insert(self.finishedRacers, {
        name = name,
        time = self.raceTime
    })

    -- Sort by time
    table.sort(self.finishedRacers, function(a, b)
        return a.time < b.time
    end)

    -- Assign positions
    for i, r in ipairs(self.finishedRacers) do
        r.position = i
    end
end

function Checkpoints.update(self, player, dt)
    -- Update race timer only if race has not ended
    if not self.finished then
        self.raceTime = self.raceTime + dt
    end

    if self.finished then
        return
    end

    for _, cp in ipairs(self.list) do
        if inside(player, cp) then
            if not cp.triggered and cp.id == self.order then
                cp.triggered = true
                self.order = self.order + 1

                -- New lap?
                if self.order > #self.list then
                    self.lap = self.lap + 1
                    self.order = 1

                    -- Race finished?
                    if self.lap >= self.lapLimit then
                        self.finished = true
                        self:finishRacer("Player")
                    end
                end
            end
        else
            cp.triggered = false
        end
    end
end

return Checkpoints
