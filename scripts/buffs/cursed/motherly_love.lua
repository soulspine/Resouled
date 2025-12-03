local UPDATES_BETWEEN_CHANCE_CHECK = 50
local CHANCE_TO_SPAWN_LEG = 0.11

local function curseActive()
    return Resouled:ActiveBuffPresent(Resouled.Buffs.MOTHERLY_LOVE) or Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.EverythingIsCursed)
end

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    if (not curseActive())
    or (player.FrameCount%UPDATES_BETWEEN_CHANCE_CHECK ~= 0)
    or (math.random() >= CHANCE_TO_SPAWN_LEG)
    then return end

    Game():Spawn(1000, 29, player.Position, Vector.Zero, player, 0, Random())
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onPlayerUpdate)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.MOTHERLY_LOVE)