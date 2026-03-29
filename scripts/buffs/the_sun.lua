---@param player EntityPlayer
local function prePlayerDeath(_, player)
    Resouled:RemoveActiveBuff(Resouled.Buffs.THE_SUN)
    Resouled:RemoveCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, prePlayerDeath)
    player:GetData().Resouled_TheSunBuffRevive = true
    return false
end

---@param player EntityPlayer
local function postPlayerRevive(_, player)
    local data = player:GetData()
    if data.Resouled_TheSunBuffRevive then
        player:UseCard(Card.CARD_SUN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)

        data.Resouled_TheSunBuffRevive = nil

        Resouled:RemoveCallback(ModCallbacks.MC_POST_PLAYER_REVIVE, postPlayerRevive)
    end
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.THE_SUN, {
    {
        CallbackID = ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH,
        Function = prePlayerDeath,
        Priority = CallbackPriority.IMPORTANT
    },
    {
        CallbackID = ModCallbacks.MC_POST_PLAYER_REVIVE,
        Function = postPlayerRevive
    }
})