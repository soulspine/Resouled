---@diagnostic disable: need-check-nil
local Soul = Resouled.Stats.Soul

local DeathStatue = Resouled.Stats.DeathStatue

---@param pickup EntityPickup
---@param black? boolean
local function spawnTrail(pickup, black)
    local entityParent = pickup
    local player = Isaac.GetPlayer()
    local data = pickup:GetData()
    if not black then
        local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, entityParent.Position,
        Vector.Zero, entityParent):ToEffect()
        trail:FollowParent(entityParent)
        trail.Color = Soul.TrailColor
        trail.MinRadius = Soul.TrailLength
        trail.SpriteScale = Soul.TrailScale
        trail.ParentOffset = Soul.SpriteOffset * 1.5
        trail.DepthOffset = player.DepthOffset + Soul.TrailDepthOffset
        trail.RenderZOffset = player.RenderZOffset - 10
        
        data.Resouled_SoulTrail = EntityRef(trail)
    else
        local trail2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, entityParent.Position,
        Vector.Zero, entityParent):ToEffect()
        trail2:FollowParent(entityParent)
        trail2.Color = Soul.Trail2Color
        trail2.MinRadius = Soul.Trail2Length
        trail2.SpriteScale = Soul.Trail2Scale
        trail2.ParentOffset = Soul.SpriteOffset * 1.5
        trail2.DepthOffset = player.DepthOffset + Soul.TrailDepthOffset - 10
        trail2.RenderZOffset = player.RenderZOffset - 20

        local sprite = trail2:GetSprite()
        for i = 0, sprite:GetLayerCount() - 1 do
            local layer = sprite:GetLayer(i)
            if layer then
                local blend = layer:GetBlendMode()

                blend.RGBSourceFactor = BlendFactor.ONE_MINUS_SRC_COLOR
                blend.RGBDestinationFactor = BlendFactor.ONE_MINUS_SRC_COLOR
            end
        end
        
        data.Resouled_SoulTrail2 = EntityRef(trail2)
    end
end

---@param pickup EntityPickup
local function onPickupInit(_, pickup)
    if pickup.SubType == Soul.SubType or pickup.SubType == Soul.SubTypeStatue then
        local sprite = pickup:GetSprite()
        sprite:Play("Appear", true)
        sprite.Offset = Soul.SpriteOffset

        spawnTrail(pickup, false)
        spawnTrail(pickup, true)

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
                pickup:GetData().Resouled_SoulStatueTarget = statue
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

        if not sprite:IsPlaying("Appear") then
            sprite:SetFrame("Idle", ((pickup.Velocity:GetAngleDegrees() - 67.5)%360)//45)
        end

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
            spawnTrail(pickup, false)
        end

        if data.Resouled_SoulTrail2 then
            ---@type EntityEffect | nil
            local trail = data.Resouled_SoulTrail2.Entity
            if trail then
                trail:Update()
            end

            if not trail:Exists() then
                data.Resouled_SoulTrail2 = nil
            end
        else
            spawnTrail(pickup, true)
        end

        if pickup.FrameCount % 2 == 0 then
            --Resouled:SpawnSparkleEffect(pickup.Position, -pickup.Velocity / 5, 180, pickup.SpriteOffset)
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
