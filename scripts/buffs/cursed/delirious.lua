local CHANCE_TO_REPLACE_ROOM = 0.15

local STAGES_BLACKLIST = {
    [9] = true,  -- HUSH
    [13] = true, -- HOME
}

local function curseActive()
    return Resouled:ActiveBuffPresent(Resouled.Buffs.DELIRIOUS) or Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.EverythingIsCursed)
end

---@param slot LevelGeneratorRoom
---@param config RoomConfigRoom
---@param seed integer
local function prePlaceRoom(_, slot, config, seed)
    local stage = Game():GetLevel():GetStage()

    if (not curseActive())
    or (STAGES_BLACKLIST[stage])
    or (13 * slot:Row() + slot:Column() == 84)
    or (RNG(seed):RandomFloat() >= CHANCE_TO_REPLACE_ROOM)
    then return end

    stage = (math.floor(stage * 1.5 + 0.5)) + 1

    return RoomConfig.GetRoomByStageTypeAndVariant(stage, config.Type, config.Variant)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, prePlaceRoom)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.DELIRIOUS)