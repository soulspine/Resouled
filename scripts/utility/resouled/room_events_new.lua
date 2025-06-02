---@enum ResouledRoomEvent
Resouled.RoomEvents = {
    ALL_HALLOWS_EVE = 1,
    ANGELIC_INTERVENTION = 2,
    BLACK_CHAMPIONS = 3,
    BLESSING_OF_GLUTTONY = 4,
    BLESSING_OF_GREED = 5,
    BLESSING_OF_THE_SACK = 6,
    BLOOD_LUST = 7,
    BUTTER_FINGERS = 8,
    RED_CHAMPIONS = 9,
    SHADOW_OF_WAR = 10,
    STATIC_SHOCK = 11,
    SPOILS_OF_WAR = 12,
    MAGGYS_BLESSING = 13,
    SAMSONS_BLESSING = 14,
    RED_VISE = 15,
    SPLASH_DAMAGE = 16,
    EDENS_BLESSING = 17,
    GREED_LOOMS = 18,
    TAX_FOR_THE_MIGHTY = 19,
    SHADOW_OF_FAMINE = 20,
    BLESSING_OF_STEAM = 21,
    BLESSING_OF_INNER_EYE = 22,
    CONJOINED_TWIN = 23,
    BLOOD_MONEY = 24,
    HEAVY_IS_THE_HEAD = 25,
    BLIND_RAGE = 26,
    EQUALITY = 27,
    ISAACS_BLESSING = 28,
}

---@class ResouledRoomEventDesc
---@field Id ResouledRoomEvent
---@field Name string
---@field Filters table

---@type table<string, ResouledRoomEventDesc>
local registeredRoomEvents = {}

---@param roomEvent ResouledRoomEvent
---@param name string
---@param filters table
---@return boolean
function Resouled:RegisterRoomEvent(roomEvent, name, filters)
    local roomEventKey = tostring(roomEvent)

    if not registeredRoomEvents[roomEventKey] then
        registeredRoomEvents[roomEventKey] = {
            Id = roomEvent,
            Name = name,
            Filters = filters,
        }

        return true
    end

    Resouled:LogError("Tried to register a roomEvent that was already registered: " .. roomEvent)
    return false
end

---@param roomEventID ResouledRoomEvent
---@return ResouledRoomEventDesc | nil
function Resouled:GetRoomEvent(roomEventID)
    local roomEvent = registeredRoomEvents[tostring(roomEventID)]
    if roomEvent then
        return roomEvent
    end
    return nil
end

---@param roomEventID  ResouledRoomEvent
---@return boolean
function Resouled:CheckFilters(roomEventID)
    local roomEvent = registeredRoomEvents[tostring(roomEventID)]
    for i = 1, #roomEvent.Filters do
        local filter = roomEvent.Filters[i]
        if filter() == false then
            return false
        end
    end
    return true
end

Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    print(Resouled:CheckFilters(Resouled.RoomEvents.ALL_HALLOWS_EVE))
end)