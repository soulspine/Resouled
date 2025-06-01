local HOLY_PORTAL_TYPE = Isaac.GetEntityTypeByName("Holy Portal")
local HOLY_PORTAL_VARIANT = Isaac.GetEntityVariantByName("Holy Portal")
local HOLY_PORTAL_SUBTYPE = Isaac.GetEntitySubTypeByName("Holy Portal")

local SPAWN_SFX = "Holy Spawn " --add tostring math.random
local SPAWN_SFX_VOLUME = 2

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == HOLY_PORTAL_VARIANT and npc.SubType == HOLY_PORTAL_SUBTYPE then
        npc:GetSprite():Play("Idle", true)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, HOLY_PORTAL_TYPE)

---@param portal Entity
---@param type EntityType
---@param variant integer
---@param subtype integer
local function spawnHolyEnemy(portal, type, variant, subtype)
    local spawnedEntity = Game():Spawn(type, variant, portal.Position + Vector(0, 1), Vector(0, 5), nil, subtype, portal.InitSeed)
    spawnedEntity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    spawnedEntity:SetColor(Color(1, 0, 1, 0, 1, 0, 1), 20, 9999, true, true)
    local randomNum = math.random(1, 3)
    SFXManager():Play(Isaac.GetSoundIdByName(SPAWN_SFX..tostring(randomNum)), SPAWN_SFX_VOLUME)
    portal:SetColor(Color(1, 1, 1, 1, 0.25, 0.1, 0.25), 15, 1, true, true)
end

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    if npc.Type == EntityType.ENTITY_BONY and npc.Variant == 0 then
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            if entity.Type == HOLY_PORTAL_TYPE and entity.Variant == HOLY_PORTAL_VARIANT and entity.SubType == HOLY_PORTAL_SUBTYPE then --Bony
                spawnHolyEnemy(entity, EntityType.ENTITY_BONY, 1, 0)
            end
        end)
    end
    if npc.Type == EntityType.ENTITY_MULLIGAN then
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            if entity.Type == HOLY_PORTAL_TYPE and entity.Variant == HOLY_PORTAL_VARIANT and entity.SubType == HOLY_PORTAL_SUBTYPE then --Mulligan
                spawnHolyEnemy(entity, 22, 2, 0)
            end
        end)
    end
    if npc.Type == EntityType.ENTITY_LEECH and npc.Variant ~= 2 then
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            if entity.Type == HOLY_PORTAL_TYPE and entity.Variant == HOLY_PORTAL_VARIANT and entity.SubType == HOLY_PORTAL_SUBTYPE then --Leech
                spawnHolyEnemy(entity, EntityType.ENTITY_LEECH, 2, 0)
            end
        end)
    end
    if npc.Type == EntityType.ENTITY_EYE and npc.Variant ~= 2 then
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            if entity.Type == HOLY_PORTAL_TYPE and entity.Variant == HOLY_PORTAL_VARIANT and entity.SubType == HOLY_PORTAL_SUBTYPE then --Eye
                spawnHolyEnemy(entity, EntityType.ENTITY_EYE, 2, 0)
            end
        end)
    end
    if npc.Type == EntityType.ENTITY_BABY and npc.Variant ~= 1 and npc.Variant ~= 2 then
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            if entity.Type == HOLY_PORTAL_TYPE and entity.Variant == HOLY_PORTAL_VARIANT and entity.SubType == HOLY_PORTAL_SUBTYPE then --Baby
                spawnHolyEnemy(entity, EntityType.ENTITY_BABY, 1, 0)
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == HOLY_PORTAL_VARIANT and npc.SubType == HOLY_PORTAL_SUBTYPE then
        local sprite = npc:GetSprite()
        local enemyCount = 0
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            if entity:IsEnemy() and entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
                if entity.Type == HOLY_PORTAL_TYPE and entity.Variant == HOLY_PORTAL_VARIANT and entity.SubType == HOLY_PORTAL_SUBTYPE then
                else
                    enemyCount = enemyCount + 1
                end
            end
        end)

        if enemyCount == 0 and sprite:IsPlaying("Idle") then
            sprite:Play("Death", true)
            npc.CanShutDoors = false
        end

        if sprite:IsFinished("Death") then
            npc:Die()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, HOLY_PORTAL_TYPE)