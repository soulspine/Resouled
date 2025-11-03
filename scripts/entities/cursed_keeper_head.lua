local CURSED_KEEPER_HEAD_VARIANT = Isaac.GetEntityVariantByName("Cursed Keeper Head")
local CURSED_KEEPER_HEAD_TYPE = Isaac.GetEntityTypeByName("Cursed Keeper Head")
local CURSED_KEEPER_HEAD_SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Keeper Head")

local CURSED_ENEMY_MORPH_CHANCE = Resouled.Stats.CursedEnemyMorphChance

local ATTACK1 = {
    [1] = -20,
    [2] = 20
}
local ATTACK2 = {
    [1] = -40,
    [2] = 0,
    [3] = 40
}

local PROJECTILE_PARAMS = Resouled.Stats:GetCursedProjectileParams()
local PROJECTILE_SPEED = 7

---@param npc EntityNPC
local function onNpcInit(_, npc)
    --Try to turn enemy into a cursed enemy
    if Game():GetLevel():GetCurses() > 0 then
        Resouled:TryEnemyMorph(npc, CURSED_ENEMY_MORPH_CHANCE, CURSED_KEEPER_HEAD_TYPE, CURSED_KEEPER_HEAD_VARIANT, CURSED_KEEPER_HEAD_SUBTYPE)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_KEEPER_HEAD_TYPE)

---@param npc EntityNPC
local function preNpcUpdate(_, npc)
    if npc.Variant == CURSED_KEEPER_HEAD_VARIANT then
        local sprite = npc:GetSprite()

        local player = npc:GetPlayerTarget()
        if sprite:IsEventTriggered("Shoot1") then
            local npcToPlayerVector = (player.Position - npc.Position):Normalized() * PROJECTILE_SPEED
            for i = 1, #ATTACK1 do
                npc:FireProjectiles(npc.Position, npcToPlayerVector:Rotated(ATTACK1[i]), 0, PROJECTILE_PARAMS)
            end
        end
        if sprite:IsEventTriggered("Shoot2") then
            local npcToPlayerVector = (player.Position - npc.Position):Normalized() * PROJECTILE_SPEED
            for i = 1, #ATTACK2 do
                npc:FireProjectiles(npc.Position, npcToPlayerVector:Rotated(ATTACK2[i]), 0, PROJECTILE_PARAMS)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, preNpcUpdate, CURSED_KEEPER_HEAD_TYPE)