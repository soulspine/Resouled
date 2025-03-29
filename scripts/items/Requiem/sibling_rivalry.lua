local SIBLING_RIVALRY = Isaac.GetItemIdByName("Sibling Rivalry")

if EID then
    EID:addCollectible(SIBLING_RIVALRY, "On use, player starts to accelerate. If the player hits anything, they start to spin dealing contact damage, while being invulnerable.")
end

local GRID_BOUCE_VELOCITY_LOSS_MULTIPLIER = 0.1
local ENEMY_BOUNCE_VELOCITY_GAIN_MULTIPLIER = 0.2
local SPIN_START_VELOCITY_MULTIPLIER = 3
local VELOCITY_LOSS_PER_TICK_MULTIPLIER = 0.01

local CAR_BATTERY_GRID_BOUNCE_VELOCITY_LOSS_MULTIPLIER = 0.05
local CAR_BATTERY_ENEMY_BOUNCE_VELOCITY_GAIN_MULTIPLIER = 0.25
local CAR_BATTERY_SPIN_START_VELOCITY_MULTIPLIER = 2
local CAR_BATTERY_VELOCITY_LOSS_PER_TICK = 0.005

local TWIN_HUG_SPEED = 13

---@param type CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
---@param data integer
local function onActiveUse(_, type, rng, player, flags, slot, data)
    local data = player:GetData()
    if not player:GetOtherTwin() then
        player:AnimateCollectible(SIBLING_RIVALRY, "UseItem")
        data.ResouledSiblingRivalry = true
    else
        player:AddControlsCooldown(6)
        player:GetOtherTwin():AddControlsCooldown(6)
        player.Velocity = -(player.Position - player:GetOtherTwin().Position):Normalized() * (player.Position:Distance(player:GetOtherTwin().Position) / TWIN_HUG_SPEED)
        player:GetOtherTwin().Velocity = -(player:GetOtherTwin().Position - player.Position):Normalized() * (player:GetOtherTwin().Position:Distance(player.Position) / TWIN_HUG_SPEED)
        player:AnimateCollectible(SIBLING_RIVALRY, "UseItem")
        player:GetOtherTwin():AnimateCollectible(SIBLING_RIVALRY, "UseItem")
        data.ResouledSiblingRivalry = true
    end
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, SIBLING_RIVALRY)

---@param player EntityPlayer
---@param source EntityRef
local function prePlayerTakeDmg(_, player, source)
    local data = player:GetData()
    if data.ResouledSiblingRivalrySpin or data.ResouledIsSiblingAndSpin then
        return false
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, prePlayerTakeDmg)

local function onUpdate()
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        local data = player:GetData()
        if data.ResouledSiblingRivalry then
            if not data.ResouledSiblingRivalrySpin and player:GetOtherTwin() then
                if player.Position:Distance(player:GetOtherTwin().Position) < 55 then
                    data.ResouledSiblingRivalrySpin = true
                    player:GetOtherTwin():GetData().SiblingRivalrySpin = true
                    data.ResouledSiblingRivalry = false
                    player:GetOtherTwin():GetData().SiblingRivalry = false
                    data.ResouledSRVelocity = player.Velocity * SPIN_START_VELOCITY_MULTIPLIER
                    player:GetOtherTwin():GetData().SRVelocity = data.ResouledSRVelocity
                    player:GetOtherTwin():GetData().ResouledIsSiblingAndSpin = true
                end
            end
        else
        end

        if data.ResouledSiblingRivalrySpin then
            if not data.ResouledTornado then
                data.ResouledTornado = Game():Spawn(Isaac.GetEntityTypeByName("Tornado"), Isaac.GetEntityVariantByName("Tornado"), player.Position, Vector.Zero, nil, 0, player.InitSeed)
            end
            player:SetShootingCooldown(2)
            player:GetOtherTwin():SetShootingCooldown(2)
            if player:GetOtherTwin() then
                if data.ResouledSRVelocity then
                    player:GetOtherTwin().Position = player.Position
                    player:GetOtherTwin().Visible = false
                end
            end
            if data.ResouledSRVelocity then
                local smoke = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, player.Position, Vector.Zero, nil, 0, 0)
                smoke.Color = Color(2,2,2,0.7)
                smoke.SpriteScale = Vector(1.5 + data.ResouledSRVelocity:Length()/10, 1.5 + data.ResouledSRVelocity:Length()/10)
                player.Visible = false
                player.Velocity = data.ResouledSRVelocity
                if not player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                    data.ResouledSRVelocity = data.ResouledSRVelocity * (1 - VELOCITY_LOSS_PER_TICK_MULTIPLIER)
                else
                    data.ResouledSRVelocity = data.ResouledSRVelocity * (1 - CAR_BATTERY_VELOCITY_LOSS_PER_TICK)
                end
                data.ResouledTornado.Position = player.Position
                data.ResouledTornado.SpriteScale = Vector(0.75 + data.ResouledSRVelocity:Length()/15, 0.75 + data.ResouledSRVelocity:Length()/15)
                if data.ResouledSRVelocity:Length() < 3 then
                    Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, player.Position, Vector(0, 0), player, 0, 0)
                    player.Visible = true
                    data.ResouledSiblingRivalrySpin = false
                    data.ResouledSRVelocity = nil
                    data.ResouledTornado:Remove()
                    data.ResouledTornado = nil
                    if player:GetOtherTwin() then
                        player:GetOtherTwin():GetData().ResouledIsSiblingAndSpin = false
                        player:GetOtherTwin().Visible = true
                    end
                end
            end
        else
            if player:GetOtherTwin() then
                player:GetOtherTwin().EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param player EntityPlayer
---@param gridIndex integer
local function onPlayerGridCollision(_, player, gridIndex)
    local data = player:GetData()
    if not data.ResouledSiblingRivalrySpin and data.ResouledSiblingRivalry then
        data.ResouledSiblingRivalrySpin = true
        data.ResouledSiblingRivalry = false
        data.ResouledSRVelocity = player.Velocity * SPIN_START_VELOCITY_MULTIPLIER
        if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
            data.ResouledSRVelocity = data.ResouledSRVelocity * 2
        end
    end

    local dirHelper = Game():GetRoom():GetGridPosition(gridIndex) - player.Position
    if data.ResouledSRVelocity or data.ResouledIsSiblingAndSpin then
        if data.ResouledSRVelocity then
            if dirHelper.X > 0 and dirHelper.Y >= -20 and dirHelper.Y <= 20 then
                data.ResouledSRVelocity.X = -data.ResouledSRVelocity.X
            elseif dirHelper.X < 0 and dirHelper.Y >= -20 and dirHelper.Y <= 20 then
                data.ResouledSRVelocity.X = -data.ResouledSRVelocity.X
            elseif dirHelper.Y > 0 and dirHelper.X >= -20 and dirHelper.X <= 20 then
                data.ResouledSRVelocity.Y = -data.ResouledSRVelocity.Y
            elseif dirHelper.Y < 0 and dirHelper.X >= -20 and dirHelper.X <= 20 then
                data.ResouledSRVelocity.Y = -data.ResouledSRVelocity.Y
            end
        end

        
        if data.ResouledSRVelocity then 
            Game():ShakeScreen(math.floor(data.ResouledSRVelocity:Length())*2)

            data.ResouledSRVelocity = data.ResouledSRVelocity:Rotated(math.random(-10, 10))

            if not player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                data.ResouledSRVelocity = data.ResouledSRVelocity * (1 - GRID_BOUCE_VELOCITY_LOSS_MULTIPLIER)
            else
                data.ResouledSRVelocity = data.ResouledSRVelocity * (1 - CAR_BATTERY_GRID_BOUNCE_VELOCITY_LOSS_MULTIPLIER)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, onPlayerGridCollision)

---@param npc EntityNPC
---@param collider Entity
local function onNpcCollision(_, npc, collider)
    if collider.Type == EntityType.ENTITY_PLAYER then
        local data = collider:GetData()
        if data.ResouledSiblingRivalry then
            data.ResouledSRVelocity = collider.Velocity * SPIN_START_VELOCITY_MULTIPLIER
            if collider:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                data.ResouledSRVelocity = data.ResouledSRVelocity * CAR_BATTERY_SPIN_START_VELOCITY_MULTIPLIER
            end
            data.ResouledSiblingRivalry = false
            data.ResouledSiblingRivalrySpin = true
        end
        if data.ResouledSRVelocity or data.ResouledIsSiblingAndSpin then
            local dirHelper = npc.Position - collider.Position
            if data.ResouledSRVelocity then
                if dirHelper.X > 0 then
                    data.ResouledSRVelocity.X = -data.ResouledSRVelocity.X
                elseif dirHelper.X < 0 then
                    data.ResouledSRVelocity.X = -data.ResouledSRVelocity.X
                elseif dirHelper.Y > 0 then
                    data.ResouledSRVelocity.Y = -data.ResouledSRVelocity.Y
                elseif dirHelper.Y < 0 then
                    data.ResouledSRVelocity.Y = -data.ResouledSRVelocity.Y
                end
            end
            if data.ResouledSRVelocity then 
                Game():ShakeScreen(math.floor(data.ResouledSRVelocity:Length())*2)

                data.ResouledSRVelocity = data.ResouledSRVelocity:Rotated(math.random(-10, 10))

                if not collider:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                    data.ResouledSRVelocity = data.ResouledSRVelocity * (1 + ENEMY_BOUNCE_VELOCITY_GAIN_MULTIPLIER)
                else
                    data.ResouledSRVelocity = data.ResouledSRVelocity * (1 + CAR_BATTERY_ENEMY_BOUNCE_VELOCITY_GAIN_MULTIPLIER)
                end

                if npc:IsEnemy() then
                    npc:TakeDamage(6 * data.ResouledSRVelocity:Length()/7, 0, EntityRef(npc), 1)
                end
            end

            local impact = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, collider.Position, Vector(0, 0), collider, 0, 0)
            if data.ResouledSRVelocity then 
                impact.SpriteScale = Vector(math.floor(data.ResouledSRVelocity:Length())/5, math.floor(data.ResouledSRVelocity:Length())/5)
                
                if data.ResouledSRVelocity:Length() > 10 then
                    Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, collider.Position, Vector(0, 0), collider, 0, 0)
                    Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, collider.Position, Vector(0, 0), collider, 0, 0)
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, onNpcCollision)

local function onNewRoom()
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        local data = player:GetData()
        data.ResouledSiblingRivalry = false
        data.ResouledSiblingRivalrySpin = false
        if data.ResouledTornado then 
            data.ResouledTornado:Remove()
            data.ResouledTornado = nil
        end
        if player:GetOtherTwin() then
            player:GetOtherTwin():GetData().ResouledIsSiblingAndSpin = false
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, onNewRoom)