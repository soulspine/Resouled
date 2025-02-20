local DADDY_HAUNT = Isaac.GetItemIdByName("Daddy Haunt")

if EID then
    EID:addCollectible(DADDY_HAUNT, "Not implemented yet", "Daddy Haunt")
end

local DADDY_HAUNT_FAMILIAR = Isaac.GetEntityVariantByName("Daddy Haunt")



---@param pickup EntityPickup
---@param variant PickupVariant
local function spawnFamiliarOnPickup(_, pickup, variant)
    Resouled:IterateOverPlayers(function(player, playerId)
        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        playerRunSave.Items.DaddyHaunt = {
            Spawned = false,
        }
        if player:HasCollectible(DADDY_HAUNT) and not playerRunSave.Items.DaddyHaunt.Spawned then
            Game():Spawn(EntityType.ENTITY_FAMILIAR, DADDY_HAUNT_FAMILIAR, player.Position, Vector.Zero, player, 0, Game():GetRoom():GetSpawnSeed())
            playerRunSave.Items.DaddyHaunt.Spawned = true
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, EntityPickup, PickupVariant.PICKUP_COLLECTIBLE)