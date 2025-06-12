local HAND_ME_DOWNS = Isaac.GetTrinketIdByName("Hand me Downs")

if EID then
    EID:addTrinket(HAND_ME_DOWNS, "Familairs have a 10% chance to inherit your tear effects")
end

local EFFECT_APPLY_CHANCE = 0.1

---@param tear EntityTear
local function postFamiliarFireTear(_, tear)
    local player = Resouled:TryFindPlayerSpawner(tear)
    if player then
        if player:HasTrinket(HAND_ME_DOWNS) then
            local randomNum = math.random()
            if randomNum < EFFECT_APPLY_CHANCE then
                tear:AddTearFlags(player.TearFlags)
                tear:SetDeadEyeIntensity(player:GetDeadEyeCharge())
                tear:Update()
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_PROJECTILE, postFamiliarFireTear)