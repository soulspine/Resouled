local USE_AMOUNT = 12

local function postGameStarted()
    if not Resouled:ActiveBuffPresent(Resouled.Buffs.SMALL_CAP) then return end
    local player = Isaac.GetPlayer()
    for _ = 1, USE_AMOUNT do
        player:UseActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP, UseFlag.USE_NOANIM)
    end
    Resouled:RemoveActiveBuff(Resouled.Buffs.SMALL_CAP)
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.SMALL_CAP)