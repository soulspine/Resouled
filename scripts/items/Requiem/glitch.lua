local GLITCH = Isaac.GetItemIdByName("Glitch")

---@param entity Entity
---@param amount integer
---@param damageFlags DamageFlag
---@param entityRef EntityRef
---@param countdownFrames boolean
local function onHit(_, entity, amount, damageFlags, entityRef, countdownFrames)
    if entity:ToPlayer():HasCollectible(GLITCH) then
        entity:ToPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_D4, UseFlag.USE_NOANIM)
        SFXManager():Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 0, false, 1, 0)
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onHit, EntityType.ENTITY_PLAYER)