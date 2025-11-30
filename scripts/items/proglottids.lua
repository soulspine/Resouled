local ENTITIES = {
    BLACK = Resouled:GetEntityByName("Black Proglottid"),
    STUN_TENTACLE = Resouled:GetEntityByName("Stun Tentacle (Black)"),
    WHITE = Resouled:GetEntityByName("White Proglottid"),
    RED = Resouled:GetEntityByName("Red Proglottid"),
    PINK = Resouled:GetEntityByName("Pink Proglottid"),
}

-- ALL PROGLOTTIDS CONFIG
local MIN_POST_ROOM_ENTER_SHOOT_DELAY = 75 -- updates
local MAX_POST_ROOM_ENTER_SHOOT_DELAY = 200

--BLACK CONFIG
local BLACK_ON_KILL_EFFECT_VARIANT = EffectVariant.PLAYER_CREEP_BLACK
local BLACK_ON_KILL_EFFECT_SUBTYPE = 0
local BLACK_ON_KILL_EFFECT_DURATION = 1200 -- updates
local BLACK_ON_KILL_EFFECT_RADIUS = 3

local STUN_TENTACLE_TARGET_SEEK_RADIUS = 55
local STUN_TENTACLE_EFFECT_MIN_COOLDOWN = 150
local STUN_TENTACLE_EFFECT_MAX_COOLDOWN = 250

-- WHITE CONFIG
local WHITE_ON_KILL_EFFECT_EXPLOSION_SFX = SoundEffect.SOUND_EXPLOSION_WEAK
local WHITE_ON_KILL_EFFECT_EXPLOSION_SFX_VOLUME = 0.6
local WHITE_ON_KILL_EFFECT_EXPLOSION_VARIANT = EffectVariant.ENEMY_GHOST
local WHITE_ON_KILL_EFFECT_EXPLOSION_SUBTYPE = 1
local WHITE_ON_KILL_EFFECT_EXPLOSION_DAMAGE = 50
local WHITE_ON_KILL_EFFECT_EXPLOSION_RADIUS = 65
local WHITE_ON_KILL_EFFECT_EXPLOSION_DAMAGE_FLAGS = DamageFlag.DAMAGE_EXPLOSION
local WHITE_ON_KILL_EFFECT_EXPLOSION_DAMAGE_COUNTDOWN = 30

local WHITE_ON_KILL_EFFECT_GHOST_VARIANT = EffectVariant.PURGATORY
local WHITE_ON_KILL_EFFECT_GHOST_SUBTYPE = 1

-- PINK CONFIG
local PINK_ON_KILL_EFFECT_ENTITY_FLAGS = EntityFlag.FLAG_CHARM | EntityFlag.FLAG_PERSISTENT

-- RED CONFIG
local RED_ON_KILL_EFFECT_EXPLOSION_SFX = SoundEffect.SOUND_EXPLOSION_DEBRIS
local RED_ON_KILL_EFFECT_EXPLOSION_SFX_VOLUME = 0.5
local RED_ON_KILL_EFFECT_EXPLOSION_VARIANT = EffectVariant.LARGE_BLOOD_EXPLOSION
local RED_ON_KILL_EFFECT_EXPLOSION_SUBTYPE = 0
local RED_ON_KILL_EFFECT_EXPLOSION_RADIUS = 85
local RED_ON_KILL_EFFECT_EXPLOSION_BAITED_DURATION = 290

---@param str string
---@return string
local function getFirstWord(str)
    return string.match(str, "^(%S+)")
end

-- populated automatically based on entity name, specifically first word (color), subtypes of entities used as keys
---@type table<integer, string>
local SPRITESHEETS = {}

---@type table<integer, ResouledEntityDesc>
local EGGS = {}

---@type table<integer, CollectibleType>
local ITEMS = {}

---@type table<integer, integer>
local STATUS_EFFECTS = {}

for _, entity in pairs(ENTITIES) do
    if not string.find(string.lower(entity.Name), "proglottid") then goto continue end

    local color = getFirstWord(entity.Name)
    SPRITESHEETS[entity.SubType] = string.lower("gfx_resouled/familiar/" .. color .. "_proglottid.png")
    EGGS[entity.SubType] = Resouled:GetEntityByName(entity.Name .. "'s Egg")
    ITEMS[entity.SubType] = Isaac.GetItemIdByName(entity.Name)

    for name, flag in pairs(StatusEffectLibrary.StatusFlag) do
        if string.find(string.lower(name), string.lower(color .. " proglottid")) then
            STATUS_EFFECTS[entity.SubType] = flag
            break
        end
    end

    ::continue::
end
local EGG_VARIANT = EGGS[ENTITIES.BLACK.SubType]
    .Variant -- all of them have the same variant so this doesnt really matter

---@param familiar EntityFamiliar
local function isProglottid(familiar)
    if familiar.Variant == ENTITIES.BLACK.Variant and SPRITESHEETS[familiar.SubType] then
        return true
    end
    return false
end

local function isEgg(tear)
    for _, egg in pairs(EGGS) do
        if tear.Variant == egg.Variant and tear.SubType == egg.SubType then
            return true
        end
    end
    return false
end

local SPRITESHEET_LAYER = 0

local ANIMATION_IDLE = "Idle"
local ANIMATION_SHOOT = "Shoot"

local ANIMATION_EVENT_SHOOT = "ResouledShoot"


---@param familiar EntityFamiliar
local function setRandomCooldown(familiar)
    familiar:GetData().RESOULED__PROGLOTTID_SHOOT_COOLDOWN =
        math.random(MIN_POST_ROOM_ENTER_SHOOT_DELAY, MAX_POST_ROOM_ENTER_SHOOT_DELAY)
end



---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    for _, entity in pairs(ENTITIES) do
        if not string.find(string.lower(entity.Name), "proglottid") then goto continue end

        Resouled.Familiar:CheckFamiliar(player, ITEMS[entity.SubType], entity.Variant, entity.SubType)

        ::continue::
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_FAMILIARS)



---@param familiar EntityFamiliar
local function onFamiliarInit(_, familiar)
    if not isProglottid(familiar) then return end

    familiar:AddToFollowers()
    familiar:GetSprite():ReplaceSpritesheet(SPRITESHEET_LAYER, SPRITESHEETS[familiar.SubType], true)
    setRandomCooldown(familiar)
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onFamiliarInit, ENTITIES.BLACK.Variant)



---@param familiar EntityFamiliar
local function onFamiliarUpdate(_, familiar)
    if not isProglottid(familiar) then return end

    local data = familiar:GetData()
    local sprite = familiar:GetSprite()

    -- COUNT DOWN TO SHOOT
    if data.RESOULED__PROGLOTTID_SHOOT_COOLDOWN then
        if data.RESOULED__PROGLOTTID_SHOOT_COOLDOWN > 0 then
            data.RESOULED__PROGLOTTID_SHOOT_COOLDOWN = data
                .RESOULED__PROGLOTTID_SHOOT_COOLDOWN - 1
        elseif Isaac.CountEnemies() > 0 then -- PLAY SHOOTING ANIMATION ONLY IF ENEMIES ARE PRESENT
            sprite:Play(ANIMATION_SHOOT, true)
            data.RESOULED__PROGLOTTID_SHOOT_COOLDOWN = nil
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
            local egg = EGGS[familiar.SubType]
            Game():Spawn(
                egg.Type,
                egg.Variant,
                shotTear.Position,
                shotTear.Velocity,
                familiar,
                egg.SubType,
                Resouled:NewSeed()
            )
            shotTear:Remove() -- Remove the original tear
        end
    end

    familiar:FollowParent()
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onFamiliarUpdate, ENTITIES.BLACK.Variant)



local function onRoomEnter()
    -- clearing kill count for white proglottid
    Isaac.GetPlayer():GetData().RESOULED__WHITE_PROGLOTTID_DEAD_ENEMIES_POSITIONS = nil

    Resouled.Iterators:IterateOverRoomFamiliars(function(familiar)
        if isProglottid(familiar) then
            setRandomCooldown(familiar)

            if familiar.SubType == ENTITIES.WHITE.SubType then
                familiar:GetData().RESOULED__WHITE_PROGLOTTID_ENEMIES_COUNT = 0
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onRoomEnter)



---@param tear EntityTear
---@param collider Entity
---@param low boolean
local function onTearCollision(_, tear, collider, low)
    if not isEgg(tear) or not collider:ToNPC() or not tear.SpawnerEntity then return end

    StatusEffectLibrary:AddStatusEffect(
        collider,
        STATUS_EFFECTS[tear.SpawnerEntity.SubType],
        -1,
        EntityRef(tear.SpawnerEntity)
    )
end
Resouled:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, onTearCollision)


---@param entity Entity
local function onEntityKill(_, entity)
    -- tracking room kills for white proglottid
    if PlayerManager.AnyoneHasCollectible(ITEMS[ENTITIES.WHITE.SubType]) and entity:IsEnemy() then
        local player0data = Isaac.GetPlayer():GetData()
        if not player0data.RESOULED__WHITE_PROGLOTTID_DEAD_ENEMIES_POSITIONS then
            player0data.RESOULED__WHITE_PROGLOTTID_DEAD_ENEMIES_POSITIONS = {}
        end

        table.insert(player0data.RESOULED__WHITE_PROGLOTTID_DEAD_ENEMIES_POSITIONS, entity.Position)
    end

    local blackEffect = StatusEffectLibrary:GetStatusEffectData(entity, STATUS_EFFECTS[ENTITIES.BLACK.SubType])
    local whiteEffect = StatusEffectLibrary:GetStatusEffectData(entity, STATUS_EFFECTS[ENTITIES.WHITE.SubType])
    local pinkEffect = StatusEffectLibrary:GetStatusEffectData(entity, STATUS_EFFECTS[ENTITIES.PINK.SubType])
    local redEffect = StatusEffectLibrary:GetStatusEffectData(entity, STATUS_EFFECTS[ENTITIES.RED.SubType])

    if not (blackEffect or whiteEffect or pinkEffect or redEffect) then return end

    if blackEffect then
        local effect = Game():Spawn(EntityType.ENTITY_EFFECT, BLACK_ON_KILL_EFFECT_VARIANT, entity.Position, Vector.Zero,
            blackEffect.Source.Entity, BLACK_ON_KILL_EFFECT_SUBTYPE, Resouled:NewSeed()):ToEffect()
        if not effect then return end

        effect:SetTimeout(BLACK_ON_KILL_EFFECT_DURATION)
        effect.SpriteScale = Vector(1, 1) * BLACK_ON_KILL_EFFECT_RADIUS
        effect:Update()
        effect:GetData().RESOULED__BLACK_PROGLOTTID_CREEP = true
        StatusEffectLibrary:RemoveStatusEffect(entity, STATUS_EFFECTS[ENTITIES.BLACK.SubType])
    end

    if whiteEffect then
        local effect = Game():Spawn(EntityType.ENTITY_EFFECT, WHITE_ON_KILL_EFFECT_EXPLOSION_VARIANT, entity.Position,
            Vector.Zero, whiteEffect.Source.Entity, WHITE_ON_KILL_EFFECT_EXPLOSION_SUBTYPE, Resouled:NewSeed())
        if not effect then return end

        for _, entity in ipairs(Isaac.FindInRadius(entity.Position, WHITE_ON_KILL_EFFECT_EXPLOSION_RADIUS, EntityPartition.ENEMY)) do
            entity:TakeDamage(WHITE_ON_KILL_EFFECT_EXPLOSION_DAMAGE, WHITE_ON_KILL_EFFECT_EXPLOSION_DAMAGE_FLAGS,
                whiteEffect.Source, WHITE_ON_KILL_EFFECT_EXPLOSION_DAMAGE_COUNTDOWN)

            ---@type Vector[]?
            local ghostSpawnPositions = Isaac.GetPlayer():GetData().RESOULED__WHITE_PROGLOTTID_DEAD_ENEMIES_POSITIONS
            if not ghostSpawnPositions then return end

            for _, position in ipairs(ghostSpawnPositions) do
                Game():Spawn(EntityType.ENTITY_EFFECT, WHITE_ON_KILL_EFFECT_GHOST_VARIANT, position, Vector.Zero,
                    entity,
                    WHITE_ON_KILL_EFFECT_GHOST_SUBTYPE, Resouled:NewSeed()):ToEffect()
            end
        end
        SFXManager():Play(WHITE_ON_KILL_EFFECT_EXPLOSION_SFX, WHITE_ON_KILL_EFFECT_EXPLOSION_SFX_VOLUME)
        StatusEffectLibrary:RemoveStatusEffect(entity, STATUS_EFFECTS[ENTITIES.WHITE.SubType])
    end

    if pinkEffect then
        local newNpc = Game():Spawn(entity.Type, entity.Variant, entity.Position, Vector.Zero, pinkEffect.Source.Entity,
            entity.SubType, Resouled:NewSeed()):ToNPC()
        if not newNpc then return end

        ---@diagnostic disable-next-line: param-type-mismatch
        newNpc:AddEntityFlags(PINK_ON_KILL_EFFECT_ENTITY_FLAGS)
        newNpc:AddCharmed(pinkEffect.Source, -1)
        StatusEffectLibrary:RemoveStatusEffect(entity, STATUS_EFFECTS[ENTITIES.PINK.SubType])
    end

    if redEffect then
        Game():Spawn(EntityType.ENTITY_EFFECT, RED_ON_KILL_EFFECT_EXPLOSION_VARIANT, entity.Position, Vector.Zero,
            redEffect.Source.Entity, RED_ON_KILL_EFFECT_EXPLOSION_SUBTYPE, Resouled:NewSeed())

        for _, entity in ipairs(Isaac.FindInRadius(entity.Position, RED_ON_KILL_EFFECT_EXPLOSION_RADIUS, EntityPartition.ENEMY)) do
            entity:AddBaited(redEffect.Source, RED_ON_KILL_EFFECT_EXPLOSION_BAITED_DURATION)
        end

        SFXManager():Play(RED_ON_KILL_EFFECT_EXPLOSION_SFX, RED_ON_KILL_EFFECT_EXPLOSION_SFX_VOLUME)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, onEntityKill)


---@param effect EntityEffect
---@param value? number if not specified, rolls a random value between specified boundaries
local function setCreepTentacleCooldown(effect, value)
    value = value or math.random(STUN_TENTACLE_EFFECT_MIN_COOLDOWN, STUN_TENTACLE_EFFECT_MAX_COOLDOWN)
    effect:GetData().RESOULED__BLACK_PROGLOTTID_STUN_COOLDOWN = value
end



---@param effect EntityEffect
local function creepUpdate(_, effect)
    local data = effect:GetData()
    if not data.RESOULED__BLACK_PROGLOTTID_CREEP then return end

    if not data.RESOULED__BLACK_PROGLOTTID_STUN_COOLDOWN then
        setCreepTentacleCooldown(effect, 0)
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
            Game():Spawn(ENTITIES.STUN_TENTACLE.Type, ENTITIES.STUN_TENTACLE.Variant, target.Position, Vector.Zero,
                effect,
                ENTITIES.STUN_TENTACLE.SubType, Resouled:NewSeed())
            setCreepTentacleCooldown(effect)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, creepUpdate, BLACK_ON_KILL_EFFECT_VARIANT)
