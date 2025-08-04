local mod = Resouled
local Death = {}
local callbacksActive = false


function Death:entityTakeDMG()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.DEATH) then
        ---@param npc EntityNPC
        Resouled.Iterators:IterateOverRoomNpcs(function(npc)
            if npc:IsActiveEnemy() and npc:IsEnemy() then
                npc:Die()
            end
        end)
        Resouled:RemoveActiveBuff(Resouled.Buffs.DEATH)
        Death:RemoveCallbacks()
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Death.entityTakeDMG, EntityType.ENTITY_PLAYER)


function Death:AddCallbacks()
    if not callbacksActive then
        mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Death.entityTakeDMG, EntityType.ENTITY_PLAYER)
        callbacksActive = true
    end
end


function Death:RemoveCallbacks()
    if callbacksActive then
        mod:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Death.entityTakeDMG)
        callbacksActive = false
    end
end


mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.LATE, function()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.DEATH) then
        Death:AddCallbacks()
    end
end)


mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
    Death:RemoveCallbacks()
end)

Resouled:AddBuffDescription(Resouled.Buffs.DEATH, Resouled.EID:AutoIcons("Kills all enemies in the room the first time you take damage"))