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

local CURSED_ENEMY_MORPH_CHANCE = 0.05

---@param npc EntityNPC
local function onNPCDeath(_, npc)
    if npc.Variant == CURSED_GAPER_VARIANT then
        npc:Die()
        local DEATH_PROJECTILE_PARAMS = ProjectileParams()
        DEATH_PROJECTILE_PARAMS.BulletFlags = DEATH_TEAR_BULLET_FLAGS
        DEATH_PROJECTILE_PARAMS.Acceleration = DEATH_TEAR_ACCELERATION
        DEATH_PROJECTILE_PARAMS.HomingStrength = DEATH_TEAR_HOMING_STRENGTH
        for i = 1, DEATH_TEARS_SPAWN_COUNT do
            npc:FireProjectiles(npc.Position, Vector.FromAngle(i * 360 / DEATH_TEARS_SPAWN_COUNT):Resized(1), 0, DEATH_PROJECTILE_PARAMS)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNPCDeath, CURSED_GAPER_TYPE)

local function onRoomEnter()
    local rng = RNG()
    if Game():GetLevel():GetCurses() < 0 then
        return
    end
    for _ = 1, #Isaac.GetRoomEntities() do
        local npc = Isaac.GetRoomEntities()[_]
        rng:SetSeed(npc:GetDropRNG():GetSeed(), 0)
        if npc == EntityType.ENTITY_PLAYER or not npc:IsEnemy() then
        elseif npc.Type == CURSED_GAPER_TYPE and rng:RandomFloat() < CURSED_ENEMY_MORPH_CHANCE then
            Game():Spawn(CURSED_GAPER_TYPE, CURSED_GAPER_VARIANT, npc.Position, Vector(0, 0), nil, 0, npc:GetDropRNG():GetSeed())
            npc:Die()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onRoomEnter)

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == CURSED_GAPER_VARIANT then
        Resouled:AddHaloToNpc(npc, HALO_SUBTYPE, HALO_SCALE, HALO_OFFSET)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_GAPER_TYPE)

---@param npc EntityNPC
local function preNpcUpdate(_, npc)
    if npc.Variant == CURSED_GAPER_VARIANT then
        for _ = 1, #Isaac.GetRoomEntities() do
            local entity = Isaac.GetRoomEntities()[_]
            local data = entity:GetData()
            if data.FirstLook == nil then
                data.BaseDamage = entity.CollisionDamage
                data.DamageAdded = false
                data.FirstLook = 1
            end
            if Game():GetLevel():GetStage() < 7 then --before the womb
                if entity:IsEnemy() and data.DamageAdded == false and entity.Position:Distance(npc.Position) < ACTIVATION_DISTANCE then
                    entity.CollisionDamage = data.BaseDamage + 1
                    data.DamageAdded = true
                    print(entity.CollisionDamage)
                elseif data.DamageAdded == true and entity.Position:Distance(npc.Position) >= ACTIVATION_DISTANCE then
                    entity.CollisionDamage = entity.CollisionDamage - 1
                    data.DamageAdded = false
                    print(entity.CollisionDamage)
                end    
            elseif Game():GetLevel():GetStage() >= 7 then --after the womb
                if entity:IsEnemy() and data.DamageAdded == false and entity.Position:Distance(npc.Position) < ACTIVATION_DISTANCE then
                    entity.CollisionDamage = data.BaseDamage + 2
                    data.DamageAdded = true
                    print(entity.CollisionDamage)
                elseif data.DamageAdded == true and entity.Position:Distance(npc.Position) >= ACTIVATION_DISTANCE then
                    entity.CollisionDamage = entity.CollisionDamage - 2
                    data.DamageAdded = false
                    print(entity.CollisionDamage)
                end    
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, preNpcUpdate, CURSED_GAPER_TYPE)