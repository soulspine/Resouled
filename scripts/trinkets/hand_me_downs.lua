local HAND_ME_DOWNS = Isaac.GetTrinketIdByName("Hand me Downs")

if EID then
    EID:addTrinket(HAND_ME_DOWNS, "Familairs have a 10% chance to inherit your tear effects")
end

local EFFECT_APPLY_CHANCE = 0.5--0.1

---@param tear EntityTear
local function postTearInit(_, tear)
    local player = Resouled:TryFindPlayerSpawnerIfEntityFamiliar(tear)
    if player then
        if player:HasTrinket(HAND_ME_DOWNS) then
            local randomNum = math.random()
            if randomNum < EFFECT_APPLY_CHANCE then
                local newTear = player:FireTear(tear.Position, tear.Velocity, true, false, false, tear.SpawnerEntity)
                newTear.CollisionDamage = tear.CollisionDamage
                tear:Remove() -- remove the original tear
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, postTearInit)