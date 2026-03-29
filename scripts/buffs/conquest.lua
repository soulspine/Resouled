local function postTriggerRoomClear()
    if Resouled.Game:GetRoom():GetType() ~= RoomType.ROOM_BOSS then return end

    Resouled.SaveManager.GetRunSave().ConquestBuff = true
end

---@param wisp EntityFamiliar
local function hideWisp(wisp)
    wisp.OrbitDistance = Vector(0, 0)
    wisp.OrbitSpeed = 0
    wisp.OrbitAngleOffset = 0
    wisp.HitPoints = 0.01
    wisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    wisp.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    wisp:GetSprite():Load("gfx/bullshit.nothing", true)
end

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local save = Resouled.SaveManager.GetRunSave()
    local idx = tostring(player:GetPlayerIndex())
    if (not save.ConquestBuffWisps or not save.ConquestBuffWisps[idx]) and Resouled.SaveManager.GetRunSave().ConquestBuff then
        local wisp = player:AddItemWisp(CollectibleType.COLLECTIBLE_MERCURIUS, player.Position)

        hideWisp(wisp)

        if not save.ConquestBuffWisps then
            save.ConquestBuffWisps = {}
        end
        save.ConquestBuffWisps[idx] = EntityRef(wisp)
    end
end

local function preGameExit()
    Resouled.Iterators:IterateOverRoomFamiliars(function(fam)
        if fam:GetSprite():GetFilename() == "gfx/bullshit.nothing" then
            fam:Kill()
        end
    end)
end

local function postNewLevel()
    local save = Resouled.SaveManager.GetRunSave()
    save.ConquestBuff = nil
    save.ConquestBuffWisps = nil

    Resouled.Iterators:IterateOverRoomFamiliars(function(fam)
        if fam:GetSprite():GetFilename() == "gfx/bullshit.nothing" then
            fam:Kill()
        end
    end)
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.CONQUEST, {
    {
        CallbackID = ModCallbacks.MC_POST_NEW_LEVEL,
        Function = postNewLevel
    },
    {
        CallbackID = ModCallbacks.MC_PRE_GAME_EXIT,
        Function = preGameExit
    },
    {
        CallbackID = ModCallbacks.MC_POST_PLAYER_TRIGGER_ROOM_CLEAR,
        Function = postTriggerRoomClear
    },
    {
        CallbackID = ModCallbacks.MC_POST_PLAYER_UPDATE,
        Function = onPlayerUpdate
    }
})

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.CONQUEST, true)