---@param entity Entity
---@param amount number
---@param flags integer
---@param source EntityRef
---@param countdown integer
local function onPlayerHit(_, entity, amount, flags, source, countdown)
    local player = entity:ToPlayer()
    if not entity:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then
        if player and Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_PAIN) and flags & DamageFlag.DAMAGE_FAKE == 0 then
            if Resouled:GetEffectiveBlackHP(player) > 0 then
                player:AddBlackHearts(-1)
            elseif Resouled:GetEffectiveBlackHP(player) <= 0 and Resouled:GetEffectiveSoulHP(player) > 0 then
                player:AddSoulHearts(-1)
            elseif Resouled:GetEffectiveBlackHP(player) <= 0 and Resouled:GetEffectiveSoulHP(player) <= 0 and Resouled:GetEffectiveRedHP(player) > 0 then
                player:AddHearts(-1)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onPlayerHit, EntityType.ENTITY_PLAYER)