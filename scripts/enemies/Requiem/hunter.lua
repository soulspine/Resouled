local HUNTER_TYPE = Isaac.GetEntityTypeByName("Hunter")
local HUNTER_VARIANT = Isaac.GetEntityVariantByName("Hunter")
local HUNTER_SUBTYPE = Isaac.GetEntityTypeByName("Haunt")

local APPEAR = "Appear"
local IDLE = "OpenIdle"

local OPEN_TRIGGER = "ResouledOpen"

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == HUNTER_VARIANT then
        local sprite = npc:GetSprite()

        sprite:Play("Appear", true)

        npc.DepthOffset = 1000

        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, HUNTER_TYPE)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == HUNTER_VARIANT then
        local sprite = npc:GetSprite()

        if sprite:IsEventTriggered(OPEN_TRIGGER) then
            sprite:Play(IDLE, true)
        end

        if sprite:IsPlaying(IDLE) then
            Game():Darken(1, 1)
        end

        sprite:GetLayer(4):SetPos((Game():GetNearestPlayer(npc.Position).Position - npc.Position):Normalized() * 4)

    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, HUNTER_TYPE)