local ENTITY = Resouled:GetEntityByName("Black Proglottid")
local ITEM = Isaac.GetItemIdByName("Black Proglottid")
local EGG = Resouled:GetEntityByName("Black Proglottid's Egg")
local STUN_TENTACLE = Resouled:GetEntityByName("Stun Tentacle (Black)")

local ON_KILL_EFFECT_VARIANT = EffectVariant.PLAYER_CREEP_BLACK
local ON_KILL_EFFECT_SUBTYPE = 0
local ON_KILL_EFFECT_DURATION = 1200 -- updates
local ON_KILL_EFFECT_RADIUS = 3

local STUN_TENTACLE_TARGET_SEEK_RADIUS = 55
local STUN_TENTACLE_EFFECT_MIN_COOLDOWN = 150
local STUN_TENTACLE_EFFECT_MAX_COOLDOWN = 250

local SPRITESHEET_LAYER = 0
local SPRITESHEET_PATH = "gfx/familiar/black_proglottid.png"

local MIN_POST_ROOM_ENTER_SHOOT_DELAY = 75 -- updates
local MAX_POST_ROOM_ENTER_SHOOT_DELAY = 200

local ANIMATION_IDLE = "Idle"
local ANIMATION_SHOOT = "Shoot"

local ANIMATION_EVENT_SHOOT = "ResouledShoot"

local e = Resouled.EID

if EID then
    EID:addCollectible(ITEM,
        e:AutoIcons("Familiar that shoots an egg once per room#Enemy hit by this egg will spawn a moderately large black creep pool on death#Enemies standing in this creep get slowed and occasionally immobilized # Creep lasts " ..
        math.floor(ON_KILL_EFFECT_DURATION / 30) .. " seconds"),
        "Black Proglottid")
end

---@param familiar EntityFamiliar
local function setRandomCooldown(familiar)
    familiar:GetData().RESOULED__BLACK_PROGLOTTID_SHOOT_COOLDOWN =
        math.random(MIN_POST_ROOM_ENTER_SHOOT_DELAY, MAX_POST_ROOM_ENTER_SHOOT_DELAY)
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    if cacheFlag & CacheFlag.CACHE_FAMILIARS ~= 0 then
        Resouled.Familiar:CheckFamiliar(player, ITEM, ENTITY.Variant, ENTITY.SubType)
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function onFamiliarInit(_, familiar)
    if familiar.SubType == ENTITY.SubType then
        familiar:GetSprite():ReplaceSpritesheet(SPRITESHEET_LAYER, SPRITESHEET_PATH, true)
        setRandomCooldown(familiar)
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onFamiliarInit, ENTITY.Variant)

---@param familiar EntityFamiliar
local function onFamiliarUpdate(_, familiar)
    if familiar.SubType == ENTITY.SubType then
        local data = familiar:GetData()
        local sprite = familiar:GetSprite()

        -- COUNT DOWN TO SHOOT
        if data.RESOULED__BLACK_PROGLOTTID_SHOOT_COOLDOWN then
            if data.RESOULED__BLACK_PROGLOTTID_SHOOT_COOLDOWN > 0 then
                data.RESOULED__BLACK_PROGLOTTID_SHOOT_COOLDOWN = data
                    .RESOULED__BLACK_PROGLOTTID_SHOOT_COOLDOWN - 1
            elseif Isaac.CountEnemies() > 0 then -- PLAY SHOOTING ANIMATION ONLY IF ENEMIES ARE PRESENT
                sprite:Play(ANIMATION_SHOOT, true)
                data.RESOULED__BLACK_PROGLOTTID_SHOOT_COOLDOWN = nil
            end
        end

        -- GO BACK TO IDLE AFTER SHOOTING
        if sprite:IsFinished(ANIMATION_SHOOT) then
            sprite:Play(ANIMATION_IDLE, true)
        end

        -- SHOOT WHEN EVENT
        if sprite:IsEventTriggered(ANIMATION_EVENT_SHOOT) then
            local target = Resouled.Familiar.Targeting:SelectNearestEnemyTarget(familiar)
            if target then
                local velocity = (target.Position - familiar.Position):Normalized()
                -- just spawning the tear sometimes made its velocity funky so i just shoot a normal tear to copy its stats
                local shotTear = familiar:FireProjectile(velocity)
                local eggTear = Game():Spawn(EGG.Type, EGG.Variant, shotTear.Position, shotTear.Velocity, familiar,
                    EGG.SubType, Resouled:NewSeed())
                shotTear:Remove() -- Remove the original tear
            end
        end


        familiar:AddToFollowers()
        familiar:FollowParent()
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onFamiliarUpdate, ENTITY.Variant)

local function onRoomEnter()
    Resouled.Iterators:IterateOverRoomFamiliars(function(familiar)
        if familiar.Variant == ENTITY.Variant and familiar.SubType == ENTITY.SubType then
            setRandomCooldown(familiar)
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onRoomEnter)

---@param tear EntityTear
---@param collider Entity
---@param low boolean
local function onTearCollision(_, tear, collider, low)
    if tear.Variant == EGG.Variant and tear.SubType == EGG.SubType and collider:ToNPC() then
        collider:GetData().RESOULED__TAGGED_BY_BLACK_PROGLOTTID = true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, onTearCollision)

local function onEntityKill(_, entity)
    local data = entity:GetData()
    if data.RESOULED__TAGGED_BY_BLACK_PROGLOTTID then
        local effect = Game():Spawn(EntityType.ENTITY_EFFECT, ON_KILL_EFFECT_VARIANT, entity.Position, Vector.Zero,
            entity, ON_KILL_EFFECT_SUBTYPE, Resouled:NewSeed()):ToEffect()
        if effect then
            effect:SetTimeout(ON_KILL_EFFECT_DURATION)
            effect.SpriteScale = Vector(1, 1) * ON_KILL_EFFECT_RADIUS
            effect:Update()
            effect:GetData().RESOULED__BLACK_PROGLOTTID_CREEP = true
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, onEntityKill)

---@param effect EntityEffect
local function setRandomStunCooldown(effect)
    effect:GetData().RESOULED__BLACK_PROGLOTTID_STUN_COOLDOWN = math.random(STUN_TENTACLE_EFFECT_MIN_COOLDOWN,
        STUN_TENTACLE_EFFECT_MAX_COOLDOWN)
end

---@param effect EntityEffect
local function onEffectUpdate(_, effect)
    local data = effect:GetData()
    if data.RESOULED__BLACK_PROGLOTTID_CREEP then
        if not data.RESOULED__BLACK_PROGLOTTID_STUN_COOLDOWN then
            setRandomStunCooldown(effect)
        end

        if data.RESOULED__BLACK_PROGLOTTID_STUN_COOLDOWN > 0 then
            data.RESOULED__BLACK_PROGLOTTID_STUN_COOLDOWN = data.RESOULED__BLACK_PROGLOTTID_STUN_COOLDOWN - 1
        else
            local targets = Isaac.FindInRadius(effect.Position, STUN_TENTACLE_TARGET_SEEK_RADIUS, EntityPartition.ENEMY)

            local validTargets = {}

            for _, target in ipairs(targets) do
                if not target:IsFlying() then
                    table.insert(validTargets, target)
                end
            end

            if #validTargets > 0 then
                local target = validTargets[math.random(#validTargets)]
                Game():Spawn(STUN_TENTACLE.Type, STUN_TENTACLE.Variant, target.Position, Vector.Zero, effect,
                    STUN_TENTACLE.SubType, Resouled:NewSeed())
                setRandomStunCooldown(effect)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, onEffectUpdate, ON_KILL_EFFECT_VARIANT)
