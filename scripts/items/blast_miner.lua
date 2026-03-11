local g = Game()

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

local TNT_THROW_SPEED = 10
local TNT_THROW_COOLDOWN = 5

local saveKey = "PickedUpTNTCrate"

local function makeSureCrateSpriteExistsInData(player)
    local runSave = Resouled.SaveManager.GetRunSave(player)
    if not runSave[saveKey] then return end

    local data = player:GetData()
    data.Resouled_PickedUpTNTCrate = Sprite()
    data.Resouled_PickedUpTNTCrate:Load(runSave[saveKey]["Anm2Path"], false)
    data.Resouled_PickedUpTNTCrate:ReplaceSpritesheet(0, runSave[saveKey]["Spritesheet"], false)
    data.Resouled_PickedUpTNTCrate:LoadGraphics()
    local anim = tostring(runSave[saveKey]["VarData"]).."Pickup"
    data.Resouled_PickedUpTNTCrate:Play(anim, true)
end

local CRATE_RENDER_OFFSET = Vector(0.5, -17)

---@param player EntityPlayer
---@param velocity Vector
local function throwPickedUpTNTCrate(player, velocity)
    local runSave = Resouled.SaveManager.GetRunSave(player)
    if not runSave[saveKey] then return end

    local tnt = g:Spawn(EntityType.ENTITY_PICKUP, TNT_VARIANT, player.Position, velocity, player, runSave[saveKey]["SubType"], runSave[saveKey]["Seed"]):ToPickup()
    if not tnt then return end

    tnt:SetVarData(runSave[saveKey]["VarData"])
    local data = tnt:GetData()
    data.Resouled_TNTCrateThrown = {
        Speed = -3,
        Accel = 0.15,
        Height = Vector(0, CRATE_RENDER_OFFSET.Y)
    }
    tnt.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    tnt.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    data["Resouled_BlastMiner"] = runSave[saveKey]["CrateData"]

    runSave[saveKey] = nil
    player:GetData().Resouled_PickedUpTNTCrate = nil

    player:AnimatePickup(Sprite(), nil, "HideItem")
end

---@param player EntityPlayer
---@param crate EntityPickup
local function playerPickupTNTCrate(player, crate)
    if player:GetHeldEntity() then return end
    local data = player:GetData()

    data.Resouled_PickedUpTNTCrateThrowCooldown = TNT_THROW_COOLDOWN

    if data.Resouled_PickedUpTNTCrate then
        throwPickedUpTNTCrate(player, Vector(TNT_THROW_SPEED, 0):Rotated(360 * math.random()))
    end

    local runSave = Resouled.SaveManager.GetRunSave(player)
    if runSave[saveKey] then return end

    local sprite = crate:GetSprite()
    runSave[saveKey] = {
        ["CrateData"] = crate:GetData()["Resouled_BlastMiner"],
        ["Anm2Path"] = sprite:GetFilename(),
        ["Spritesheet"] = crate:GetSprite():GetLayer(0):GetSpritesheetPath(),
        ["VarData"] = crate:GetVarData(),
        ["Seed"] = crate.InitSeed,
        ["SubType"] = crate.SubType
    }

    makeSureCrateSpriteExistsInData(player)

    player:AnimatePickup(data.Resouled_PickedUpTNTCrate, nil, "LiftItem")

    crate:Remove()
end

---@param player EntityPlayer
local function prePlaceBomb(_, player)
    if player:HasCollectible(BLAST_MINER) then
        player:GetData().Resouled_HasGigaBomb = player:GetNumGigaBombs() > 0
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_USE_BOMB, prePlaceBomb)

---@param player EntityPlayer
---@return EntityPickup
function Resouled:SpawnBlastMinerTNTCrate(player)
    local data = player:GetData()
    local subtype

    if (data.Resouled_HasGigaBomb and data.Resouled_HasGigaBomb == true) then
        data.Resouled_HasGigaBomb = nil
        subtype = TNT_GIGA_SUBTYPE
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) then
        subtype = TNT_MEGA_SUBTYPE
    else
        subtype = TNT_SUBTYPE
    end
    local tnt = g:Spawn(EntityType.ENTITY_PICKUP, TNT_VARIANT, player.Position, Vector.Zero, player, subtype, Resouled:NewSeed()):ToPickup()
    if not tnt then return end
    tnt.Velocity = player.Velocity * 2

    local tntData = tnt:GetData()
    ---@type BitSet128
    ---@diagnostic disable-next-line
    local flags = player:GetBombFlags()
    tntData["Resouled_BlastMiner"] = {
        ["Golden"] = player:HasGoldenBomb(),
        ["BobbyBomb"] = player:HasCollectible(CollectibleType.COLLECTIBLE_BOBBY_BOMB),
        ["Flags"] = {
            ["L"] = flags.l,
            ["R"] = flags.h
        },
        ["Player"] = tostring(player:GetPlayerIndex())
    }
    if tntData["Resouled_BlastMiner"]["Golden"] and tnt.SubType == TNT_SUBTYPE then
        tnt:GetSprite():ReplaceSpritesheet(0, "gfx_resouled/pickups/bombs/blast_miner_crate_gold.png", true)
    end
    g:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, tnt.Position, Vector.Zero, nil, 0, tnt.InitSeed)

    return tnt
end

---@param player EntityPlayer
---@param bomb EntityBomb
local function playerPlaceBomb(_, player, bomb)
    if player:HasCollectible(BLAST_MINER) then

        local tnt = Resouled:SpawnBlastMinerTNTCrate(player)

        local spelunkersPack = Isaac.GetItemIdByName("Spelunker's Pack")
        if spelunkersPack and player:HasCollectible(spelunkersPack) then
            playerPickupTNTCrate(player, tnt)
        end

        bomb:Remove()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_USE_BOMB, playerPlaceBomb)

---@param bomb EntityBomb
local function drFetusOverride(_, bomb)
    local player = bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer()
    if player then
        
        if player:HasCollectible(BLAST_MINER) then
            
            local tnt = Resouled:SpawnBlastMinerTNTCrate(player)

            playerPickupTNTCrate(player, tnt)
            throwPickedUpTNTCrate(player, bomb.Velocity)

            bomb:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, drFetusOverride)

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local runSave = Resouled.SaveManager.GetRunSave(player)
    if not runSave[saveKey] then return end
    makeSureCrateSpriteExistsInData(player)
    local data = player:GetData()
    local sprite = player:GetSprite()

    if not player:GetHeldSprite():GetFilename():lower():find("blast_miner")
        or (not sprite:GetAnimation():lower():find("pickup") and player.FrameCount%2 == 0)
    then
        player:AnimatePickup(data.Resouled_PickedUpTNTCrate, nil, "LiftItem")
    end

    player:SetShootingCooldown(5)

    if data.Resouled_PickedUpTNTCrateThrowCooldown then
        data.Resouled_PickedUpTNTCrateThrowCooldown = math.max(0, data.Resouled_PickedUpTNTCrateThrowCooldown - 1)
        if data.Resouled_PickedUpTNTCrateThrowCooldown == 0 then data.Resouled_PickedUpTNTCrateThrowCooldown = nil else return end
    end

    local input = player:GetShootingInput()
    if input.X ~= 0 or input.Y ~= 0 or Resouled.AccurateStats:GetEffectiveHP(player) <= 0 then
        local vel = input:Normalized():Resized(TNT_THROW_SPEED)
        throwPickedUpTNTCrate(player, vel + player.Velocity)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onPlayerUpdate)

---@param pickup EntityPickup
---@param collider Entity
local function onCollision(_, pickup, collider)
    if not tntSubtypes[pickup.SubType] then return end
    local player = collider:ToPlayer()
    if not player then return end
    if not (player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) and player:HasCollectible(BLAST_MINER)) then return end

    playerPickupTNTCrate(player, pickup)
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, onCollision, TNT_VARIANT)

---@param player EntityPlayer
local function onUseItem(_, _, _, player)
    if not player:HasCollectible(BLAST_MINER) then return end
    
    local index = tostring(player:GetPlayerIndex())
    ---@param pickup EntityPickup
    Resouled.Iterators:IterateOverRoomPickups(function(pickup)
        if pickup.Variant == TNT_VARIANT and tntSubtypes[pickup.SubType] then
            local data = pickup:GetData()
            if data["Resouled_BlastMiner"] and data["Resouled_BlastMiner"]["Player"] == index then
                Resouled:ExplodeBlastMinerTNTCrate(pickup)
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onUseItem, CollectibleType.COLLECTIBLE_REMOTE_DETONATOR)

---@param player EntityPlayer
local function preUseItem(_, _, _, player)
    for _, en in ipairs(Isaac.FindInRadius(player.Position, 25, EntityPartition.PICKUP)) do
        local pickup = en:ToPickup()
        if pickup and pickup.Variant == TNT_VARIANT and tntSubtypes[pickup.SubType] and pickup:GetVarData() < 3 then
            
            playerPickupTNTCrate(player, pickup)
            return true
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, preUseItem, CollectibleType.COLLECTIBLE_MOMS_BRACELET)

---@param en Entity
Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function(_, en)
    local player = en:ToPlayer()
    if not player then return end
    if player:GetData().Resouled_PickedUpTNTCrate then
        throwPickedUpTNTCrate(player, Vector(TNT_THROW_SPEED, 0):Rotated(360 * math.random()))
    end
end, EntityType.ENTITY_PLAYER)