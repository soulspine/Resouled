---@class ModReference
Resouled = RegisterMod("Resouled", 1)

if REPENTOGON and MinimapAPI then
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
    local messages = {
        "Please enable REPENTOGON script extender,",
        "Install MiniMAPI: A Minimap API",
        "and restart your game to enable Resouled",
    }
    local initOffset = Vector(0, -50)
    local diffOffset = Vector(0, 15)
    local scale = Vector(1, 1)
    local color = KColor(1, 0, 0, 1)
    local boxWidth = 10
    local center = true
    local font = Font()
    font:Load("font/terminus.fnt")

    Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function()
        local player0position = Isaac.WorldToScreen(Isaac.GetPlayer().Position) 
        for i, message in ipairs(messages) do
            font:DrawStringScaled(message, player0position.X + initOffset.X, player0position.Y + initOffset.Y + i * diffOffset.Y, scale.X, scale.Y, color, boxWidth, center)
        end
    end)
end