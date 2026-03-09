local BLAST_MINER = Resouled.Enums.Items.BLAST_MINER

local TNT_VARIANT = Isaac.GetEntityVariantByName("Blast Miner TNT")
local TNT_SUBTYPE = Isaac.GetEntitySubTypeByName("Blast Miner TNT")
local TNT_MEGA_SUBTYPE = Isaac.GetEntitySubTypeByName("Blast Miner TNT Mega")
local TNT_GIGA_SUBTYPE = Isaac.GetEntitySubTypeByName("Blast Miner TNT Giga")

local tntSubtypes = {
    [TNT_SUBTYPE] = true,
    [TNT_MEGA_SUBTYPE] = true,
    [TNT_GIGA_SUBTYPE] = true
}

---@param player EntityPlayer
local function prePlaceBomb(_, player)
    if player:HasCollectible(BLAST_MINER) then
        player:GetData().Resouled_HasGigaBomb = player:GetNumGigaBombs() > 0
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_USE_BOMB, prePlaceBomb)

---@param player EntityPlayer
---@param bomb EntityBomb
local function playerPlaceBomb(_, player, bomb)
    if player:HasCollectible(BLAST_MINER) then
        local data = player:GetData()
        local subtype
        player:GetNumGigaBombs()
        if (data.Resouled_HasGigaBomb and data.Resouled_HasGigaBomb == true) then
            data.Resouled_HasGigaBomb = nil
            subtype = TNT_GIGA_SUBTYPE
        elseif player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) then
            subtype = TNT_MEGA_SUBTYPE
        else
            subtype = TNT_SUBTYPE
        end
        local tnt = Game():Spawn(EntityType.ENTITY_PICKUP, TNT_VARIANT, player.Position, Vector.Zero, player, subtype, bomb.InitSeed)
        tnt.Velocity = player.Velocity * 2
        bomb:Remove()

        local tntData = tnt:GetData()
        ---@type BitSet128
        ---@diagnostic disable-next-line
        local flags = player:GetBombFlags()

        tntData["BlastMiner"] = {
            ["Golden"] = player:HasGoldenBomb(),
            ["BobbyBomb"] = player:HasCollectible(CollectibleType.COLLECTIBLE_BOBBY_BOMB),
            ["Flags"] = {
                ["L"] = flags.l,
                ["R"] = flags.h
            },
            ["Player"] = tostring(player:GetPlayerIndex())
        }
        if tntData["BlastMiner"]["Golden"] and tnt.SubType == TNT_SUBTYPE then
            tnt:GetSprite():ReplaceSpritesheet(0, "gfx_resouled/pickups/bombs/blast_miner_crate_gold.png", true)
        end
        Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, tnt.Position, Vector.Zero, nil, 0, tnt.InitSeed)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_USE_BOMB, playerPlaceBomb)

---@param player EntityPlayer
local function onUseItem(_, _, _, player)
    if player:HasCollectible(BLAST_MINER) then
        local index = tostring(player:GetPlayerIndex())
        ---@param pickup EntityPickup
        Resouled.Iterators:IterateOverRoomPickups(function(pickup)
            if pickup.Variant == TNT_VARIANT and tntSubtypes[pickup.SubType] then
                local data = pickup:GetData()
                if data["BlastMiner"] and data["BlastMiner"]["Player"] == index then
                    Resouled:ExplodeBlastMinerTNTCrate(pickup, data["BlastMiner"]["Flags"])
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onUseItem, CollectibleType.COLLECTIBLE_REMOTE_DETONATOR)