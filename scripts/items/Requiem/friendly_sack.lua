local FRIENDLY_SACK = Isaac.GetItemIdByName("Friendly Sack")

local ROOMS_TO_SPAWN_PICKUP = 1

local PICKUP_SPAWNING_TRANSLATOR = {
    [1] = PickupVariant.PICKUP_BOMB,
    [2] = PickupVariant.PICKUP_COIN,
    [3] = PickupVariant.PICKUP_HEART,
    [4] = PickupVariant.PICKUP_KEY,
}

---@param player EntityPlayer
local function postPlayerUpdate(_, player)
    local RUN_SAVE = SAVE_MANAGER.GetRunSave()
    if player:HasCollectible(FRIENDLY_SACK) then
        if not RUN_SAVE.ResouledFriendlySack then
            RUN_SAVE.ResouledFriendlySack = {}
        end
        RUN_SAVE.ResouledFriendlySack[player:GetPlayerIndex()] = 0
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postPlayerUpdate)

local function postNewRoom()
    local RUN_SAVE = SAVE_MANAGER.GetRunSave()
    if RUN_SAVE.ResouledFriendlySack then
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            local playerIndex = player:GetPlayerIndex()
            if RUN_SAVE.ResouledFriendlySack[playerIndex] then
                RUN_SAVE.ResouledFriendlySack[playerIndex] = RUN_SAVE.ResouledFriendlySack[playerIndex] + 1

                if RUN_SAVE.ResouledFriendlySack[playerIndex] >= ROOMS_TO_SPAWN_PICKUP then
                    RUN_SAVE.ResouledFriendlySack[playerIndex] = 0
                    local rng = RNG()
                    rng:SetSeed(Game():GetRoom():GetSpawnSeed())
                    ---@param entity Entity
                    Resouled.Iterators:IterateOverRoomEntities(function(entity)
                        local familiar = entity:ToFamiliar()
                        if familiar then
                            local spawnerPlayerIndex = familiar.SpawnerEntity:ToPlayer():GetPlayerIndex()
                            if spawnerPlayerIndex == playerIndex then
                                local pickupSpawnPos = familiar.Position
                                for _ = 1, Isaac.GetPlayer(spawnerPlayerIndex):GetCollectibleNum(FRIENDLY_SACK) do
                                    Resouled:NewSeed()

                                    local chosenPickup = PICKUP_SPAWNING_TRANSLATOR[rng:RandomInt(#PICKUP_SPAWNING_TRANSLATOR) + 1]

                                    Game():Spawn(EntityType.ENTITY_PICKUP, chosenPickup, pickupSpawnPos, Vector.Zero, nil, 0, rng:GetSeed())
                                end
                            end
                        end
                    end)
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, postNewRoom)