function test_gain_player_xp_in_world()
    Addon:PLAYER_ENTERING_WORLD()
    assertEqual(0, Addon.session.total_gained_xp)
    assertEqual(0, #Addon.instances)
    assertEqual(0, #Addon.pets)

    -- "Kill 1 mob for 50xp" (lvl1=100xp)
    GetTime_VALUE = {10}
    UnitXP_VALUE = {50}
    Addon:PLAYER_XP_UPDATE()
    -- We should be at 50% of the level, and gained 50xp in total
    assertEqual(50, Addon.session.total_gained_xp)
    assertEqual(0.5, Addon.session.total_gained_lvl)
    assertEqual(10, Addon.session:totalTime())

    -- "Turn in quest for 80xp" (lvl2=200xp)
    GetTime_VALUE = {20}
    UnitXP_VALUE = {30}
    UnitXPMax_VALUE = {200}
    Addon:PLAYER_XP_UPDATE()
    -- We should be at 15% of the next level, and gained 130xp in total
    assertEqual(130, Addon.session.total_gained_xp)
    assertEqual(1.15, Addon.session.total_gained_lvl)
    assertEqual(20, Addon.session:totalTime())

    assertEqual(0, #Addon.instances)
    assertEqual(0, #Addon.pets)
end

function test_gain_player_xp_in_instance()
    IsInInstance_VALUE = {true}
    GetInstanceInfo_VALUE = {"BRD"}

    Addon:PLAYER_ENTERING_WORLD()
    assertEqual(0, Addon.session.total_gained_xp)
    assert(Addon.instances["BRD"] ~= nil, "Expected to have instance BRD")
    assertEqual(Addon.instances["BRD"], Addon.current_instance)

    -- "Kill 1 mob for 30xp" (lvl1=100xp)
    GetTime_VALUE = {10}
    UnitXP_VALUE = {30}
    Addon:PLAYER_XP_UPDATE()
    -- Both the session XP and the instance XP should be increased
    assertEqual(30, Addon.session.total_gained_xp)
    assertEqual(0.3, Addon.session.total_gained_lvl)
    assertEqual(10, Addon.session:totalTime())
    assertEqual(30, Addon.current_instance.total_gained_xp)
    assertEqual(0.3, Addon.current_instance.total_gained_lvl)
    assertEqual(10, Addon.current_instance:totalTime())

    -- Get out of instance
    GetTime_VALUE = {20}
    IsInInstance_VALUE = {false}
    GetInstanceInfo_VALUE = {"Azeroth"}
    Addon:PLAYER_ENTERING_WORLD()
    assertEqual(nil, Addon.current_instance)
    assertEqual(20, Addon.session:totalTime())
    assertEqual(20, Addon.instances["BRD"]:totalTime())
    assertEqual(1, #Console)
    assertEqual("BRD (0:00:20) Gained 30xp (90xp/min) / Lvl: 30% (5400%/h)", Console[1])

    -- "Kill 1 mob for 30xp" (lvl1=100xp)
    GetTime_VALUE = {30}
    UnitXP_VALUE = {60}
    Addon:PLAYER_XP_UPDATE()
    -- Only the session XP should be increased
    assertEqual(60, Addon.session.total_gained_xp)
    assertEqual(0.6, Addon.session.total_gained_lvl)
    assertEqual(30, Addon.session:totalTime())
    assertEqual(30, Addon.instances["BRD"].total_gained_xp)
    assertEqual(0.3, Addon.instances["BRD"].total_gained_lvl)
    assertEqual(20, Addon.instances["BRD"]:totalTime())
end
