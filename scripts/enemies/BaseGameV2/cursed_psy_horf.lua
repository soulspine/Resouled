local CURSED_PSY_HORF_VARIANT = Isaac.GetEntityVariantByName("Cursed Psy Horf")
local CURSED_PSY_HORF_TYPE = Isaac.GetEntityTypeByName("Cursed Psy Horf")
local HALO_SUBTYPE = 3

local HALO_OFFSET = Vector(0, -15)
local HALO_SCALE = Vector(0.5, 0.5)

local ACTIVATION_DISTANCE = 110

local CURSED_ENEMY_MORPH_CHANCE = 0.1

local SHOOT = "ResouledShoot"

local PROJECTILE_PARAMS = ProjectileParams()
local PROJECTILE_FLAGS = (ProjectileFlags.SMART)

---@param npc EntityNPC
local function onNpcInit(_, npc)
    --Try to turn enemy into a cursed enemy
    if Game():GetLevel():GetCurses() > 0 then
        Resouled:TryEnemyMorph(npc, CURSED_ENEMY_MORPH_CHANCE, CURSED_PSY_HORF_TYPE, CURSED_PSY_HORF_VARIANT, 0)
    end
    

    --Add halo
    if npc.Variant == CURSED_PSY_HORF_VARIANT then
        local data = npc:GetData()
        PROJECTILE_PARAMS.BulletFlags = PROJECTILE_FLAGS
        data.ProjectileParams = PROJECTILE_PARAMS
        Resouled:AddHaloToNpc(npc, HALO_SUBTYPE, HALO_SCALE, HALO_OFFSET)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_PSY_HORF_TYPE)

---@param npc EntityNPC
local function preNpcUpdate(_, npc)
    if npc.Variant == CURSED_PSY_HORF_VARIANT then
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        if sprite:WasEventTriggered(SHOOT) then
            npc:FireProjectiles(npc.Position, (npc:GetPlayerTarget().Position - npc.Position) / 25, 0, data.ProjectileParams)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, preNpcUpdate, CURSED_PSY_HORF_TYPE)

---@param type CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param activeSlot ActiveSlot
local function onActiveItemUse(_, type, rng, player, activeSlot)
    Resouled:IterateOverRoomEntities(
    ---@param npc EntityRef
    function(npc)
        if npc.Type == CURSED_PSY_HORF_TYPE and npc.Variant == CURSED_PSY_HORF_VARIANT then 
            player:AddControlsCooldown(150)
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, onActiveItemUse)