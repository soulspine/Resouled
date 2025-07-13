local MAMA_HAUNT = Isaac.GetItemIdByName("Mama Haunt")
local MAMA_HAUNT_VARIANT = Isaac.GetEntityVariantByName("Mama Haunt")
local MAMA_HAUNT_SUBTYPE = Isaac.GetEntitySubTypeByName("Mama Haunt")

local SING_PETRIFY_DURATION = 90
local SING_PETRIFY_COOLDOWN = 210 -- in updates, each second is 30 updates

if EID then
    EID:addCollectible(MAMA_HAUNT, "Every " .. math.ceil(SING_PETRIFY_COOLDOWN/30) .. " seconds, Mama Haunt sings, petrifying all enemies in the room for " .. math.ceil(SING_PETRIFY_DURATION/30) .. " seconds", "Mama Haunt")
end

local Note = {
    Variant = Isaac.GetEntityVariantByName("Music Note"),
    SubType = Isaac.GetEntitySubTypeByName("Music Note"),
    LowestColorValue = 150,
}

local ANIMATION_SING = "Sing"
local ANIMATION_IDLE = "Idle"
local ANIMATION_TRIGGER_PETRIFY = "Petrify"

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    if cacheFlag & CacheFlag.CACHE_FAMILIARS then
        player:CheckFamiliar(MAMA_HAUNT_VARIANT, player:GetCollectibleNum(MAMA_HAUNT) + player:GetEffects():GetCollectibleEffectNum(MAMA_HAUNT), player:GetCollectibleRNG(MAMA_HAUNT), Isaac.GetItemConfig():GetCollectible(MAMA_HAUNT), MAMA_HAUNT_SUBTYPE)
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval)

---@param familiar EntityFamiliar
local function onFamiliarInit(_, familiar)
    if familiar.SubType == MAMA_HAUNT_SUBTYPE then
        if not familiar.IsFollower then
            familiar:AddToFollowers()
        end
        familiar:GetData().RESOULED______MAMAHAUNT_COOLDOWN = 0
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onFamiliarInit, MAMA_HAUNT_VARIANT)

---@param familiar EntityFamiliar
local function onFamiliarUpdate(_, familiar)
    if familiar.SubType == MAMA_HAUNT_SUBTYPE then
        local data = familiar:GetData()
        local sprite = familiar:GetSprite()

        familiar:FollowParent()

        if sprite:IsEventTriggered(ANIMATION_TRIGGER_PETRIFY) then
            Resouled.Iterators:IterateOverRoomNpcs(function(npc)
                if npc:IsVulnerableEnemy() and npc:IsActiveEnemy() then
                    npc:AddFreeze(EntityRef(familiar), SING_PETRIFY_DURATION)
                end
            end)
        end

        if sprite:IsFinished(ANIMATION_SING) then
            sprite:Play(ANIMATION_IDLE, true)
            data.RESOULED______MAMAHAUNT_COOLDOWN = SING_PETRIFY_COOLDOWN
        end

        if data.RESOULED______MAMAHAUNT_COOLDOWN > 0 then
            data.RESOULED______MAMAHAUNT_COOLDOWN = data.RESOULED______MAMAHAUNT_COOLDOWN - 1
        end

        if Isaac.CountEnemies() > 0 and data.RESOULED______MAMAHAUNT_COOLDOWN == 0 and not sprite:IsPlaying(ANIMATION_SING) then
            sprite:Play(ANIMATION_SING, true)
        end

        if sprite:IsEventTriggered("Note") then
            local offset = sprite:GetNullFrame("NotePos"):GetPos()

            local note = Game():Spawn(EntityType.ENTITY_EFFECT, Note.Variant, familiar.Position, Vector.Zero, nil, Note.SubType, familiar.InitSeed)

            note.SpriteOffset = offset
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onFamiliarUpdate, MAMA_HAUNT_VARIANT)