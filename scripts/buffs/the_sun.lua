---@param player EntityPlayer
local function prePlayerDeath(_, player)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.THE_SUN) then
        Resouled:RemoveActiveBuff(Resouled.Buffs.THE_SUN)
        player:GetData().Resouled_TheSunBuffRevive = true
        return false
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, CallbackPriority.IMPORTANT, prePlayerDeath)

---@param player EntityPlayer
local function postPlayerRevive(_, player)
    local data = player:GetData()
    if data.Resouled_TheSunBuffRevive then
        player:UseCard(Card.CARD_SUN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)

        data.Resouled_TheSunBuffRevive = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_REVIVE, postPlayerRevive)