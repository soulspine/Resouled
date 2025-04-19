local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_SOULLESS]

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_SOULLESS)
    end,
    Resouled.CursesSprite,
    mapId,
    1
)