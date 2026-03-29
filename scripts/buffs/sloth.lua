local DOOR_OPEN_TIME = 900

local doorsOpened = false
local timer = 0

local doorBlacklist = {
    [DoorVariant.DOOR_HIDDEN] = true,
    [DoorVariant.DOOR_LOCKED] = true,
    [DoorVariant.DOOR_LOCKED_BARRED] = true,
    [DoorVariant.DOOR_LOCKED_CRACKED] = true,
    [DoorVariant.DOOR_LOCKED_DOUBLE] = true,
    [DoorVariant.DOOR_LOCKED_GREED] = true,
    [DoorVariant.DOOR_LOCKED_KEYFAMILIAR] = true
}

local function postNewRoom()
    timer = DOOR_OPEN_TIME
    doorsOpened = false
end

local function onUpdate()
    if doorsOpened then return end

    timer = math.max(timer - 1, 0)
    if timer == 0 then

        local room = Resouled.Game:GetRoom()
        for i = DoorSlot.LEFT0, DoorSlot.NUM_DOOR_SLOTS do
            local door = room:GetDoor(i)
            if door then
                if not door:IsOpen() and not doorBlacklist[door:GetVariant()] then
                    door:Open()
                end
            end
        end
        doorsOpened = true
    end
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.SLOTH, {
    {
        Function = postNewRoom,
        CallbackID = ModCallbacks.MC_POST_NEW_ROOM
    },
    {
        Function = onUpdate,
        CallbackID = ModCallbacks.MC_POST_UPDATE
    }
})

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.SLOTH, true)