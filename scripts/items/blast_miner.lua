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
        local tnt = g:Spawn(EntityType.ENTITY_PICKUP, TNT_VARIANT, player.Position, Vector.Zero, player, subtype, bomb.InitSeed)
        tnt.Velocity = player.Velocity * 2
        bomb:Remove()

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
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_USE_BOMB, playerPlaceBomb)



local saveKey = "PickedUpTNTCrate"

local function makeSureCrateSpriteExistsInData(player)
    local runSave = Resouled.SaveManager.GetRunSave(player)
    if not runSave[saveKey] then return end

    local data = player:GetData()
    data.Resouled_PickedUpTNTCrate = Sprite()
    data.Resouled_PickedUpTNTCrate:Load(runSave[saveKey]["Anm2Path"], false)
    data.Resouled_PickedUpTNTCrate:ReplaceSpritesheet(0, runSave[saveKey]["Spritesheet"], false)
    data.Resouled_PickedUpTNTCrate:LoadGraphics()
    data.Resouled_PickedUpTNTCrate:Play(tostring(runSave[saveKey]["VarData"]), true)
end

---@param player EntityPlayer
---@param crate EntityPickup
local function playerPickupTNTCrate(player, crate)
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
    local data = player:GetData()
    
    player:AnimatePickup(data.Resouled_PickedUpTNTCrate, true, tostring(runSave[saveKey]["VarData"]))

    crate:Remove()
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
    tnt.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_PITSONLY
    data["Resouled_BlastMiner"] = runSave[saveKey]["CrateData"]

    runSave[saveKey] = nil
    player:GetData().Resouled_PickedUpTNTCrate = nil
end

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local runSave = Resouled.SaveManager.GetRunSave(player)
    if not runSave[saveKey] then return end

    local input = player:GetShootingInput()
    if input.X ~= 0 or input.Y ~= 0 or Resouled.AccurateStats:GetEffectiveHP(player) <= 0 then
        local vel = input:Normalized():Resized(10)
        throwPickedUpTNTCrate(player, vel)
    end

    player:SetShootingCooldown(5)
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onPlayerUpdate)

---@param player EntityPlayer
---@return table
local function getWalkAnimFromPlayer(player)
    local vel = player.Velocity
    if vel:LengthSquared() < 0.1 then
        return {
            Anim = "PickupWalkDown",
            Frame = 1
        }
    end

    local degrees = vel:GetAngleDegrees()%360
    local anim

    if degrees < 45 or degrees >= 315 then
        anim = "PickupWalkRight"
    elseif degrees >= 45 and degrees < 135 then
        anim = "PickupWalkDown"
    elseif degrees >= 135 and degrees < 225 then
        anim = "PickupWalkLeft"
    elseif degrees >= 225 and degrees < 315 then
        anim = "PickupWalkUp"
    end

    return {
        Anim = anim,
        Frame = player.FrameCount%20 --20 is the walking anim length
    }
end

---@param player EntityPlayer
local function onPlayerRender(_, player)
    local runSave = Resouled.SaveManager.GetRunSave(player)
    if not runSave[saveKey] then return end
    local sprite = player:GetSprite()
    if sprite:IsPlaying("Pickup") then return end

    ::CreateSprite::
    ---@type Sprite
    local crateSprite = player:GetData().Resouled_PickedUpTNTCrate
    if not crateSprite then
        makeSureCrateSpriteExistsInData(player)
        goto CreateSprite
    end
    
    local renderPos = Isaac.WorldToScreen(player.Position + player:GetFlyingOffset() + player.SpriteOffset)
    sprite:RemoveOverlay()
        
    local anim = getWalkAnimFromPlayer(player)
    sprite:SetFrame(anim.Anim, anim.Frame)
        
    sprite:Render(renderPos)
        
    crateSprite:Render(renderPos + CRATE_RENDER_OFFSET)

    return false
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, onPlayerRender)

---@param item CollectibleType
---@param player EntityPlayer
local function onUseItem(_, item, _, player)
    if not player:HasCollectible(BLAST_MINER) then return end
    if item == CollectibleType.COLLECTIBLE_REMOTE_DETONATOR then
        
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
    elseif item == CollectibleType.COLLECTIBLE_MOMS_BRACELET then
        
        for _, en in ipairs(Isaac.FindInRadius(player.Position, 25, EntityPartition.PICKUP)) do
            local pickup = en:ToPickup()
            if pickup and pickup.Variant == TNT_VARIANT and tntSubtypes[pickup.SubType] and pickup:GetVarData() < 3 then
                
                playerPickupTNTCrate(player, pickup)
                return
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onUseItem)
