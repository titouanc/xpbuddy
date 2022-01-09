local builtin_print = print

Console = {}

print = function (...) table.insert(Console, {...}) end

-- Compat Lua5.3 / Lua 5.1
if not unpack then unpack = table.unpack end

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
        return unpack(_G[func_name .. "_VALUE"])
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

local function beforeTestFunction()
    Console = {}
    for func_name, default_value in pairs(mock_functions) do
        _G[func_name .. "_VALUE"] = default_value
    end
    Addon:init()
end

-- Collect all functions test_...() like pytest does
local function runTests()
    local failed = false

    -- Find all files containing tests
    for filename in io.popen('ls tests'):lines() do
        -- require without the ".lua" extension
        require('tests/' .. filename:gsub(".lua$", ""))
    end

    for func_name, func in pairs(_G) do
        -- Find all functions in the form `test_...()`
        if func_name:sub(1, 5) == "test_" then
            beforeTestFunction()
            local status_text
            local ok, retval = pcall(func)
            if ok then
                builtin_print("\x1b[32m OK \x1b[0m " .. func_name)
            else
                builtin_print("\x1b[31mFAIL\x1b[0m " .. func_name ..  " \x1b[37m(" .. retval .. ")\x1b0m")
                failed = true
            end
        end
    end

    if failed then
        error("Some tests failed")
    end
end

runTests()
