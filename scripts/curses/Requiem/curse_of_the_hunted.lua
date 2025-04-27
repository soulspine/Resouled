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