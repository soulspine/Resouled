local cursesToAdd = {
    [1] = LevelCurse.CURSE_OF_THE_LOST,
    [2] = LevelCurse.CURSE_OF_THE_UNKNOWN,
    [3] = LevelCurse.CURSE_OF_MAZE,
    [4] = LevelCurse.CURSE_OF_DARKNESS,
    [5] = 1<<Resouled.Curses.CURSE_OF_PAIN-1,
    [6] = 1<<Resouled.Curses.CURSE_OF_GREED-1,
}

local function postGameStart()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.FORBIDDEN_CRANIUM) then
        for i = 1, #cursesToAdd do
            Game():GetLevel():AddCurse(cursesToAdd[i], false)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStart)

---@param pickup EntityPickup
local function postPickupInit(_, pickup)
    if Game():GetRoom():GetType() == RoomType.ROOM_BOSS and Resouled:ActiveBuffPresent(Resouled.Buffs.FORBIDDEN_CRANIUM) then
        pickup:AddCollectibleCycle(Resouled:GetRandomItemFromPool(ItemPoolType.POOL_DEVIL, RNG(pickup.InitSeed), 4))

        Resouled:RemoveActiveBuff(Resouled.Buffs.FORBIDDEN_CRANIUM)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupInit, PickupVariant.PICKUP_COLLECTIBLE)

Resouled:AddBuffDescription(Resouled.Buffs.FORBIDDEN_CRANIUM, "You get curse of the lost, unknown, maze, darkness, pain, greed but the first boss item has a q4 devil deal item cycle")