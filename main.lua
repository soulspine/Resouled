---@class ModReference
Resouled = RegisterMod("Resouled", 1)

if REPENTOGON then
    ---@type SaveManager
    SAVE_MANAGER = include("scripts.utility.save_manager")
    SAVE_MANAGER.Init(Resouled)

    include("scripts.utility.resouled")

    include("scripts.character_start")
    include("scripts.items")
    include("scripts.pocketitems")
    include("scripts.effects")
    include("scripts.curses")
    include("scripts.enemies")
    include("scripts.challenges")
    include("scripts.pickups")

else
    local noRepentogonMessage1 = "Please enable REPENTOGON script extender and"
    local noRepentogonMessage2 = "restart your game to enable Resouled"
    local offset1 = Vector(0, -50)
    local offset2 = Vector(0, -30)
    local scale = Vector(1, 1)
    local color = KColor(1, 0, 0, 1)
    local boxWidth = 10
    local center = true
    local font = Font()
    font:Load("font/terminus.fnt")

    Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function()
        local player0position = Isaac.WorldToScreen(Isaac.GetPlayer().Position) 
        font:DrawStringScaled(noRepentogonMessage1, player0position.X + offset1.X, player0position.Y + offset1.Y, scale.X, scale.Y, color, boxWidth, center)
        font:DrawStringScaled(noRepentogonMessage2, player0position.X + offset2.X, player0position.Y + offset2.Y, scale.X, scale.Y, color, boxWidth, center)
    end)
end