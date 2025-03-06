local SPAWN_CHANCE_PER_PEDESTAL = 0.33

local function onNewRoomEnter()
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        if Resouled:CustomCursePresent(Resouled.Blessings.BLESSING_OF_ISAAC) then
            local room = Game():GetRoom()
            if room:IsFirstVisit() then
                local rng = RNG()
                rng:SetSeed(room:GetSpawnSeed(), 0)

                local roomPedestalCount = Isaac.CountEntities(nil, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
                local grantChance = SPAWN_CHANCE_PER_PEDESTAL * roomPedestalCount

                if player:GetActiveItem(ActiveSlot.SLOT_POCKET2) == CollectibleType.COLLECTIBLE_NULL and rng:RandomFloat() < grantChance then
                    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_D6, ActiveSlot.SLOT_POCKET2, true)
                end
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onNewRoomEnter)