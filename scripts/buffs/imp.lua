local game = Game()
local itemsList = {}

local collectiblesWhitelist = {
    [CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK] = true,
    [CollectibleType.COLLECTIBLE_BLOOD_BOMBS] = true,
    [CollectibleType.COLLECTIBLE_BOBS_CURSE] = true,
    [CollectibleType.COLLECTIBLE_BOBBY_BOMB] = true,
    [CollectibleType.COLLECTIBLE_BOOM] = true,
    [CollectibleType.COLLECTIBLE_BRIMSTONE_BOMBS] = true,
    [CollectibleType.COLLECTIBLE_BUTT_BOMBS] = true,
    [CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER] = true,
    [CollectibleType.COLLECTIBLE_DR_FETUS] = true,
    [CollectibleType.COLLECTIBLE_FAST_BOMBS] = true,
    [CollectibleType.COLLECTIBLE_GHOST_BOMBS] = true,
    [CollectibleType.COLLECTIBLE_GLITTER_BOMBS] = true,
    [CollectibleType.COLLECTIBLE_HOT_BOMBS] = true,
    [CollectibleType.COLLECTIBLE_KAMIKAZE] = true,
    [CollectibleType.COLLECTIBLE_MAMA_MEGA] = true,
    [CollectibleType.COLLECTIBLE_MR_BOOM] = true,
    [CollectibleType.COLLECTIBLE_MR_MEGA] = true,
    [CollectibleType.COLLECTIBLE_NANCY_BOMBS] = true,
    [CollectibleType.COLLECTIBLE_PYRO] = true,
    [CollectibleType.COLLECTIBLE_PYROMANIAC] = true,
    [CollectibleType.COLLECTIBLE_REMOTE_DETONATOR] = true,
    [CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR] = true,
    [CollectibleType.COLLECTIBLE_SAD_BOMBS] = true,
    [CollectibleType.COLLECTIBLE_STICKY_BOMBS] = true,
    [Isaac.GetItemIdByName("Blast Miner TNT!")] = true
}

local itemConfig = Isaac.GetItemConfig()
for i = 1, #itemConfig:GetCollectibles() do
    local item = itemConfig:GetCollectible(i)
    if item and game:GetItemPool():CanSpawnCollectible(i, false) and (item.AddBombs > 0 or collectiblesWhitelist[i] or item.Name:find("Bomb") or item.Name:find("Bombs")) then
        table.insert(itemsList, i)
    end
end

---@param pickup EntityPickup
local function postPickupIint(_, pickup)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.IMP) and game:GetRoom():GetType() == RoomType.ROOM_TREASURE then
        local rng = RNG(pickup.InitSeed)
        pickup:AddCollectibleCycle(itemsList[rng:RandomInt(#itemsList)+1])
        Resouled:RemoveActiveBuff(Resouled.Buffs.IMP)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupIint, PickupVariant.PICKUP_COLLECTIBLE)