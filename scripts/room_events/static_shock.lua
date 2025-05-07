---@param player EntityPlayer
local function onActiveUse(_, type, rng, player)
    if Resouled:RoomEventPresent(Resouled.RoomEvents.STATIC_SHOCK) then
        player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 1)
        SFXManager():Play(SoundEffect.SOUND_REDLIGHTNING_ZAP)
        Game():Darken(1, 2)
    end
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse)