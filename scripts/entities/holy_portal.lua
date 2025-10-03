local PORTAL_DESC = Resouled:GetEntityByName("Holy Portal")

local SPAWN_SFX = "Holy Spawn " --add tostring math.random
local SPAWN_SFX_VOLUME = 2

local HOLY_ENEMIES = {
    BONY = Resouled:EntityDescConstructor(227, 1, 0, "Holy Bony"),
    MULLIGAN = Resouled:EntityDescConstructor(22, 2, 0, "Holy Mulligan"),
    LEECH = Resouled:EntityDescConstructor(55, 2, 0, "Holy Leech"),
    EYE = Resouled:EntityDescConstructor(60, 2, 0, "Holy Eye"),
    ANGELIC_BABY = Resouled:EntityDescConstructor(38, 1, 0, "Angelic Baby"),
    --ANGELIC_BABY_SMALL = Resouled:GetEntityByName("Angelic Baby (small)"), --useless since there is normal variant
    BRAIN = Resouled:GetEntityByName("Holy Brain"),
    PSY_HORF = Resouled:GetEntityByName("Holy Psy Horf"),
    DIP = Resouled:GetEntityByName("Holy Dip"),
    SQUIRT = Resouled:GetEntityByName("Holy Squirt"),
}

---@type table<ResouledEntityDesc, ResouledEntityDesc>
local ENTITIES_SPAWN_LOOKUP = {
    [Resouled:EntityDescConstructor(227, 0, 0, "Bony")] = HOLY_ENEMIES.BONY,
    [Resouled:EntityDescConstructor(16, 0, 0, "Mulligan")] = HOLY_ENEMIES.MULLIGAN,
    [Resouled:EntityDescConstructor(55, 0, 0, "Leech")] = HOLY_ENEMIES.LEECH,
    [Resouled:EntityDescConstructor(55, 1, 0, "Kamikaze Leech")] = HOLY_ENEMIES.LEECH,
    [Resouled:EntityDescConstructor(60, 0, 0, "Eye")] = HOLY_ENEMIES.EYE,
    [Resouled:EntityDescConstructor(60, 1, 0, "Bloodshot Eye")] = HOLY_ENEMIES.EYE,
    [Resouled:EntityDescConstructor(38, 0, 0, "Baby")] = HOLY_ENEMIES.ANGELIC_BABY,
    [Resouled:EntityDescConstructor(38, 2, 0, "Ultra Pride Baby")] = HOLY_ENEMIES.ANGELIC_BABY,
    [Resouled:EntityDescConstructor(38, 3, 0, "Wrinkly Baby")] = HOLY_ENEMIES.ANGELIC_BABY,
    [Resouled:EntityDescConstructor(32, 0, 0, "Brain")] = HOLY_ENEMIES.BRAIN,
    [Resouled:EntityDescConstructor(26, 2, 0, "Psychic Horf")] = HOLY_ENEMIES.PSY_HORF,
    [Resouled:EntityDescConstructor(217, 0, 0, "Dip")] = HOLY_ENEMIES.DIP,
    [Resouled:EntityDescConstructor(217, 1, 0, "Corn")] = HOLY_ENEMIES.DIP,
    [Resouled:EntityDescConstructor(217, 2, 0, "Brownie Corn")] = HOLY_ENEMIES.DIP,
    [Resouled:EntityDescConstructor(217, 3, 0, "Big Corn")] = HOLY_ENEMIES.DIP,
    [Resouled:EntityDescConstructor(220, 0, 0, "Squirt")] = HOLY_ENEMIES.SQUIRT,
    [Resouled:EntityDescConstructor(220, 1, 0, "Dank Squirt")] = HOLY_ENEMIES.SQUIRT,
}

---@param type integer
---@param variant integer
---@param subtype integer
local function makeLookupKey(type, variant, subtype)
    return tostring(type) .. "_" .. tostring(variant) .. "_" .. tostring(subtype)
end
-- populated at runtime with string keys with data from ENTITIES_LOOKUP for faster access
local entitiesLookup = {}
for dyingEntity, spawningEntity in pairs(ENTITIES_SPAWN_LOOKUP) do
    entitiesLookup[makeLookupKey(dyingEntity.Type, dyingEntity.Variant, dyingEntity.SubType)] = spawningEntity
end


local function isHolyEnemy(entity)
    for _, desc in pairs(HOLY_ENEMIES) do
        if Resouled:MatchesEntityDesc(entity, desc) then
            return true
        end
    end
    return false
end

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == PORTAL_DESC.Variant and npc.SubType == PORTAL_DESC.SubType then
        npc:GetSprite():Play("Idle", true)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, PORTAL_DESC.Type)

---@param portal Entity
---@param entityDesc ResouledEntityDesc
local function spawnHolyEnemy(portal, entityDesc)
    local spawnedEntity = Game():Spawn(
        entityDesc.Type,
        entityDesc.Variant,
        portal.Position + Vector(0, 1),
        Vector(0, 5),
        portal,
        entityDesc.SubType,
        Resouled:NewSeed()
    )
    spawnedEntity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    spawnedEntity:SetColor(Color(1, 0, 1, 0, 1, 0, 1), 20, 9999, true, true)
    SFXManager():Play(Isaac.GetSoundIdByName(SPAWN_SFX .. tostring(math.random(1, 3))), SPAWN_SFX_VOLUME)
    portal:SetColor(Color(1, 1, 1, 1, 0.25, 0.1, 0.25), 15, 1, true, true)
end

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    local spawningEntity = entitiesLookup[makeLookupKey(npc.Type, npc.Variant, npc.SubType)]
    if not spawningEntity then return end

    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        if Resouled:MatchesEntityDesc(entity, PORTAL_DESC) then
            spawnHolyEnemy(entity, spawningEntity)
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == PORTAL_DESC.Variant and npc.SubType == PORTAL_DESC.SubType then
        local sprite = npc:GetSprite()
        local enemyCount = 0
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            if entity:IsEnemy() and entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
                if isHolyEnemy(entity) or Resouled:MatchesEntityDesc(entity, PORTAL_DESC) then
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
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, PORTAL_DESC.Type)
