local TNT_VARIANT = Isaac.GetEntityVariantByName("Blast Miner TNT")
local TNT_SUBTYPE = Isaac.GetEntitySubTypeByName("Blast Miner TNT")

local VELOCITY_MULTIPLIER = 0.25
local BOBBY_BOMBS_VELOCITY_MULTIPLIER = 4

local EFFECT_VARIANT = Isaac.GetEntityVariantByName("Wood Particle")
local EFFECT_SUBTYPE = Isaac.GetEntitySubTypeByName("Wood Particle")
local EFFECT_GOLD_SUBTYPE = Isaac.GetEntitySubTypeByName("Wood Gold Particle")

local AMOUNT = 20
local START_OFFSET = 10
local MIN_OFFSET_LOSS = 75
local MAX_OFFSET_LOSS = 0
local WEIGHT = 1.5
local BOUNCINESS = 0.2
local SLIPPERINESS = 0
local SIZE = 1
local MAX_SIZE_VARIETY = 0
local SPEED = 25

---@param tnt EntityPickup
---@param flags TearFlags
local EXPLODE = function(tnt, flags)
    local bomb = Game():Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_NORMAL, tnt.Position, Vector.Zero, nil, 0, tnt.InitSeed):ToBomb()
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave(tnt)
    bomb:AddTearFlags(flags)
    bomb:SetExplosionCountdown(0)
    bomb:Update()
    tnt:SetVarData(5)
    tnt:GetSprite():Play("5", true)
    tnt.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    tnt.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

    local golden = ROOM_SAVE.BlastMiner.GOLDEN
    local subtype
    if golden then
        subtype = EFFECT_GOLD_SUBTYPE
    else
        subtype = EFFECT_SUBTYPE
    end

    if tnt.Velocity:LengthSquared() < 0.01 then
        Resouled:SpawnRealisticParticles(GridCollisionClass.COLLISION_SOLID, tnt.Position, AMOUNT + math.random(-5, 5), START_OFFSET, MIN_OFFSET_LOSS, MAX_OFFSET_LOSS, WEIGHT, BOUNCINESS, SLIPPERINESS, SIZE, MAX_SIZE_VARIETY, SPEED, nil, nil, false, EFFECT_VARIANT, subtype)
    else
        Resouled:SpawnRealisticParticles(GridCollisionClass.COLLISION_SOLID, tnt.Position, AMOUNT + math.random(-5, 5), START_OFFSET, MIN_OFFSET_LOSS, MAX_OFFSET_LOSS, WEIGHT, BOUNCINESS, SLIPPERINESS, SIZE, MAX_SIZE_VARIETY, SPEED + tnt.Velocity:Length(), tnt.Velocity:GetAngleDegrees(), 45 - math.floor(tnt.Velocity:Length()/2), false, EFFECT_VARIANT, subtype)
    end
end

---@param pickup EntityPickup
local function postPickupInit(_, pickup)
    if pickup.SubType == TNT_SUBTYPE then
        local sprite = pickup:GetSprite()
        local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave(pickup)
        local ROOM_SAVE_POSITION = SAVE_MANAGER.GetRoomFloorSave(pickup.Position)
        ROOM_SAVE.BlastMiner = ROOM_SAVE_POSITION.BlastMiner
        if ROOM_SAVE.BlastMiner and ROOM_SAVE.BlastMiner.GOLDEN then
            sprite:ReplaceSpritesheet(0, "gfx/pickups/bombs/blast_miner_crate_gold.png", true)
        end
        sprite:Play("0", true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupInit, TNT_VARIANT)

---@param pickup EntityPickup
local function onPickupUpdate(_, pickup)
    local sprite = pickup:GetSprite()
    if pickup.SubType == TNT_SUBTYPE then
        local varData = pickup:GetVarData()

        if sprite:GetAnimation() ~= varData then
            sprite:Play(tostring(varData), true)
        end

        local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave(pickup)
        if ROOM_SAVE.BlastMiner and pickup:GetVarData() < 5 then
            if pickup.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_ALL then
                pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            end
            if pickup.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_GROUND then
                pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            end
            local data = pickup:GetData()
            
            if data.Explode then
                EXPLODE(pickup, ROOM_SAVE.BlastMiner.FLAGS)
            end
            
            local bobbyBombPresent = ROOM_SAVE.BlastMiner.BOBBYBOMB
            ---@type EntityNPC | nil
            local nearestEnemy = nil
            
            ---@param entity Entity
            Resouled.Iterators:IterateOverRoomEntities(function(entity)
                
                if bobbyBombPresent then
                    local npc = entity:ToNPC()
                    if npc and npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() then
                        if not nearestEnemy then
                            nearestEnemy = npc
                        elseif npc.Position:Distance(pickup.Position) < nearestEnemy.Position:Distance(pickup.Position) then
                            nearestEnemy = npc
                        end
                    end
                end
                
                local tear = entity:ToTear()
                if tear and tear.Position:Distance(pickup.Position) - tear.Size <= pickup.Size then
                    tear:Die()
                    pickup:SetVarData(pickup:GetVarData() + 1)
                end
                
                local bomb = entity:ToBomb()
                if bomb and bomb:GetExplosionCountdown() <= 0 and Resouled:IsInBombBlastRadius(pickup, bomb) then
                    data.Explode = true
                end

                local knife = entity:ToKnife()
                if knife and knife.Position:Distance(pickup.Position) - knife.Size <= pickup.Size then
                    pickup:SetVarData(pickup:GetVarData() + 1)
                end

                local laser = entity:ToLaser()
                if laser then
                    local laserDamage = false
                    local samples = laser:GetNonOptimizedSamples()
                    for i = 0, #samples - 1 do
                        local samplePos = samples:Get(i)
                        if samplePos:Distance(pickup.Position) - laser.Size <= pickup.Size then
                            laserDamage = true
                        end
                    end
                    if laserDamage then
                        pickup:SetVarData(pickup:GetVarData() + 1)
                    end
                end
            end)

            if nearestEnemy then
                if pickup.Position:Distance(nearestEnemy.Position) > pickup.Size + nearestEnemy.Size then
                    pickup.Velocity = (pickup.Velocity + (nearestEnemy.Position - pickup.Position):Normalized()) * BOBBY_BOMBS_VELOCITY_MULTIPLIER
                else
                    EXPLODE(pickup, ROOM_SAVE.BlastMiner.FLAGS)
                    nearestEnemy = nil
                end
            end

            varData = pickup:GetVarData()

            if sprite:GetAnimation() ~= varData then
                sprite:Play(tostring(varData), true)
            end
            
            if varData >= 5 then
                EXPLODE(pickup, ROOM_SAVE.BlastMiner.FLAGS)
            end
        else
            if pickup.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE then
                pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            end
            if pickup.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_GROUND then
                pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            end
            pickup.Velocity = Vector.Zero
        end
        pickup.Velocity = pickup.Velocity * VELOCITY_MULTIPLIER
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_UPDATE, onPickupUpdate, TNT_VARIANT)

local function preRoomLeave()
    ---@param entity Entity
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local pickup = entity:ToPickup()
        if pickup and pickup.Variant == TNT_VARIANT and pickup.SubType == TNT_SUBTYPE then
            local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave(pickup)
            local ROOM_SAVE_POSITION = SAVE_MANAGER.GetRoomFloorSave(pickup.Position)
            if ROOM_SAVE.BlastMiner then
                ROOM_SAVE_POSITION.BlastMiner = ROOM_SAVE.BlastMiner
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, preRoomLeave)