local mod = Resouled
local SoulCatcher = {}
local callbacksActive = false


local Soul = Resouled.Stats.Soul
local CHANCE_TO_DUPLICATE = 0.15


---@param pickup EntityPickup
function SoulCatcher:postPickupInit(pickup)
    if pickup.SubType == Soul.SubType then
        local rng = RNG(pickup.InitSeed)
        if rng:RandomFloat() < CHANCE_TO_DUPLICATE then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, Soul.Variant, Soul.SubType, pickup.Position, -pickup.Velocity, nil)
        end
    end
end


function SoulCatcher:postGameEnd()
    if Resouled:GetPossessedSoulsNum() >= 30 then
        Resouled.AfterlifeShop:AddSpecialBuffToSpawn(Resouled.Buffs.SOUL_CATCHER)
    end

    if Resouled:ActiveBuffPresent(Resouled.Buffs.SOUL_CATCHER) then
        Resouled:RemoveActiveBuff(Resouled.Buffs.SOUL_CATCHER)
        SoulCatcher:RemoveCallbacks()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, SoulCatcher.postGameEnd)


function SoulCatcher:AddCallbacks()
    if not callbacksActive then
        mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, SoulCatcher.postPickupInit, Soul.Variant)
        callbacksActive = true
    end
end


function SoulCatcher:RemoveCallbacks()
    if callbacksActive then
        mod:RemoveCallback(ModCallbacks.MC_POST_PICKUP_INIT, SoulCatcher.postPickupInit)
        callbacksActive = false
    end
end


mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.LATE, function()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.SOUL_CATCHER) then
        SoulCatcher:AddCallbacks()
    end
end)


mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
    SoulCatcher:RemoveCallbacks()
end)

Resouled:AddBuffDescription(Resouled.Buffs.SOUL_CATCHER, Resouled.EID:AutoIcons("15% chance to spawn another soul on spawn (obtained by ending the run with 30+ souls)"))