local FRIENDLY_SACK = Isaac.GetItemIdByName("Friendly Sack")

if EID then
    EID:addCollectible(FRIENDLY_SACK, "After clearing 6 rooms, each familiar spawns a pickup")
end

local ROOMS_TO_SPAWN_PICKUP = 6

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
        if not RUN_SAVE.ResouledFriendlySack[tostring(player:GetPlayerIndex())] then
            RUN_SAVE.ResouledFriendlySack[tostring(player:GetPlayerIndex())] = 0
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postPlayerUpdate)

local function postNewRoom()
    local RUN_SAVE = SAVE_MANAGER.GetRunSave()
    
    if RUN_SAVE.ResouledFriendlySack then

        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)

            local playerIndex = player:GetPlayerIndex()
            local indexKey = tostring(playerIndex)

            if RUN_SAVE.ResouledFriendlySack[indexKey] then

                RUN_SAVE.ResouledFriendlySack[indexKey] = RUN_SAVE.ResouledFriendlySack[indexKey] + 1

                if RUN_SAVE.ResouledFriendlySack[indexKey] >= ROOMS_TO_SPAWN_PICKUP then

                    RUN_SAVE.ResouledFriendlySack[indexKey] = 0

                    local rng = RNG()

                    rng:SetSeed(Game():GetRoom():GetSpawnSeed())

                    ---@param entity Entity
                    Resouled.Iterators:IterateOverRoomEntities(function(entity)

                        local familiar = entity:ToFamiliar()

                        if familiar then
                            local spawnerPlayer = Resouled:TryFindPlayerSpawner(familiar)
                            if spawnerPlayer then

                                local spawnerPlayerIndex = spawnerPlayer:GetPlayerIndex()

                                if spawnerPlayerIndex == playerIndex then

                                    local pickupSpawnPos = familiar.Position

                                    for _ = 1, Isaac.GetPlayer(spawnerPlayerIndex):GetCollectibleNum(FRIENDLY_SACK) do
                                        Resouled:NewSeed()
                                        
                                        local chosenPickup = PICKUP_SPAWNING_TRANSLATOR[rng:RandomInt(#PICKUP_SPAWNING_TRANSLATOR) + 1]
                                        
                                        Game():Spawn(EntityType.ENTITY_PICKUP, chosenPickup, pickupSpawnPos, Vector.Zero, nil, 0, rng:GetSeed())
                                    end
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