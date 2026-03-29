local USE_AMOUNT = 12

local function postGameStarted()
    local player = Isaac.GetPlayer()
    for _ = 1, USE_AMOUNT do
        player:UseActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP, UseFlag.USE_NOANIM)
    end
    Resouled:RemoveActiveBuff(Resouled.Buffs.SMALL_CAP)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.SMALL_CAP, {
    {
        CallbackID = ModCallbacks.MC_POST_GAME_STARTED,
        Function = postGameStarted
    }
})