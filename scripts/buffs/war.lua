---@param bomb EntityBomb
local function postBombInit(_, bomb)
    if Resouled:BuffPresent(Resouled.Buffs.WAR) and Resouled:TryFindPlayerSpawner(bomb) then
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, postBombInit)