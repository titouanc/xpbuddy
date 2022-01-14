XPMeter = {
    stopped = true,
    accumulated_time = 0,
    total_gained_xp = 0,
    total_gained_lvl = 0
}

local translations = {
    enUS="%s (%d:%02d:%02d) Gained %dxp (%dxp/min) / Lvl: %d%% (%d%%/h)",
    frFR="%s (%d:%02d:%02d) Gagné %dpx (%dpx/min) / Niv: %d%% (%d%%/h)"
}

local function round(num)
    if num % 1 > 0.5 then
        return math.ceil(num)
    else
        return math.floor(num)
    end
end

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

function XPMeter:totalTime()
    local dt = GetTime() - self.start_time
    if self.stopped then
        return self.accumulated_time
    else
        return dt + self.accumulated_time
    end
end

function XPMeter:toString(lang)
    local dt = self:totalTime()
    local hours = math.floor(dt / 3600)
    local minutes = math.floor(dt / 60) % 60
    local seconds = math.floor(dt) % 60

    if not lang then
        lang = GetLocale()
    end
    local text_fmt = translations[lang]
    if not text_fmt then
        text_fmt = translations["enUS"]
    end

    local gained_level_percent = 100 * self.total_gained_lvl

    local xp_per_min, lvl_per_h
    if dt == 0 then
        xp_per_min = 0
        lvl_per_h = 0
    else
        xp_per_min = 60 * self.total_gained_xp / dt
        lvl_per_h = 3600 * gained_level_percent / dt
    end

    return string.format(
        text_fmt,
        self.name, hours, minutes, seconds,
        self.total_gained_xp,
        round(xp_per_min),
        round(gained_level_percent),
        round(lvl_per_h)
    )
end

function XPMeter:start()
    if self.stopped then
        self.start_time = GetTime()
        self.last_known_xp, self.last_known_xp_max = self.getCurrentXp()
        self.stopped = false
    end
end

function XPMeter:stop()
    if not self.stopped then
        self.accumulated_time = self:totalTime()
        self.stopped = true
    end
end
