if not XPMeter then return end

local Addon = {
    session = XPMeter:forPlayer("Session"),
    pets = {},
    current_pet = nil,
    instances = {},
    current_instance = nil,
}

function Addon:PLAYER_ENTERING_WORLD()
    if IsInInstance() then
        local instance_name = GetInstanceInfo()
        if not self.instances[instance_name] then
            self.instances[instance_name] = XPMeter:forPlayer(instance_name)
        end
        self.current_instance = self.instances[instance_name]
        self.current_instance:start()
    elseif self.current_instance then
        self.current_instance:stop()
        print(self.current_instance:toString())
        self.current_instance = nil
    end
end

function Addon:PLAYER_XP_UPDATE()
    self.session:accountForNewXp()
    if self.current_instance then
        self.current_instance:accountForNewXp()
    end
end

function Addon:UNIT_PET()
    local pet_name = UnitName("pet")

    if pet_name then
        if not self.pets[pet_name] then
            self.pets[pet_name] = XPMeter:forPet(pet_name)
        end
        self.current_pet = self.pets[pet_name]
        self.current_pet:start()
    elseif self.current_pet then
        self.current_pet:stop()
        print(self.current_pet:toString())
        self.current_pet = nil
    end
end

function Addon:UNIT_PET_EXPERIENCE()
    if self.current_pet then
        self.current_pet:accountForNewXp()
    end
end

SLASH_XPMETER1 = "/xpmeter"
SlashCmdList["XPMETER"] = function(msg)
    print(Addon.session:toString())
    if #Addon.instances > 0 then
        print("Instances:")
        for _, instance in ipairs(Addon.instances) do
            print("-" .. instance:toString())
        end
    end
    if #Addon.pets > 0 then
        print("Pets:")
        for _, pet in ipairs(Addon.pets) do
            print("-" .. pet:toString())
        end
    end
end


local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_PET")
frame:RegisterEvent("UNIT_PET_EXPERIENCE")

frame:SetScript("OnEvent", function(f, event_name, ...)
    Addon[event_name](Addon, ...)
end)
