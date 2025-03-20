local CURSED_GAPER_VARIANT = Isaac.GetEntityVariantByName("Cursed Gaper")
local CURSED_GAPER_TYPE = Isaac.GetEntityTypeByName("Cursed Gaper")
local HALO_SUBTYPE = 3

local HALO_OFFSET = Vector(0, -15)
local HALO_SCALE = Vector(1.5, 1.5)

local ACTIVATION_DISTANCE = 110

local DEATH_TEARS_SPAWN_COUNT = 3
local DEATH_TEAR_BULLET_FLAGS = (ProjectileFlags.SMART | ProjectileFlags.ACCELERATE | ProjectileFlags.BURST)
local DEATH_TEAR_HOMING_STRENGTH = 0.05
local DEATH_TEAR_ACCELERATION = 1.08

local CURSED_ENEMY_MORPH_CHANCE = 0.1

---@param entity Entity
local function onEntityKill(_, entity)
    local npc = entity:ToNPC()
    if npc and npc.Variant == CURSED_GAPER_VARIANT then
        local DEATH_PROJECTILE_PARAMS = ProjectileParams()
        DEATH_PROJECTILE_PARAMS.BulletFlags = DEATH_TEAR_BULLET_FLAGS
        DEATH_PROJECTILE_PARAMS.Acceleration = DEATH_TEAR_ACCELERATION
        DEATH_PROJECTILE_PARAMS.HomingStrength = DEATH_TEAR_HOMING_STRENGTH
        for i = 1, DEATH_TEARS_SPAWN_COUNT do
            npc:FireProjectiles(npc.Position, Vector.FromAngle(i * 360 / DEATH_TEARS_SPAWN_COUNT):Resized(1), 0, DEATH_PROJECTILE_PARAMS)
        end

        -- remove buff from every entity
        -- will be reapplied by other cursed gaapers so removeing it for 1 update is not that big of a deal
        Resouled:IterateOverRoomEntities(function(entity)
            local entityData = entity:GetData()
            if entityData.ResouledCurseGaperBuff then
                entityData.ResouledCurseGaperBuff = false
            end
        end)
        entity:Remove()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, onEntityKill, CURSED_GAPER_TYPE)

---@param npc EntityNPC
local function onNpcInit(_, npc)
    --Try to turn enemy into a cursed enemy
    if Game():GetLevel():GetCurses() > 0 then
        Resouled:TryEnemyMorph(npc, CURSED_ENEMY_MORPH_CHANCE, CURSED_GAPER_TYPE, CURSED_GAPER_VARIANT, 0)
    end

    --Add halo
    if npc.Variant == CURSED_GAPER_VARIANT then
        Resouled:AddHaloToNpc(npc, HALO_SUBTYPE, HALO_SCALE, HALO_OFFSET)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_GAPER_TYPE)

---@param npc EntityNPC
local function preNpcUpdate(_, npc)
    if npc.Variant == CURSED_GAPER_VARIANT then
        ---@param entity Entity
        Resouled:IterateOverRoomEntities(function(entity)
            local otherNpc = entity:ToNPC()
            local entityData = entity:GetData()
            if otherNpc and otherNpc:IsActiveEnemy() and not otherNpc:IsDead() and npc.Position:Distance(otherNpc.Position) < ACTIVATION_DISTANCE then
                entityData.ResouledCurseGaperBuff = true
            else
                entityData.ResouledCurseGaperBuff = false
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, preNpcUpdate, CURSED_GAPER_TYPE)

---@param entity Entity
---@param amount number
---@param flags integer
---@param source EntityRef
---@param countdown integer
local function onPlayerTakeDamage(_, entity, amount, flags, source, countdown)
    local sourceEnt = source.Entity
    local sourceData = sourceEnt:GetData()
    local entityData = entity:GetData()
    if sourceData.ResouledCurseGaperBuff and amount == 1 then
        entityData.ResouledCursedGaperBuffDamage = true
        entity:TakeDamage(2, flags, source, countdown)
        print("Cursed Gaper buffed damage")
        return false
    end

    if entityData.ResouledCursedGaperBuffDamage then
        entityData.ResouledCursedGaperBuffDamage = false
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onPlayerTakeDamage, EntityType.ENTITY_PLAYER)