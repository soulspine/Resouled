---@diagnostic disable: need-check-nil
local Soul = Resouled.Stats.Soul

local DeathStatue = Resouled.Stats.DeathStatue

---@param pickup EntityPickup
local function onPickupInit(_, pickup)
    if pickup.SubType == Soul.SubType or pickup.SubType == Soul.SubTypeStatue then
        local sprite = pickup:GetSprite()
        sprite:Play("Appear", true)
        sprite.Offset = Soul.SpriteOffset

        local entityParent = pickup
        local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, entityParent.Position,
            Vector.Zero, entityParent):ToEffect()
        trail:FollowParent(entityParent)
        trail.Color = Soul.TrailColor
        trail.MinRadius = Soul.TrailLength
        trail.SpriteScale = Vector.One
        trail.DepthOffset = 100
        trail.RenderZOffset = 100
        trail.ParentOffset = Soul.SpriteOffset * 1.5

        local data = pickup:GetData()

        data.Resouled_SoulTrail = EntityRef(trail)

        pickup.Velocity = Soul.StartVelocity:Rotated(math.random(360))

        if pickup.SubType ~= Soul.SubTypeStatue then
            pickup:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
        else
            local statue = nil

            ---@param effect EntityEffect
            Resouled.Iterators:IterateOverRoomEffects(function(effect)
                if effect.Variant == DeathStatue.Variant and effect.SubType == DeathStatue.SubType then
                    statue = effect
                end
            end)

            if not statue then
                pickup:Remove()
            else
                data.Resouled_SoulStatueTarget = statue
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit, Soul.Variant)

---@param pickup EntityPickup
local function onPickupUpdate(_, pickup)
    if pickup.SubType == Soul.SubType or pickup.SubType == Soul.SubTypeStatue then
        if pickup.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_PLAYERONLY then
            pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        end
        local sprite = pickup:GetSprite()

        if sprite:IsFinished("Appear") then
            sprite:Play("Idle", true)
        end

        if pickup.SubType == Soul.SubType then
            ---@type EntityPlayer | nil
            local nearestPlayer = nil

            ---@param player EntityPlayer
            Resouled.Iterators:IterateOverPlayers(function(player)
                if not nearestPlayer then
                    nearestPlayer = player
                else
                    if nearestPlayer.Position:Distance(pickup.Position) > player.Position:Distance(pickup.Position) then
                        nearestPlayer = player
                    end
                end
            end)

            if nearestPlayer then
                local distance = pickup.Position:Distance(nearestPlayer.Position) / 50
                if distance > 1 then
                    distance = 1
                end
                if distance < 0.9 then
                    distance = 0.9
                end
                pickup.Velocity = (pickup.Velocity + (nearestPlayer.Position - pickup.Position):Normalized()) * distance
            end
        end

        sprite.Rotation = pickup.Velocity:GetAngleDegrees()

        local data = pickup:GetData()

        if pickup.SubType == Soul.SubTypeStatue then
            if data.Resouled_SoulStatueTarget then
                ---@type EntityEffect
                local statue = data.Resouled_SoulStatueTarget
                local distance = pickup.Position:Distance(statue.Position) / 50
                if distance > 1 then
                    distance = 1
                end
                if distance < 0.9 then
                    distance = 0.9
                end
                pickup.Velocity = (pickup.Velocity + (statue.Position - pickup.Position):Normalized()) * distance

                if pickup.Position:Distance(statue.Position) - (pickup.Size + DeathStatue.Size) <= 0 then
                    local save = Resouled.StatTracker:GetSaveField(Resouled.StatTracker.Fields.SoulsCollected)
                    if not save then save = 0 end
                    save = save + 1
                    
                    pickup:Remove()
                    Soul:PlayPickupSound()
                    statue:GetSprite():PlayOverlay("Flash", true)
                end
            else
                pickup:Remove()
            end
        end

        if data.Resouled_SoulTrail then
            ---@type EntityEffect | nil
            local trail = data.Resouled_SoulTrail.Entity
            if trail then
                trail:Update()
            end

            if not trail:Exists() then
                data.Resouled_SoulTrail = nil
            end
        else
            local entityParent = pickup
            local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, entityParent.Position,
                Vector.Zero, entityParent):ToEffect()
            trail:FollowParent(entityParent)
            trail.Color = Soul.TrailColor
            trail.MinRadius = Soul.TrailLength
            trail.SpriteScale = Vector.One
            trail.DepthOffset = 100
            trail.RenderZOffset = 100
            trail.ParentOffset = Soul.SpriteOffset * 1.5

            pickup:GetData().Resouled_SoulTrail = EntityRef(trail)
        end

        if pickup.FrameCount % 2 == 0 then
            Resouled:SpawnSparkleEffect(pickup.Position, -pickup.Velocity / 5, 180, pickup.SpriteOffset)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate, Soul.Variant)

local function preRoomExit()
    ---@param pickup EntityPickup
    Resouled.Iterators:IterateOverRoomPickups(function(pickup)
        if pickup.Variant == Soul.Variant and pickup.SubType == Soul.SubTypeStatue then
            pickup:Remove()
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, preRoomExit)
