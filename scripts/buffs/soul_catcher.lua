local Soul = Resouled.Stats.Soul
local CHANCE_TO_DUPLICATE = 0.15


---@param pickup EntityPickup
local function postPickupInit(pickup)
    if pickup.SubType == Soul.SubType then
        local rng = RNG(pickup.InitSeed)
        if rng:RandomFloat() < CHANCE_TO_DUPLICATE then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, Soul.Variant, Soul.SubType, pickup.Position, -pickup.Velocity, nil)
        end
    end
end


local function postGameEnd()
    if Resouled:GetPossessedSoulsNum() >= 30 then
        Resouled.AfterlifeShop:AddSpecialBuffToSpawn(Resouled.Buffs.SOUL_CATCHER)
    end
end

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.SOUL_CATCHER, true)

Resouled:AddBuffCallbackConfig(Resouled.Buffs.SOUL_CATCHER, {
    {
        CallbackID = ModCallbacks.MC_POST_PICKUP_INIT,
        Function = postPickupInit
    },
    {
        CallbackID = ModCallbacks.MC_POST_GAME_END,
        Function = postGameEnd,
        Priority = CallbackPriority.IMPORTANT
    }
})