local g = Game()

local TNT_VARIANT = Isaac.GetEntityVariantByName("Blast Miner TNT")
local TNT_SUBTYPE = Isaac.GetEntitySubTypeByName("Blast Miner TNT")
local TNT_MEGA_SUBTYPE = Isaac.GetEntitySubTypeByName("Blast Miner TNT Mega")
local TNT_GIGA_SUBTYPE = Isaac.GetEntitySubTypeByName("Blast Miner TNT Giga")

local VELOCITY_MULTIPLIER = 0.7
local BOBBY_BOMBS_VELOCITY_MULTIPLIER = 1.4

local TNT_HP = 3

local EFFECT_VARIANT = Isaac.GetEntityVariantByName("Wood Particle")
local EFFECT_SUBTYPE = Isaac.GetEntitySubTypeByName("Wood Particle")
local EFFECT_GOLD_SUBTYPE = Isaac.GetEntitySubTypeByName("Wood Gold Particle")

local subtypeWhitelist = {
    [TNT_SUBTYPE] = true,
    [TNT_MEGA_SUBTYPE] = true,
    [TNT_GIGA_SUBTYPE] = true
}

local AMOUNT = 20
local START_OFFSET = 10
local WEIGHT = 0.8
local BOUNCINESS = 0.3
local FRICTION = 0.25
local MIN_SPEED = 17
local MAX_SPEED = 25
local MIN_SPEED_UPWARDS = 10
local MAX_SPEED_UPWARDS = 20

local gridLandExplodeBlacklist = {
    [GridEntityType.GRID_DECORATION] = true,
    [GridEntityType.GRID_GRAVITY] = true,
    [GridEntityType.GRID_PRESSURE_PLATE] = true,
    [GridEntityType.GRID_SPIDERWEB] = true,
    [GridEntityType.GRID_SPIKES] = true,
    [GridEntityType.GRID_SPIKES_ONOFF] = true,
    [GridEntityType.GRID_TRAPDOOR] = true,
    [GridEntityType.GRID_TELEPORTER] = true
}

---@param tnt EntityPickup
---@param flags TearFlags
local EXPLODE = function(tnt, flags)
    local newFlags = BitSet128(flags["L"], flags["H"])
    local bomb = g:Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_NORMAL, tnt.Position, Vector.Zero, nil, 0,
        tnt.InitSeed):ToBomb()
    if not bomb then return end

    if tnt.SubType == TNT_MEGA_SUBTYPE then
        bomb.ExplosionDamage = 185 --MR. MEGA damage
    end
    local ROOM_SAVE = Resouled.SaveManager.GetRoomFloorSave(tnt)
    bomb:AddTearFlags(newFlags)
    bomb:SetExplosionCountdown(0)
    bomb:Update()
    tnt:SetVarData(TNT_HP)
    tnt:GetSprite():Play(tostring(TNT_HP), true)
    tnt.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    tnt.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

    local data = tnt:GetData()
    local golden = data["Resouled_BlastMiner"]["Golden"]
    local subtype
    if tnt.SubType == TNT_SUBTYPE then
        if golden then
            subtype = EFFECT_GOLD_SUBTYPE
        else
            subtype = EFFECT_SUBTYPE
        end
    end

    if tnt.Velocity:LengthSquared() < 0.01 then
        for _ = 1, Resouled:GetRandomParticleCount(AMOUNT, AMOUNT) do
            Resouled:SpawnPrettyParticles(EFFECT_VARIANT, EFFECT_SUBTYPE, math.random(MIN_SPEED, MAX_SPEED),
                math.random(MIN_SPEED_UPWARDS, MAX_SPEED_UPWARDS), -25, 90, tnt.Position, START_OFFSET, nil, nil, WEIGHT,
                BOUNCINESS, FRICTION, GridCollisionClass.COLLISION_SOLID)
        end
    else
        for _ = 1, Resouled:GetRandomParticleCount(AMOUNT, AMOUNT) do
            Resouled:SpawnPrettyParticles(EFFECT_VARIANT, EFFECT_SUBTYPE,
                math.random(MIN_SPEED, MAX_SPEED) + tnt.Velocity:Length(),
                math.random(MIN_SPEED_UPWARDS, MAX_SPEED_UPWARDS), -25, 90, tnt.Position, START_OFFSET,
                tnt.Velocity:GetAngleDegrees(), 45 - math.floor(tnt.Velocity:Length() / 2), WEIGHT, BOUNCINESS, FRICTION,
                GridCollisionClass.COLLISION_SOLID)
        end
    end
end

---@param tnt EntityPickup
function Resouled:ExplodeBlastMinerTNTCrate(tnt)
    tnt:GetData().Explode = true
end

---@param pickup EntityPickup
local function postPickupInit(_, pickup)
    if subtypeWhitelist[pickup.SubType] then
        local sprite = pickup:GetSprite()
        local data = pickup:GetData()
        local ROOM_SAVE = Resouled.SaveManager.GetRoomFloorSave(pickup.Position)
        if ROOM_SAVE["Resouled_BlastMiner"] then
            data["Resouled_BlastMiner"] = ROOM_SAVE["Resouled_BlastMiner"]
        end
        if data["Resouled_BlastMiner"] and data["Resouled_BlastMiner"]["Golden"] then
            sprite:ReplaceSpritesheet(0, "gfx_resouled/pickups/bombs/blast_miner_crate_gold.png", true)
        end
        sprite:Play("0", true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupInit, TNT_VARIANT)

---@param pickup EntityPickup
local function onPickupUpdate(_, pickup)
    if subtypeWhitelist[pickup.SubType] then
        local sprite = pickup:GetSprite()
        local data = pickup:GetData()

        if pickup.FrameCount == 1 then
            if data["Resouled_BlastMiner"] and data["Resouled_BlastMiner"]["Golden"] then
                sprite:ReplaceSpritesheet(0, "gfx_resouled/pickups/bombs/blast_miner_crate_gold.png", true)
            end
        end

        local varData = pickup:GetVarData()

        if sprite:GetAnimation() ~= varData then
            sprite:Play(tostring(varData), true)
        end
        
        if data["Resouled_BlastMiner"] and pickup:GetVarData() < TNT_HP then
            local throwConfig = data.Resouled_TNTCrateThrown
            if not throwConfig then
                
                local flags = data["Resouled_BlastMiner"]["Flags"]
                
                if pickup.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_ALL then
                    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                end
                if pickup.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_GROUND then
                    pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                end
                
                if data.Explode then
                    EXPLODE(pickup, flags or TearFlags.TEAR_NORMAL)
                    return
                end
                
                local bobbyBombPresent = data["Resouled_BlastMiner"]["BobbyBomb"]
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
                        pickup.Velocity = (pickup.Velocity + (nearestEnemy.Position - pickup.Position):Normalized()) *
                        BOBBY_BOMBS_VELOCITY_MULTIPLIER
                    else
                        EXPLODE(pickup, flags or TearFlags.TEAR_NORMAL)
                        nearestEnemy = nil
                        return
                    end
                end
                
                varData = pickup:GetVarData()
                
                if sprite:GetAnimation() ~= varData then
                    sprite:Play(tostring(varData), true)
                end
                
                if varData >= TNT_HP then
                    EXPLODE(pickup, flags or TearFlags.TEAR_NORMAL)
                    return
                end
                
                pickup.Velocity = pickup.Velocity * VELOCITY_MULTIPLIER
            else
                local room = g:GetRoom()

                if not room:IsPositionInRoom(pickup.Position, 1) then
                    pickup.Velocity = Vector.Zero
                end

                if pickup.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE then
                    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                end

                if pickup.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_NONE then
                    pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                end

                if throwConfig.Height.Y >= 0 then
                    local newVarData = varData + 1
                    pickup:SetVarData(newVarData)
                    if newVarData == 3 then
                        EXPLODE(pickup, data["Resouled_BlastMiner"]["Flags"])
                        data.Resouled_TNTCrateThrown = nil
                        return
                    end

                    local grid = room:GetGridEntityFromPos(pickup.Position)
                    if grid and not gridLandExplodeBlacklist[grid:GetType()] then
                        EXPLODE(pickup, data["Resouled_BlastMiner"]["Flags"])
                        data.Resouled_TNTCrateThrown = nil
                        return
                    end

                    local npcs = Isaac.FindInRadius(pickup.Position, pickup.Size, EntityPartition.ENEMY)
                    if #npcs > 0 then
                        EXPLODE(pickup, data["Resouled_BlastMiner"]["Flags"])
                        data.Resouled_TNTCrateThrown = nil
                        return
                    end


                    data.Resouled_TNTCrateThrown = nil
                end

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
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_UPDATE, onPickupUpdate, TNT_VARIANT)

---@param pickup EntityPickup
---@param offset Vector
local function onPickupRender(_, pickup, offset)
    if g:IsPaused() then return end
    if not subtypeWhitelist[pickup.SubType] then return end

    
    local data = pickup:GetData()
    if not data.Resouled_TNTCrateThrown then return end

    data.Resouled_TNTCrateThrown.Height.Y = math.min(0, data.Resouled_TNTCrateThrown.Height.Y + data.Resouled_TNTCrateThrown.Speed)
    data.Resouled_TNTCrateThrown.Speed = data.Resouled_TNTCrateThrown.Speed + data.Resouled_TNTCrateThrown.Accel

    return offset + data.Resouled_TNTCrateThrown.Height - g:GetRoom():GetRenderScrollOffset()
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_RENDER, onPickupRender)

local function saveTNTData()
    ---@param pickup EntityPickup
    Resouled.Iterators:IterateOverRoomPickups(function(pickup)
        if pickup.Variant == TNT_VARIANT and subtypeWhitelist[pickup.SubType] then
            local data = pickup:GetData()
            local ROOM_SAVE = Resouled.SaveManager.GetRoomFloorSave(pickup.Position)
            ROOM_SAVE["Resouled_BlastMiner"] = data["Resouled_BlastMiner"]
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, saveTNTData)
Resouled:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, saveTNTData)


local function getDir(angle)
    angle = (angle + 360) % 360 -- Normalize angle to [0, 360)

    if angle < 22.5 or angle >= 337.5 then
        return Vector(-1, 0)               -- From Right
    elseif angle < 67.5 then
        return Vector(-1, -1):Normalized() -- From Up-Right
    elseif angle < 112.5 then
        return Vector(0, -1)               -- From Up
    elseif angle < 157.5 then
        return Vector(1, -1):Normalized()  -- From Up-Left
    elseif angle < 202.5 then
        return Vector(1, 0)                -- From Left
    elseif angle < 247.5 then
        return Vector(1, 1):Normalized()   -- From Down-Left
    elseif angle < 292.5 then
        return Vector(0, 1)                -- From Down
    elseif angle < 337.5 then
        return Vector(-1, 1):Normalized()  -- From Down-Right
    end

    return Vector(0, 0) -- Fallback in case something goes wrong
end




local function PushTNT(_, player, collider, low)
    if not (collider.Type == 5 and collider.Variant == TNT_VARIANT and subtypeWhitelist[collider.SubType]) then return end
    if not low then return end

    local tnt = collider
    local inputDir = player:GetMovementInput()

    if inputDir:Length() < 0.1 then return end


    local angle = (player.Position - tnt.Position):GetAngleDegrees()
    angle = (angle + 360) % 360

    tnt.Velocity = getDir(angle):Resized(player.Velocity:Length()) * 2

    local overlap = (player.Position - tnt.Position):Length() - (player.Size + tnt.Size)

    player.Velocity = player.Velocity + getDir(angle):Resized(math.max(-2, math.min(2, overlap)))

    return true
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, PushTNT)
