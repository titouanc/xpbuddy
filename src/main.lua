if not XPMeter then return end

local Addon = {}

function Addon:init()
    self.session = nil
    self.pets = {}
    self.current_pet = nil
    self.instances = {}
    self.current_instance = nil
end

Addon:init()

function Addon:PLAYER_ENTERING_WORLD()
    if self.session == nil then
        self.session = XPMeter:forPlayer("Session")
    end
    if IsInInstance() then
        local instance_name = GetInstanceInfo()
        if not self.instances[instance_name] then
            self.instances[instance_name] = XPMeter:forPlayer(instance_name)
        end
        self.current_instance = self.instances[instance_name]
        self.current_instance:start()
    elseif self.current_instance then
        self.current_instance:stop()
        if self.current_instance:hasXp() then
            print(self.current_instance:toString())
        end
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

    if self.current_pet and self.current_pet.name ~= pet_name then
        self.current_pet:stop()
        if self.current_pet:hasXp() then
            print(self.current_pet:toString())
        end
        self.current_pet = nil
    end

    if pet_name then
        if not self.pets[pet_name] then
            self.pets[pet_name] = XPMeter:forPet(pet_name)
        end
        self.current_pet = self.pets[pet_name]
        self.current_pet:start()
    end
end

function Addon:UNIT_PET_EXPERIENCE()
    if self.current_pet then
        self.current_pet:accountForNewXp()
    end
end

local function isEmpty(tab)
    for _, __ in pairs(tab) do return false end
    return true
end

SLASH_XPBUDDY1 = "/xpbuddy"
SlashCmdList["XPBUDDY"] = function()
    print(Addon.session:toString())
    if not isEmpty(Addon.instances) then
        print("Instances:")
        for _, instance in pairs(Addon.instances) do
            print("- " .. instance:toString())
        end
    end
    if not isEmpty(Addon.pets) then
        print("Pets:")
        for _, pet in pairs(Addon.pets) do
            print("- " .. pet:toString())
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

return Addon
