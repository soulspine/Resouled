local SIBLING_RIVALRY = Isaac.GetItemIdByName("Sibling Rivalry")

local EID_DESCRIPTION = "On use, player starts to accelerate. If the player hits anything, they start to spin dealing contact damage, while being invulnerable."

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
        player.Velocity = -(player.Position - player:GetOtherTwin().Position):Normalized() * (player.Position:Distance(player:GetOtherTwin().Position) / 13)
        player:GetOtherTwin().Velocity = -(player:GetOtherTwin().Position - player.Position):Normalized() * (player:GetOtherTwin().Position:Distance(player.Position) / 13)
        player:AnimateCollectible(SIBLING_RIVALRY, "UseItem")
        player:GetOtherTwin():AnimateCollectible(SIBLING_RIVALRY, "UseItem")
        data.ResouledSiblingRivalry = true
        player:GetOtherTwin():GetData().SiblingRivalry = true
    end
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, SIBLING_RIVALRY)

---@param player EntityPlayer
---@param source EntityRef
local function prePlayerTakeDmg(_, player, source)
    local data = player:GetData()
    if data.ResouledSiblingRivalrySpin then
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
                    data.ResouledSRVelocity = player.Velocity * 3
                    player:GetOtherTwin():GetData().SRVelocity = data.ResouledSRVelocity
                end
            end
        else
        end

        if data.ResouledSiblingRivalrySpin then
            if not data.ResouledTornado then
                print("Spawned")
                data.ResouledTornado = Game():Spawn(Isaac.GetEntityTypeByName("Tornado"), Isaac.GetEntityVariantByName("Tornado"), player.Position, Vector.Zero, nil, 0, player.InitSeed)
            end
            player:SetShootingCooldown(2)
            if player:GetOtherTwin() then
                if data.ResouledSRVelocity then
                    player:GetOtherTwin().Velocity = player:GetOtherTwin():GetData().SRVelocity
                end
                player:GetOtherTwin().EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
                player:GetOtherTwin().Position = player.Position
            end
            if data.ResouledSRVelocity then
                local smoke = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, player.Position, Vector.Zero, nil, 0, 0)
                smoke.Color = Color(2,2,2,0.7)
                smoke.SpriteScale = Vector(1.5 + data.ResouledSRVelocity:Length()/10, 1.5 + data.ResouledSRVelocity:Length()/10)
                player.Visible = false
                player.Velocity = data.ResouledSRVelocity
                if not player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                    data.ResouledSRVelocity = data.ResouledSRVelocity * 0.99
                else
                    data.ResouledSRVelocity = data.ResouledSRVelocity * 0.995
                end
                data.ResouledTornado.Position = player.Position
                data.ResouledTornado.SpriteScale = Vector(0.75 + data.ResouledSRVelocity:Length()/15, 0.75 + data.ResouledSRVelocity:Length()/15)
                if data.ResouledSRVelocity:Length() < 3 then
                    Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, player.Position, Vector(0, 0), player, 0, 0)
                    player.Visible = true
                    data.ResouledSiblingRivalrySpin = false
                    data.ResouledTornado:Remove()
                    data.ResouledTornado = nil
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
        data.ResouledSRVelocity = player.Velocity * 3
        if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
            data.ResouledSRVelocity = data.ResouledSRVelocity * 2
        end
    end

    local dirHelper = Game():GetRoom():GetGridPosition(gridIndex) - player.Position
    if data.ResouledSiblingRivalrySpin then
        if dirHelper.X > 0 and dirHelper.Y >= -20 and dirHelper.Y <= 20 then
            data.ResouledSRVelocity.X = -data.ResouledSRVelocity.X
        elseif dirHelper.X < 0 and dirHelper.Y >= -20 and dirHelper.Y <= 20 then
            data.ResouledSRVelocity.X = -data.ResouledSRVelocity.X
        elseif dirHelper.Y > 0 and dirHelper.X >= -20 and dirHelper.X <= 20 then
            data.ResouledSRVelocity.Y = -data.ResouledSRVelocity.Y
        elseif dirHelper.Y < 0 and dirHelper.X >= -20 and dirHelper.X <= 20 then
            data.ResouledSRVelocity.Y = -data.ResouledSRVelocity.Y
        end
        Game():ShakeScreen(math.floor(data.ResouledSRVelocity:Length())*2)

        data.ResouledSRVelocity = data.ResouledSRVelocity:Rotated(math.random(-10, 10))
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
            data.ResouledSRVelocity = data.ResouledSRVelocity * 0.9
        else
            data.ResouledSRVelocity = data.ResouledSRVelocity * 0.95
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
            data.ResouledSRVelocity = collider.Velocity * 3
            if collider:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                data.ResouledSRVelocity = data.ResouledSRVelocity * 2
            end
            data.ResouledSiblingRivalry = false
            data.ResouledSiblingRivalrySpin = true
        end
        if data.ResouledSiblingRivalrySpin then
            local dirHelper = npc.Position - collider.Position
            if dirHelper.X > 0 then
                data.ResouledSRVelocity.X = -data.ResouledSRVelocity.X
            elseif dirHelper.X < 0 then
                data.ResouledSRVelocity.X = -data.ResouledSRVelocity.X
            elseif dirHelper.Y > 0 then
                data.ResouledSRVelocity.Y = -data.ResouledSRVelocity.Y
            elseif dirHelper.Y < 0 then
                data.ResouledSRVelocity.Y = -data.ResouledSRVelocity.Y
            end
            Game():ShakeScreen(math.floor(data.ResouledSRVelocity:Length())*2)

            data.ResouledSRVelocity = data.ResouledSRVelocity:Rotated(math.random(-10, 10))

            if not collider:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                data.ResouledSRVelocity = data.ResouledSRVelocity * 1.2
            else
                data.ResouledSRVelocity = data.ResouledSRVelocity * 1.25
            end

            if npc:IsEnemy() then
                npc:TakeDamage(6 * data.ResouledSRVelocity:Length()/7, 0, EntityRef(npc), 1)
            end

            local impact = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, collider.Position, Vector(0, 0), collider, 0, 0)
            impact.SpriteScale = Vector(math.floor(data.ResouledSRVelocity:Length())/5, math.floor(data.ResouledSRVelocity:Length())/5)
            if data.ResouledSRVelocity:Length() > 10 then
                Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, collider.Position, Vector(0, 0), collider, 0, 0)
                Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, collider.Position, Vector(0, 0), collider, 0, 0)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, onNpcCollision)

local function onNewRoom()
    Resouled:IterateOverPlayers(function(player)
        local data = player:GetData()
        data.ResouledSiblingRivalry = false
        data.ResouledSiblingRivalrySpin = false
        if data.ResouledTornado then 
            data.ResouledTornado:Remove()
            data.ResouledTornado = nil
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, onNewRoom)

---@param pickup EntityPickup
local function onPickupInit(_, pickup)
    if pickup.SubType == SIBLING_RIVALRY then
        if not Resouled:IsQuestionMarkItem(pickup) then
            local data = pickup:GetData()
            data["EID_Description"] = EID_DESCRIPTION
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit, PickupVariant.PICKUP_COLLECTIBLE)