-- Mocks for Wow API
local mock_functions = {
    GetTime = {0},
    UnitXP = {0},
    UnitXPMax = {100},
    GetInstanceInfo = {"Azeroth"},
    GetPetExperience = {0, 100},
    IsInInstance = {false},
}

for func_name, default_value in pairs(mock_functions) do
    _G[func_name .. "_VALUE"] = default_value
    _G[func_name] = function (...)
        return table.unpack(_G[func_name .. "_VALUE"])
    end
end

SlashCmdList = {}

function CreateFrame()
    return {
        RegisterEvent = function() end,
        SetScript = function() end,
    }
end

-- Load our Addon resources
require('src/meter')
Addon = require('src/main')

-- Tests
function assertEqual(expected, actual)
    if expected ~= actual then
        error("Assertion failed: " .. expected .. " != " .. actual, 2)
    end
end

-- Collect all functions test_...() like pytest does
local function runTests()
    local failed = false

    for filename in io.popen('dir tests'):lines() do
        require('tests/' .. filename:sub(1, filename:len() - 4))
    end

    for func_name, func in pairs(_G) do
        Addon:init()
        for func_name, default_value in pairs(mock_functions) do
            _G[func_name .. "_VALUE"] = default_value
        end
        if func_name:sub(1, 5) == "test_" then
            local status_text
            local ok, retval = pcall(func)
            if ok then
                status_text = "\x1b[32mOK\x1b[0m"
            else
                status_text = "\x1b[31mFAIL\x1b[37m (" .. retval .. ")\x1b[0m"
                failed = true
            end
            print(func_name, status_text)
        end
    end

    if failed then
        error("Some tests failed")
    end
end

runTests()
