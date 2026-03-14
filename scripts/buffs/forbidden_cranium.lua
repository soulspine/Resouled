local cursesToAdd = {
    [1] = LevelCurse.CURSE_OF_THE_LOST,
    [2] = LevelCurse.CURSE_OF_THE_UNKNOWN,
    [3] = LevelCurse.CURSE_OF_MAZE,
    [4] = LevelCurse.CURSE_OF_DARKNESS,
    [5] = 1<<Resouled.Curses.CURSE_OF_PAIN-1,
    [6] = 1<<Resouled.Curses.CURSE_OF_GREED-1,
}

local function postGameStart()
    for i = 1, #cursesToAdd do
        Resouled.Game:GetLevel():AddCurse(cursesToAdd[i], false)
    end
end

---@param pickup EntityPickup
local function postPickupInit(_, pickup)
    if Resouled.Game:GetRoom():GetType() == RoomType.ROOM_BOSS then
        pickup:AddCollectibleCycle(Resouled:GetRandomItemFromPool(ItemPoolType.POOL_DEVIL, RNG(pickup.InitSeed), 4))

        Resouled:RemoveActiveBuff(Resouled.Buffs.FORBIDDEN_CRANIUM)
        Resouled:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStart)
        Resouled:RemoveCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupInit)
    end
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.FORBIDDEN_CRANIUM, {
    {
        CallbackID = ModCallbacks.MC_POST_GAME_STARTED,
        Function = postGameStart
    },
    {
        CallbackID = ModCallbacks.MC_POST_PICKUP_INIT,
        Function = postPickupInit,
        CallbackParams = PickupVariant.PICKUP_COLLECTIBLE
    }
})