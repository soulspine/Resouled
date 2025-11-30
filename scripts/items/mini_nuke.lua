local MINI_NUKE = Isaac.GetItemIdByName("Mini Nuke")

local VARIANT = Isaac.GetEntityVariantByName("Mini Nuke")
local SUBTYPE = Isaac.GetEntitySubTypeByName("Mini Nuke")

local STARTING_HEIGHT = 3000
local FALLING_SPEED = 0.05

local Shadow = Sprite()
Shadow:Load("gfx_resouled/shadow.anm2", false)
Shadow:ReplaceSpritesheet(0, "resources/gfx_resouled/shadow.png", true)
Shadow:Play("Idle", true)

local MAX_SHADOW_ALPHA = 0.25
local MAX_SHADOW_SIZE = 0.5
local MIN_SHADOW_SIZE = 0.25

local DAMAGE = 999
local MAMA_MEGA_EXPLOSION_DAMAGE = 200

---@param pos Vector
local function spawnMiniNuke(pos)
    local nuke = Game():Spawn(EntityType.ENTITY_EFFECT, VARIANT, pos, Vector.Zero, nil, SUBTYPE, Random() + 1):ToEffect()
    if nuke then
        nuke:GetData().Resouled_MiniNuke = FALLING_SPEED
        nuke.SpriteOffset.Y = -STARTING_HEIGHT
    end
end

---@param effect EntityEffect
local function onEffectRender(_, effect)
    if effect.SubType == SUBTYPE then
        if not Game():IsPaused() then
            local data = effect:GetData()
            
            if not data.Resouled_MiniNuke then
                effect.SpriteOffset.Y = -STARTING_HEIGHT
                data.Resouled_MiniNuke = FALLING_SPEED
            end
        
            effect.SpriteOffset.Y = math.min(0, effect.SpriteOffset.Y + (data.Resouled_MiniNuke * data.Resouled_MiniNuke))
        
            data.Resouled_MiniNuke = data.Resouled_MiniNuke + FALLING_SPEED
        
            if effect.SpriteOffset.Y >= 0 then
                data.Resouled_MiniNukeDie = true
            end
        end

        local renderPos = Isaac.WorldToScreen(effect.Position)

        local scale = MIN_SHADOW_SIZE + ((-effect.SpriteOffset.Y)/STARTING_HEIGHT) * (MAX_SHADOW_SIZE - MIN_SHADOW_SIZE)
        Shadow.Scale = Vector(scale, scale)
        Shadow.Color.A = MAX_SHADOW_ALPHA * ((STARTING_HEIGHT + effect.SpriteOffset.Y)/STARTING_HEIGHT)

        Shadow:Render(renderPos)
        effect:GetSprite():Render(renderPos)

        return false
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, onEffectRender, VARIANT)

---@param effect EntityEffect
local function onEffectUpdate(_, effect)
    if effect.SubType == SUBTYPE then
        if effect:GetData().Resouled_MiniNukeDie then
            Game():GetRoom():MamaMegaExplosion(effect.Position)
            ---@param npc EntityNPC
            Resouled.Iterators:IterateOverRoomNpcs(function(npc)
                if npc:IsEnemy() and npc:IsActiveEnemy() then
                    npc:TakeDamage(DAMAGE - MAMA_MEGA_EXPLOSION_DAMAGE, DamageFlag.DAMAGE_EXPLOSION, EntityRef(nil), 0)
                end
            end)
            effect:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, onEffectUpdate, VARIANT)

---@param player EntityPlayer
---@param slot ActiveSlot
local function onActiveUse(_, _, _, player, slot)
    spawnMiniNuke(player.Position)
    player:RemoveCollectible(MINI_NUKE, nil, slot)
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, MINI_NUKE)