XPMeter = {
    stopped = true,
    accumulated_time = 0,
    total_gained_xp = 0,
    total_gained_lvl = 0
}

function XPMeter:new(name, getCurrentXp)
    local res = {
        name = name,
        getCurrentXp = getCurrentXp
    }
    setmetatable(res, self)
    self.__index = self
    res:start()
    return res
end

function XPMeter:forPlayer(name)
    return self:new(name, function()
        return UnitXP("player"), UnitXPMax("player")
    end)
end

function XPMeter:forPet(name)
    return self:new(name, GetPetExperience)
end

function XPMeter:accountForNewXp()
    local current_xp, current_xp_max = self.getCurrentXp()

    local increment_xp
    local increment_lvl

    if current_xp < self.last_known_xp then
        -- Level up; ding!
        local prev_lvl_increment_xp = self.last_known_xp_max - self.last_known_xp
        increment_xp = prev_lvl_increment_xp + current_xp
        increment_lvl = prev_lvl_increment_xp/self.last_known_xp_max + current_xp/current_xp_max
    else
        increment_xp = current_xp - self.last_known_xp
        increment_lvl = increment_xp/current_xp_max
    end

    self.total_gained_xp = self.total_gained_xp + increment_xp
    self.total_gained_lvl = self.total_gained_lvl + increment_lvl
    self.last_known_xp = current_xp
    self.last_known_xp_max = current_xp_max
end

function XPMeter:toString()
    local dt = GetTime() - self.start_time + self.accumulated_time;

    return string.format(
        "(%s) XP gained: %d (%d/min) / Lvl gained: %d%% (%d%%/hour)",
        self.name,
        self.total_gained_xp,
        60 * self.total_gained_xp / dt,
        100 * self.total_gained_lvl,
        100 * 3600 * self.total_gained_lvl / dt
    )   
end

function XPMeter:start()
    if self.stopped then
        self.start_time = GetTime()
        self.last_known_xp, self.last_known_xp_max = self.getCurrentXp()
    end
end

function XPMeter:stop()
    if not self.stopped then
        self.accumulated_time = self.accumulated_time + (GetTime() - self.start_time)
        self.stopped = true
    end
end
