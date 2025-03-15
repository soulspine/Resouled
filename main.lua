---@class ModReference
Resouled = RegisterMod("Resouled", 1)

---@enum ResouledSouls
ResouledSouls = {
    MONSTRO = "Monstro's Soul",
    DUKE = "Duke's Soul",
}

include("scripts.utility.hud_helper")

---@type SaveManager
SAVE_MANAGER = include("scripts.utility.save_manager")
SAVE_MANAGER.Init(Resouled)

include("scripts.utility.resouled")

include("scripts.items")
include("scripts.pocketitems")
include("scripts.curses")
include("scripts.enemies")
include("scripts.challenges")
include("scripts.pickups")