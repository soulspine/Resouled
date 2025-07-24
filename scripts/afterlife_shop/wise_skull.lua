local WiseSkull = Resouled.Stats.WiseSkull

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

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == WiseSkull.Variant and npc.SubType == WiseSkull.SubType then
        local sprite = npc:GetSprite()
        
        sprite:Play("Idle", true)


        local eye1 = sprite:GetLayer("Eye1")
        local eye2 = sprite:GetLayer("Eye2")

        if eye1 and eye2 then
            local colors = getRandomPresetEyeColors()

            eye1:SetColor(colors[1])
            eye2:SetColor(colors[2])
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, WiseSkull.Type)

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    if npc.Variant == WiseSkull.Variant and npc.SubType == WiseSkull.SubType then
        local FileSave = SAVE_MANAGER.GetPersistentSave()
        if not FileSave then FileSave = {} end
        if not FileSave.WiseSkullKilled then FileSave.WiseSkullKilled = false end

        FileSave.WiseSkullKilled = true
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath, WiseSkull.Type)