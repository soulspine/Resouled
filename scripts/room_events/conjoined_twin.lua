local THROW_POWER = 2.5

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    if Resouled:RoomEventPresent(Resouled.RoomEvents.CONJOINED_TWIN) then
        if npc:IsEnemy() then
            ---@param player EntityPlayer
            Resouled.Iterators:IterateOverPlayers(function(player)
                player.Velocity = player.Velocity + (Vector(1, 0):Rotated(math.random(0, 360)) * THROW_POWER)
            end)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath)