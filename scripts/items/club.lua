local ID = Isaac.GetItemIdByName("Club")

local WEAPON_TYPE = WeaponType.WEAPON_KNIFE
local WEAPON_SLOT = 0 --things like urn of souls

---@param player EntityPlayer
local function onUseItem(_, _, _, player)
    local weapon = player:GetWeapon(0)

    if not weapon then
        local newWeapon = Isaac.CreateWeapon(WEAPON_TYPE, player)
        player:SetWeapon(newWeapon, WEAPON_SLOT)
        player:EnableWeaponType(WEAPON_TYPE, true)
        return
    end

    local weaponType = weapon:GetWeaponType()
    if weaponType ~= WEAPON_TYPE then
        local newWeapon = Isaac.CreateWeapon(WEAPON_TYPE, player)
        player:SetWeapon(newWeapon, WEAPON_SLOT)
        player:EnableWeaponType(WEAPON_TYPE, true)
        return
    end

    if weaponType == WEAPON_TYPE then
        Isaac.DestroyWeapon(weapon)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, onUseItem, ID)