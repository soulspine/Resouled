local Soul = {
    Variant = Isaac.GetEntityVariantByName("Soul"),
    SubType = Isaac.GetEntitySubTypeByName("Soul"),
    StartVelocity = Vector(10, 0),
    TrailColor = Color(1, 1, 1, 0.75),
    TrailLength = 0.025, --The lower the number the longer
    SpriteOffset = Vector(0, -10)
}

---@param pickup EntityPickup
local function onPickupInit(_, pickup)
    if pickup.SubType == Soul.SubType then
        local sprite = pickup:GetSprite()
        sprite:Play("Appear", true)
        sprite.Offset = Soul.SpriteOffset

        local entityParent = pickup
        local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, entityParent.Position, Vector.Zero, entityParent):ToEffect()
        trail:FollowParent(entityParent)
        trail.Color = Soul.TrailColor
        trail.MinRadius = Soul.TrailLength
        trail.SpriteScale = Vector.One

        trail.ParentOffset = Soul.SpriteOffset * 1.5

        pickup:GetData().Resouled_SoulTrail = EntityRef(trail)

        pickup.Velocity = Soul.StartVelocity:Rotated(math.random(360))

        pickup:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit, Soul.Variant)

---@param pickup EntityPickup
local function onPickupUpdate(_, pickup)
    if pickup.SubType == Soul.SubType then
        if pickup.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_PLAYERONLY then
            pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        end
        local sprite = pickup:GetSprite()

        if sprite:IsFinished("Appear") then
            sprite:Play("Idle", true)
        end

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
            local distance = pickup.Position:Distance(nearestPlayer.Position)/50
            if distance > 1 then
                distance = 1
            end
            if distance < 0.9 then
                distance = 0.9
            end
            pickup.Velocity = (pickup.Velocity + (nearestPlayer.Position - pickup.Position):Normalized()) * distance
        end

        sprite.Rotation = pickup.Velocity:GetAngleDegrees()

        local data = pickup:GetData()

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
            local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, entityParent.Position, Vector.Zero, entityParent):ToEffect()
            trail:FollowParent(entityParent)
            trail.Color = Soul.TrailColor
            trail.MinRadius = Soul.TrailLength
            trail.SpriteScale = Vector.One

            trail.ParentOffset = Soul.SpriteOffset * 1.5

            pickup:GetData().Resouled_SoulTrail = EntityRef(trail)
        end

        if pickup.FrameCount % 2 == 0 then
            Resouled:SpawnSparkleEffect(pickup.Position, -pickup.Velocity/5, 180, pickup.SpriteOffset)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate, Soul.Variant)