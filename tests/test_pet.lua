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

    -- Dismiss Pet
    GetTime_VALUE = {20}
    UnitName_VALUE = {"Stan"}
    Addon:UNIT_PET()
    assert(Addon.pets["Stan"] ~= nil, "Expected to have a pet named Stan")
    assertEqual(Addon.pets["Stan"], Addon.current_pet)
    assertEqual(10, Addon.pets["Leo"]:totalTime())
    assertEqual(0, Addon.pets["Stan"]:totalTime())
end
