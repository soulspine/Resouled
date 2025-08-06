local SIBLING_RIVALRY = Isaac.GetItemIdByName("Sibling Rivalry")

local e = Resouled.EID

if EID then
    EID:addCollectible(SIBLING_RIVALRY, e:AutoIcons("On use, player starts to accelerate. If the player hits anything, they start to spin ").."dealing"..e:AutoIcons(" contact damage, while being invulnerable."))
end

local GRID_BOUCE_VELOCITY_LOSS_MULTIPLIER = 0.1
local ENEMY_BOUNCE_VELOCITY_GAIN_MULTIPLIER = 0.2
local SPIN_START_VELOCITY_MULTIPLIER = 10
local VELOCITY_LOSS_PER_TICK_MULTIPLIER = 0.01

local CAR_BATTERY_GRID_BOUNCE_VELOCITY_LOSS_MULTIPLIER = 0.05
local CAR_BATTERY_ENEMY_BOUNCE_VELOCITY_GAIN_MULTIPLIER = 0.25
local CAR_BATTERY_SPIN_START_VELOCITY_MULTIPLIER = 2
local CAR_BATTERY_VELOCITY_LOSS_PER_TICK = 0.005

local CURSE_OF_IMPULSE_VELOCITY_MULTIPLIER = 1.125

---@param type CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
---@param data integer
local function onActiveUse(_, type, rng, player, flags, slot, data)
    local data = player:GetData()
    player:AnimateCollectible(SIBLING_RIVALRY, "UseItem")
    data.ResouledSiblingRivalry = true

    local nearestEnemy = nil
    ---@param entity Entity
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local npc = entity:ToNPC()
        if npc then
            if npc:IsActiveEnemy() and npc:IsEnemy() and npc:IsVulnerableEnemy() then
                if not nearestEnemy then
                    nearestEnemy = npc.Position
                elseif nearestEnemy and npc.Position:Distance(player.Position) < nearestEnemy:Distance(player.Position) then
                    nearestEnemy = npc.Position
                end
            end
        end
    end)
    
    if nearestEnemy then
        player.Velocity = (nearestEnemy - player.Position):Normalized() * SPIN_START_VELOCITY_MULTIPLIER
        data.ResouledSiblingRivalry = true
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
    Resouled.Iterators:IterateOverPlayers(function(player)
        local data = player:GetData()

        if data.ResouledSiblingRivalrySpin then
            if not data.ResouledTornado then
                data.ResouledTornado = Game():Spawn(Isaac.GetEntityTypeByName("Tornado"), Isaac.GetEntityVariantByName("Tornado"), player.Position, Vector.Zero, nil, 0, player.InitSeed)
            end
            player:SetShootingCooldown(2)
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
                    if SFXManager():IsPlaying(SoundEffect.SOUND_ULTRA_GREED_SPINNING) then
                        SFXManager():Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
                    end
                    Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, player.Position, Vector(0, 0), player, 0, 0)
                    player.Visible = true
                    data.ResouledSiblingRivalrySpin = false
                    data.ResouledSRVelocity = nil
                    data.ResouledTornado:Remove()
                    data.ResouledTornado = nil
                end
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param player EntityPlayer
---@param gridIndex integer
---@param gridEntity GridEntity | nil
local function onPlayerGridCollision(_, player, gridIndex, gridEntity)
    local data = player:GetData()
    if not data.ResouledSiblingRivalrySpin and data.ResouledSiblingRivalry then
        data.ResouledSiblingRivalrySpin = true
        data.ResouledSiblingRivalry = false
        data.ResouledSRVelocity = player.Velocity * SPIN_START_VELOCITY_MULTIPLIER
        if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
            data.ResouledSRVelocity = data.ResouledSRVelocity * 2
        end
        SFXManager():Play(SoundEffect.SOUND_ULTRA_GREED_SPINNING, 1, 0, true, 1, 0)
    end

    if data.ResouledSRVelocity or data.ResouledIsSiblingAndSpin then
        if data.ResouledSRVelocity and gridEntity then
            local newVelocity = Resouled.Vector:GetBounceOffGridElementVector(player.Velocity, player.Position, gridEntity.Position)
            player.Velocity = newVelocity
        end

        
        if data.ResouledSRVelocity then
            SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE, 1, 0, false, 1, 0)
            Game():ShakeScreen(math.floor(data.ResouledSRVelocity:Length())*2)

            data.ResouledSRVelocity = data.ResouledSRVelocity:Rotated(math.random(-10, 10))

            if not player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_IMPULSE) then
                    data.ResouledSRVelocity = data.ResouledSRVelocity * (1 - GRID_BOUCE_VELOCITY_LOSS_MULTIPLIER) * CURSE_OF_IMPULSE_VELOCITY_MULTIPLIER
                else
                    data.ResouledSRVelocity = data.ResouledSRVelocity * (1 - GRID_BOUCE_VELOCITY_LOSS_MULTIPLIER)
                end
            else
                if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_IMPULSE) then
                    data.ResouledSRVelocity = data.ResouledSRVelocity * (1 - CAR_BATTERY_GRID_BOUNCE_VELOCITY_LOSS_MULTIPLIER) * CURSE_OF_IMPULSE_VELOCITY_MULTIPLIER
                else
                    data.ResouledSRVelocity = data.ResouledSRVelocity * (1 - CAR_BATTERY_GRID_BOUNCE_VELOCITY_LOSS_MULTIPLIER)
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, onPlayerGridCollision)

---@param npc EntityNPC
---@param collider Entity
local function onNpcCollision(_, npc, collider)
    local player = collider:ToPlayer()
    if player then
        local data = collider:GetData()
        if data.ResouledSiblingRivalry then
            data.ResouledSRVelocity = collider.Velocity * SPIN_START_VELOCITY_MULTIPLIER
            if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                data.ResouledSRVelocity = data.ResouledSRVelocity * CAR_BATTERY_SPIN_START_VELOCITY_MULTIPLIER
            end
            data.ResouledSiblingRivalry = false
            data.ResouledSiblingRivalrySpin = true
            SFXManager():Play(SoundEffect.SOUND_ULTRA_GREED_SPINNING, 1, 0, true, 1, 0)
        end
        if data.ResouledSRVelocity or data.ResouledIsSiblingAndSpin then
            if data.ResouledSRVelocity then
                local newVelocity = Resouled.Vector:GetBounceOffGridElementVector(player.Velocity, npc.Position, player.Position)
                player.Velocity = newVelocity
            end
            if data.ResouledSRVelocity then
                SFXManager():Play(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 1, 0)
                Game():ShakeScreen(math.floor(data.ResouledSRVelocity:Length())*2)
                
                data.ResouledSRVelocity = data.ResouledSRVelocity:Rotated(math.random(-10, 10))
                
                if not player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
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
    if SFXManager():IsPlaying(SoundEffect.SOUND_ULTRA_GREED_SPINNING) then
        SFXManager():Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
    end
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        local data = player:GetData()
        data.ResouledSiblingRivalry = false
        data.ResouledSiblingRivalrySpin = false
        data.ResouledSRVelocity = nil
        if data.ResouledTornado then
            data.ResouledTornado:Remove()
            data.ResouledTornado = nil
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, onNewRoom)