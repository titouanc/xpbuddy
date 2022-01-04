local XPMeter = {
    accountForNewXp = function (self)
        local current_xp = UnitXP("player")
        local current_xp_max = UnitXPMax("player")

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
    end,

    toString = function (self)
        local dt = GetTime() - self.start_time;

        return string.format(
            "(%s) XP gained: %d (%d/min) / Lvl gained: %d%% (%d%%/hour)",
            self.name,
            self.total_gained_xp,
            60 * self.total_gained_xp / dt,
            100 * self.total_gained_lvl,
            100 * 3600 * self.total_gained_lvl / dt
        )   
    end
}

function XPMeter:new(name)
    local res = {
        name = name,
        start_time = GetTime(),
        last_known_xp = UnitXP("player"),
        last_known_xp_max = UnitXPMax("player"),
        total_gained_xp = 0,
        total_gained_lvl = 0,
    }
    setmetatable(res, self)
    self.__index = self
    return res
end

local Addon = {
    session_meter = XPMeter:new("Session"),
    instance_meter = nil
}

function Addon:PLAYER_XP_UPDATE()
    self.session_meter:accountForNewXp()
    if self.instance_meter ~= nil then
        self.instance_meter:accountForNewXp()
    end
end

function Addon:PLAYER_ENTERING_WORLD()
    if IsInInstance() then
        local instance_name = GetInstanceInfo()
        self.instance_meter = XPMeter:new(instance_name)
    elseif self.instance_meter then
        print(self.instance_meter:toString())
        self.instance_meter = nil
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(f, event_name, ...)
    Addon[event_name](Addon, ...)
end)
