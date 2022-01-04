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
            "XP gained: %d (%d/min) / Lvl gained: %.3f (%.3f/hour)",
            self.total_gained_xp,
            60 * self.total_gained_xp / dt,
            self.total_gained_lvl,
            3600 * self.total_gained_lvl / dt
        )   
    end
}

function XPMeter:new()
    local res = {
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

local session_meter = XPMeter:new()
local instance_meter = nil

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(f, event_name)
    if event_name == "PLAYER_XP_UPDATE" then
        session_meter:accountForNewXp()
        if instance_meter ~= nil then
            instance_meter:accountForNewXp()
        end
    elseif event_name == "PLAYER_ENTERING_WORLD" then
        local inInstance, instanceType = IsInInstance()
        if inInstance == 1 then
            instance_meter = XPMeter:new()
        else
            print(instance_meter.toString())
            instance_meter = nil
        end
    end
end)
