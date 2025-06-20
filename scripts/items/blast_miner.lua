local BLAST_MINER = Isaac.GetItemIdByName("Blast Miner TNT!")

if EID then
    EID:addCollectible(BLAST_MINER, "Replaces your bombs with pushable tnt crates # The crates explode in 5 hits and use your bomb effects")
end

local TNT_VARIANT = Isaac.GetEntityVariantByName("Blast Miner TNT")
local TNT_SUBTYPE = Isaac.GetEntitySubTypeByName("Blast Miner TNT")

---@param player EntityPlayer
---@param bomb EntityBomb
local function playerPlaceBomb(_, player, bomb)
    if player:HasCollectible(BLAST_MINER) then
        local tnt = Game():Spawn(EntityType.ENTITY_PICKUP, TNT_VARIANT, player.Position, Vector.Zero, player, TNT_SUBTYPE, bomb.InitSeed)
        tnt.Velocity = player.Velocity * 2
        bomb:Remove()
        local ROOM_SAVE = SAVE_MANAGER.GetRoomSave(tnt)
        ROOM_SAVE.Spawner = player:GetPlayerIndex()
        Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, tnt.Position, Vector.Zero, nil, 0, tnt.InitSeed)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_USE_BOMB, playerPlaceBomb)