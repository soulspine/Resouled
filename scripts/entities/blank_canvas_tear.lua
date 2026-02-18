local TEAR_TYPE = Isaac.GetEntityTypeByName("Blank Canvas Tear")
local TEAR_VARIANT = Isaac.GetEntityVariantByName("Blank Canvas Tear")
local TEAR_SUBTYPE = Isaac.GetEntitySubTypeByName("Blank Canvas Tear")

local GORE_PARTICLE_COUNT = 3

local DEATH1_SFX = Isaac.GetSoundIdByName("Paper Death 1")
local DEATH2_SFX = Isaac.GetSoundIdByName("Paper Death 2")
local DEATH3_SFX = Isaac.GetSoundIdByName("Paper Death 3")

local SFX_VOLUME = 1.5

local DEATH_SOUND_TABLE = {
    [1] = DEATH1_SFX,
    [2] = DEATH2_SFX,
    [3] = DEATH3_SFX,
}

local THE_SOUL_ACTIVATION_DISTANCE = 100

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == TEAR_VARIANT and npc.SubType == TEAR_SUBTYPE then
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, TEAR_TYPE)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == TEAR_VARIANT and npc.SubType == TEAR_SUBTYPE then
        local players = Isaac.FindInRadius(npc.Position, THE_SOUL_ACTIVATION_DISTANCE, EntityPartition.PLAYER)
        ---@param en Entity
        for _, en in pairs(players) do
            local player = en:ToPlayer()
            if not player then return end
            if player:HasCollectible(CollectibleType.COLLECTIBLE_SOUL) then
                if player.Position:Distance(npc.Position) < THE_SOUL_ACTIVATION_DISTANCE then
                    npc.Velocity = npc.Velocity + (npc.Position - player.Position):Normalized()/2
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, TEAR_TYPE)

---@param npc EntityNPC
---@param collider Entity
local function postNpcCollision(_, npc, collider)
    if npc.Variant == TEAR_VARIANT and npc.SubType == TEAR_SUBTYPE then
        local player = collider:ToPlayer()
        if player then
            player:TakeDamage(1, DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(npc.SpawnerEntity), 1)
            local randomNum = math.random(1, 3)
            SFXManager():Play(DEATH_SOUND_TABLE[randomNum], SFX_VOLUME)
            Resouled:SpawnPaperGore(npc.Position, GORE_PARTICLE_COUNT + math.random(-1, 1))
            npc:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_COLLISION, postNpcCollision, TEAR_TYPE)

---@param npc EntityNPC
local function postGridCollision(_, npc)
    if npc.Variant == TEAR_VARIANT and npc.SubType == TEAR_SUBTYPE then
        local randomNum = math.random(1, 3)
        SFXManager():Play(DEATH_SOUND_TABLE[randomNum], SFX_VOLUME)
        Resouled:SpawnPaperGore(npc.Position, GORE_PARTICLE_COUNT + math.random(-1, 1))
        npc:Remove()
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_GRID_COLLISION, postGridCollision, TEAR_TYPE)

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    if npc.Variant == TEAR_VARIANT and npc.SubType == TEAR_SUBTYPE then
        local randomNum = math.random(1, 3)
        SFXManager():Play(DEATH_SOUND_TABLE[randomNum], SFX_VOLUME)
        Resouled:SpawnPaperGore(npc.Position, GORE_PARTICLE_COUNT)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath, TEAR_TYPE)