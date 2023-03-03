function test_pet_summon_dismiss()
    Addon:PLAYER_ENTERING_WORLD()
    assertEqual(nil, Addon.current_pet)
    assertEqual(0, #Addon.pets)

    -- Summon Pet
    GetPetExperience_VALUE = {0, 3600}
    GetTime_VALUE = {10}
    UnitName_VALUE = {"Leo"}
    Addon:UNIT_PET()
    assert(Addon.pets["Leo"] ~= nil, "Expected to have a pet named Leo")
    assertEqual(Addon.pets["Leo"], Addon.current_pet)
    assertEqual(0, Addon.pets["Leo"]:totalTime())

    -- Dismiss Pet
    GetTime_VALUE = {20}
    UnitName_VALUE = {nil}
    GetPetExperience_VALUE = {60, 3600}
    Addon:UNIT_PET_EXPERIENCE()
    Addon:UNIT_PET()
    assert(Addon.pets["Leo"] ~= nil, "Expected to have a pet named Leo")
    assertEqual(nil, Addon.current_pet)
    assertEqual(10, Addon.pets["Leo"]:totalTime())
    -- When the pet is dimissed, we should have a message on the console
    assertEqual(1, #Console)
    assertEqual("Leo (0:00:10) Gained 60xp (360xp/min) / Lvl: 2% (600%/h)", Console[1])

    -- Calling the slash command
    SlashCmdList["XPBUDDY"]()
    assertEqual(4, #Console)
    assertEqual("Session (0:00:20) Gained 0xp (0xp/min) / Lvl: 0% (0%/h)", Console[2])
    assertEqual("Pets:", Console[3])
    assertEqual("- Leo (0:00:10) Gained 60xp (360xp/min) / Lvl: 2% (600%/h)", Console[4])
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
    -- When the pet is dimissed without xp, we should not have any message on the console
    assertEqual(0, #Console)
    
    -- Calling the slash command
    SlashCmdList["XPBUDDY"]()
    assertEqual(4, #Console)
    assertEqual("Session (0:00:20) Gained 0xp (0xp/min) / Lvl: 0% (0%/h)", Console[1])
    assertEqual("Pets:", Console[2])

    -- Order of elements is not fixed in a key=value Lua table, so the table
    -- pets={pet_name = meter} can be printed in any order
    assertConsoleContains("- Leo (0:00:10) Gained 0xp (0xp/min) / Lvl: 0% (0%/h)")
    assertConsoleContains("- Stan (0:00:00) Gained 0xp (0xp/min) / Lvl: 0% (0%/h)")
end

function test_no_print_when_no_xp_gain_from_pet()
    UnitName_VALUE = {"Leo"}
    Addon:UNIT_PET()
    assertEqual(0, #Console)

    UnitName_VALUE = {nil}
    Addon:UNIT_PET()
    assertEqual(0, #Console)
end
