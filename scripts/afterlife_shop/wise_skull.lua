---@param eye1 Color
---@param eye2 Color
---@return table
local function addPresetEyeColors(eye1, eye2)
    local table = {
        [1] = eye1, -- Eye1
        [2] = eye2 -- Eye2
    }
    return table
end


local presetColors = {
    FriendInsideMe = addPresetEyeColors(Color(255, 225, 0), Color(255, 0, 225)),
    Sans = addPresetEyeColors(Color(0, 200, 255), Color(0, 0, 0)),
    Red = addPresetEyeColors(Color(255, 0, 0), Color(255, 0, 0))
}

---@return table
local function getRandomPresetEyeColors()
    local presets = {}
    for _, colorTable in pairs(presetColors) do
        table.insert(presets, colorTable)
    end

    return presets[math.random(#presets)]
end