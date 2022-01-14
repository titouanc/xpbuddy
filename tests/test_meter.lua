function test_meter_toString()
    local meter = XPMeter:forPlayer("player")

    assertEqual("player (0:00:00) Gained 0xp (0xp/min) / Lvl: 0% (0%/h)", meter:toString())
    assertEqual("player (0:00:00) Gagné 0px (0px/min) / Niv: 0% (0%/h)", meter:toString("frFR"))
end
