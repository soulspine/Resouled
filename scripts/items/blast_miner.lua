local BLAST_MINER = Isaac.GetItemIdByName("Blast Miner TNT!")

local e = Resouled.EID

if EID then
    EID:addCollectible(BLAST_MINER, " +5 "..e:Bomb().." # "..e:FadeBlue("Replaces your bombs").." with pushable tnt crates # The crates explode in 3 hits and "..e:FadeBlue("use your bomb effects"))
end

local TNT_VARIANT = Isaac.GetEntityVariantByName("Blast Miner TNT")
local TNT_SUBTYPE = Isaac.GetEntitySubTypeByName("Blast Miner TNT")
local TNT_MEGA_SUBTYPE = Isaac.GetEntitySubTypeByName("Blast Miner TNT Mega")

---@param player EntityPlayer
---@param bomb EntityBomb
local function playerPlaceBomb(_, player, bomb)
    if player:HasCollectible(BLAST_MINER) then
        local subtype
        if player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) then
            subtype = TNT_MEGA_SUBTYPE
        else
            subtype = TNT_SUBTYPE
        end
        local tnt = Game():Spawn(EntityType.ENTITY_PICKUP, TNT_VARIANT, player.Position, Vector.Zero, player, subtype, bomb.InitSeed)
        tnt.Velocity = player.Velocity * 2
        bomb:Remove()
        local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave(tnt)
        ROOM_SAVE.BlastMiner = {
            GOLDEN = player:HasGoldenBomb(),
            BOBBYBOMB = player:HasCollectible(CollectibleType.COLLECTIBLE_BOBBY_BOMB),
            FLAGS = player:GetBombFlags()
        }
        if ROOM_SAVE.BlastMiner.GOLDEN and tnt.SubType == TNT_SUBTYPE then
            tnt:GetSprite():ReplaceSpritesheet(0, "gfx/pickups/bombs/blast_miner_crate_gold.png", true)
        end
        Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, tnt.Position, Vector.Zero, nil, 0, tnt.InitSeed)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_USE_BOMB, playerPlaceBomb)