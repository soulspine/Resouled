local BLACK_EGG = Isaac.GetEntitySubTypeByName("Black Proglottid Egg")
local WHITE_EGG = Isaac.GetEntitySubTypeByName("White Proglottid Egg")
local RED_EGG = Isaac.GetEntitySubTypeByName("Red Proglottid Egg")
local PINK_EGG = Isaac.GetEntitySubTypeByName("Pink Proglottid Egg")

local Egg = {
    Variant = Isaac.GetEntityVariantByName("Black Proglottid Egg"),
    SubType = {[BLACK_EGG] = true, [WHITE_EGG] = true, [RED_EGG] = true, [PINK_EGG] = true},
    StartFallSpeed = -8,
    FallSpeedToLosePerUpdate = 0.25,
    Damage = 7.5,
    ExplosionDamage = 50,
    StartOffset = Vector(0, -20),
    SpriteRotation = 15,
}

local breakEffects = {
    ---@param familiar EntityFamiliar
    ---@param npc? EntityNPC
    [BLACK_EGG] = function(familiar, npc)
        if npc then
            local data = npc:GetData()
            
            data.Resouled_ProglottidEggBlack = true
        end
    end,
    ---@param familiar EntityFamiliar
    ---@param npc? EntityNPC
    [WHITE_EGG] = function(familiar, npc)
        if npc then
            local data = npc:GetData()
            
            data.Resouled_ProglottidEggWhite = true
        end
    end,
    ---@param familiar EntityFamiliar
    ---@param npc? EntityNPC
    [RED_EGG] = function(familiar, npc)
        if npc then
            local data = npc:GetData()
            
            data.Resouled_ProglottidEggRed = true
        end
    end,
    ---@param familiar EntityFamiliar
    ---@param npc? EntityNPC
    [PINK_EGG] = function(familiar, npc)
        if npc then
            local data = npc:GetData()
            
            data.Resouled_ProglottidEggPink = true
        end
    end
}

---@param familiar EntityFamiliar
local function Break(familiar)
    breakEffects[familiar.SubType](familiar)
    familiar:Remove()
end

---@param familiar EntityFamiliar
local function onFamiliarInit(_, familiar)
    if Egg.SubType[familiar.SubType] then
        local subType = familiar.SubType
        local sprite = familiar:GetSprite()

        if subType == BLACK_EGG then
            sprite:ReplaceSpritesheet(0, "gfx/familiar/black_egg.png", true)
        elseif subType == WHITE_EGG then
            sprite:ReplaceSpritesheet(0, "gfx/familiar/white_egg.png", true)
        elseif subType == PINK_EGG then
            sprite:ReplaceSpritesheet(0, "gfx/familiar/pink_egg.png", true)
        elseif subType == RED_EGG then
            sprite:ReplaceSpritesheet(0, "gfx/familiar/red_egg.png", true)
        end

        sprite:Play("Idle", true)

        local data = familiar:GetData()
        data.Resouled_ProglottidEgg = {
            Offset = Egg.StartOffset,
            FallSpeed = Egg.StartFallSpeed
        }
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onFamiliarInit, Egg.Variant)

---@param familiar EntityFamiliar
local function onFamiliarUpdate(_, familiar)
    if Egg.SubType[familiar.SubType] then
        local entities = Isaac.FindInRadius(familiar.Position, familiar.Size, EntityPartition.ENEMY)
        for _, entity in ipairs(entities) do
            if entity:IsEnemy() and entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then
                entity:TakeDamage(Egg.Damage, DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(familiar), 0)
            end
            Break(familiar, entity:ToNPC())
        end

        local data = familiar:GetData()
        if data.Resouled_ProglottidEgg then
            if data.Resouled_ProglottidEgg.Offset.Y + data.Resouled_ProglottidEgg.FallSpeed >= 0 then
                Break(familiar)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onFamiliarUpdate, Egg.Variant)

---@param familiar EntityFamiliar
local function preFamiliarRender(_, familiar)
    if Egg.SubType[familiar.SubType] then
        local data = familiar:GetData()
        if not Game():IsPaused() then
            if data.Resouled_ProglottidEgg then
                data.Resouled_ProglottidEgg.Offset.Y = data.Resouled_ProglottidEgg.Offset.Y + data.Resouled_ProglottidEgg.FallSpeed
                
                data.Resouled_ProglottidEgg.FallSpeed = data.Resouled_ProglottidEgg.FallSpeed + Egg.FallSpeedToLosePerUpdate
            end

            familiar.SpriteRotation = familiar.SpriteRotation + Egg.SpriteRotation
        end

        return data.Resouled_ProglottidEgg.Offset
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_RENDER, preFamiliarRender, Egg.Variant)