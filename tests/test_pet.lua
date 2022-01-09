function test_pet_summon_dismiss()
    Addon:PLAYER_ENTERING_WORLD()
    assertEqual(nil, Addon.current_pet)
    assertEqual(0, #Addon.pets)

    -- Summon Pet
    GetTime_VALUE = {10}
    UnitName_VALUE = {"Leo"}
    Addon:UNIT_PET()
    assert(Addon.pets["Leo"] ~= nil, "Expected to have a pet named Leo")
    assertEqual(Addon.pets["Leo"], Addon.current_pet)
    assertEqual(0, Addon.pets["Leo"]:totalTime())

    -- Dismiss Pet
    GetTime_VALUE = {20}
    UnitName_VALUE = {nil}
    Addon:UNIT_PET()
    assert(Addon.pets["Leo"] ~= nil, "Expected to have a pet named Leo")
    assertEqual(nil, Addon.current_pet)
    assertEqual(10, Addon.pets["Leo"]:totalTime())
    assertEqual(1, #Console)
    assertEqual("Leo (0:00:10) Gained 0xp (0xp/min) / Lvl: 0% (0%/h)", Console[1])

    SlashCmdList["XPBUDDY"]()
    assertEqual(4, #Console)
    assertEqual("Session (0:00:20) Gained 0xp (0xp/min) / Lvl: 0% (0%/h)", Console[2])
    assertEqual("Pets:", Console[3])
    assertEqual("- Leo (0:00:10) Gained 0xp (0xp/min) / Lvl: 0% (0%/h)", Console[4])
end

function test_change_pet()
    Addon:PLAYER_ENTERING_WORLD()
    assertEqual(nil, Addon.current_pet)
    assertEqual(0, #Addon.pets)

    -- Summon Pet
    GetTime_VALUE = {10}
    UnitName_VALUE = {"Leo"}
    Addon:UNIT_PET()
    assert(Addon.pets["Leo"] ~= nil, "Expected to have a pet named Leo")
    assertEqual(Addon.pets["Leo"], Addon.current_pet)
    assertEqual(0, Addon.pets["Leo"]:totalTime())

    -- Summon other pet
    GetTime_VALUE = {20}
    UnitName_VALUE = {"Stan"}
    Addon:UNIT_PET()
    assert(Addon.pets["Stan"] ~= nil, "Expected to have a pet named Stan")
    assertEqual(Addon.pets["Stan"], Addon.current_pet)
    assertEqual(10, Addon.pets["Leo"]:totalTime())
    assertEqual(0, Addon.pets["Stan"]:totalTime())
    assertEqual(1, #Console)
    assertEqual("Leo (0:00:10) Gained 0xp (0xp/min) / Lvl: 0% (0%/h)", Console[1])
    
    SlashCmdList["XPBUDDY"]()
    assertEqual(5, #Console)
    assertEqual("Session (0:00:20) Gained 0xp (0xp/min) / Lvl: 0% (0%/h)", Console[2])
    assertEqual("Pets:", Console[3])
    assertEqual("- Leo (0:00:10) Gained 0xp (0xp/min) / Lvl: 0% (0%/h)", Console[4])
    assertEqual("- Stan (0:00:00) Gained 0xp (0xp/min) / Lvl: 0% (0%/h)", Console[5])
end
