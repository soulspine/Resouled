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

---@param str string
---@return string
local function getFirstWord(str)
    return string.match(str, "^(%S+)")
end

-- populated automatically based on entity name, specifically first word (color), subtypes of entities used as keys
---@type table<integer, string>
local SPRITESHEETS = {}

---@type table<integer, string>
local COLORS = {}

---@type table<integer, ResouledEntityDesc>
local EGGS = {}

---@type table<integer, CollectibleType>
local ITEMS = {}

for _, entity in pairs(ENTITIES) do
    if not string.find(string.lower(entity.Name), "proglottid") then goto continue end

    local color = getFirstWord(entity.Name)
    COLORS[entity.SubType] = color
    SPRITESHEETS[entity.SubType] = string.lower("gfx/familiar/" .. color .. "_proglottid.png")
    EGGS[entity.SubType] = Resouled:GetEntityByName(entity.Name .. "'s Egg")
    ITEMS[entity.SubType] = Isaac.GetItemIdByName(entity.Name)

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

local SPRITESHEET_LAYER = 0

local ANIMATION_IDLE = "Idle"
local ANIMATION_SHOOT = "Shoot"

local ANIMATION_EVENT_SHOOT = "ResouledShoot"

if EID then
    EID:addCollectible(ITEMS[ENTITIES.BLACK.SubType],
        Resouled.EID:AutoIcons(
            "Familiar that shoots an egg once per room#Enemy hit by this egg will spawn a moderately large black creep pool on death#Enemies standing in this creep get slowed and occasionally immobilized # Creep lasts " ..
            math.floor(BLACK_ON_KILL_EFFECT_DURATION / 30) .. " seconds"),
        ENTITIES.BLACK.Name)
end



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

    Resouled.Familiar:CheckFamiliar(
        player, ITEMS[ENTITIES.BLACK.SubType], ENTITIES.BLACK.Variant, ENTITIES.BLACK.SubType)

    Resouled.Familiar:CheckFamiliar(
        player, ITEMS[ENTITIES.WHITE.SubType], ENTITIES.WHITE.Variant, ENTITIES.WHITE.SubType)
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
    if tear.Variant ~= EGG_VARIANT or not collider:ToNPC() or not tear.SpawnerEntity then return end

    collider:GetData().RESOULED__TAGGED_BY_PROGLOTTID = {
        Color = COLORS[tear.SpawnerEntity.SubType],
        Source = EntityRef(tear.SpawnerEntity),
    }
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

    local data = entity:GetData()
    if not data.RESOULED__TAGGED_BY_PROGLOTTID then return end
    ---@type string
    local color = data.RESOULED__TAGGED_BY_PROGLOTTID.Color
    ---@type EntityRef
    local source = data.RESOULED__TAGGED_BY_PROGLOTTID.Source

    -- BLACK EFFECT
    if color == COLORS[ENTITIES.BLACK.SubType] then
        local effect = Game():Spawn(EntityType.ENTITY_EFFECT, BLACK_ON_KILL_EFFECT_VARIANT, entity.Position, Vector.Zero,
            source.Entity, BLACK_ON_KILL_EFFECT_SUBTYPE, Resouled:NewSeed()):ToEffect()
        if not effect then return end

        effect:SetTimeout(BLACK_ON_KILL_EFFECT_DURATION)
        effect.SpriteScale = Vector(1, 1) * BLACK_ON_KILL_EFFECT_RADIUS
        effect:Update()
        effect:GetData().RESOULED__BLACK_PROGLOTTID_CREEP = true
    end

    -- WHITE EFFECT
    if color == COLORS[ENTITIES.WHITE.SubType] then
        Game():Spawn(EntityType.ENTITY_EFFECT, WHITE_ON_KILL_EFFECT_EXPLOSION_VARIANT, entity.Position, Vector.Zero,
            source.Entity, WHITE_ON_KILL_EFFECT_EXPLOSION_SUBTYPE, Resouled:NewSeed())

        for _, entity in ipairs(Isaac.FindInRadius(entity.Position, WHITE_ON_KILL_EFFECT_EXPLOSION_RADIUS, EntityPartition.ENEMY)) do
            entity:TakeDamage(WHITE_ON_KILL_EFFECT_EXPLOSION_DAMAGE, WHITE_ON_KILL_EFFECT_EXPLOSION_DAMAGE_FLAGS,
                source, WHITE_ON_KILL_EFFECT_EXPLOSION_DAMAGE_COUNTDOWN)

            ---@type Vector[]?
            local ghostSpawnPositions = Isaac.GetPlayer():GetData().RESOULED__WHITE_PROGLOTTID_DEAD_ENEMIES_POSITIONS
            if not ghostSpawnPositions then return end

            for _, position in ipairs(ghostSpawnPositions) do
                Game():Spawn(EntityType.ENTITY_EFFECT, WHITE_ON_KILL_EFFECT_GHOST_VARIANT, position, Vector.Zero,
                    entity,
                    WHITE_ON_KILL_EFFECT_GHOST_SUBTYPE, Resouled:NewSeed()):ToEffect()
            end
        end
    end

    -- PINK EFFECT
    if color == COLORS[ENTITIES.PINK.SubType] then
        local newNpc = Game():Spawn(entity.Type, entity.Variant, entity.Position, Vector.Zero, source.Entity,
            entity.SubType, Resouled:NewSeed()):ToNPC()
        if not newNpc then return end

        ---@diagnostic disable-next-line: param-type-mismatch
        newNpc:AddEntityFlags(PINK_ON_KILL_EFFECT_ENTITY_FLAGS)
        newNpc:AddCharmed(source, -1)
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
