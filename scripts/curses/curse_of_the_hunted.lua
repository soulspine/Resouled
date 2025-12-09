local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_THE_HUNTED]

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_THE_HUNTED)
    end,
    Resouled.CursesSprite,
    mapId,
    1
)

local CHANCE = 0.125

local function postNewRoom()
    local room = Game():GetRoom()
    if not Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_THE_HUNTED) or not room:IsClear() or room:GetType() == RoomType.ROOM_BOSS then return end

    if math.random() < CHANCE then
        room:SetClear(false)
        room:RespawnEnemies()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)