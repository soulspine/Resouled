---@class ModReference
Resouled = RegisterMod("Resouled", 1)

if REPENTOGON and MinimapAPI then

    -- ALL EXTERNAL IMPORTS

    ---@type SaveManager
    SAVE_MANAGER = include("scripts.utility.save_manager")
    SAVE_MANAGER.Init(Resouled)

    ---@type AccurateStatsModule
    Resouled.AccurateStats = include("scripts.utility.accurate_stats")

    ---@type DoorsModule
    Resouled.Doors = include("scripts.utility.doors")

    ---@type IteratorsModule
    Resouled.Iterators = include("scripts.utility.iterators")

    ---@type CollectiblextensionModule
    Resouled.Collectiblextension = include("scripts.utility.collectiblextension")

    ---@type FamiliarTargetingModule
    Resouled.FamiliarTargeting = include("scripts.utility.familiar_targeting")

    ---@type NpcHaloModule
    Resouled.NpcHalo = include("scripts.utility.npc_halo")

    ---@type VectorModule
    Resouled.Vector = include("scripts.utility.vector")

    ---@type PullingModule
    Resouled.Pulling = include("scripts.utility.pulling")

    ---@type PricesModule
    Resouled.Prices = include("scripts.utility.prices")

    ---@type ProceduralMaxChargeModule
    Resouled.ProceduralMaxCharge = include("scripts.utility.procedural_max_charge")


    -- ALL MODULES UNIQUE TO RESOULED

    include("scripts.utility.resouled.buffs")
    include("scripts.utility.resouled.souls")
    include("scripts.utility.resouled.tear_effects")
    include("scripts.utility.resouled.curses")
    include("scripts.utility.resouled.misc")
    include("scripts.utility.resouled.room_events")


    --- ALL RESOULED SCRIPTS

    include("scripts.character_start")
    include("scripts.items")
    include("scripts.pocketitems")
    include("scripts.effects")
    include("scripts.curses")
    include("scripts.enemies")
    include("scripts.challenges")
    include("scripts.pickups")
    include("scripts.room_events")
    include("scripts.souls")

else -- REPENTOGON AND MINIMAPI NOT FOUND
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