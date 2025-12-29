---@class ModReference
Resouled = RegisterMod("Resouled", 1)

if REPENTOGON and MinimapAPI then
    local thingsToRunAfterImports = {}

    include("scripts.callbacks")

    --- Does not pass any parameters
    ---@param func function
    function Resouled:RunAfterImports(func)
        table.insert(thingsToRunAfterImports, func)
    end

    -- ALL EXTERNAL IMPORTS

    ---@type SaveManager
    Resouled.SaveManager = include("scripts.utility.save_manager")
    Resouled.SaveManager.Init(Resouled)

    include("scripts.utility.status_effect_library")

    ---@type ResouledSave
    Resouled.Save = include("scripts.utility.resouled.save")

    ---@type AccurateStatsModule
    Resouled.AccurateStats = include("scripts.utility.accurate_stats")

    ---@type DoorsModule
    Resouled.Doors = include("scripts.utility.doors")

    ---@type IteratorsModule
    Resouled.Iterators = include("scripts.utility.iterators")

    ---@type CollectiblextensionModule
    Resouled.Collectiblextension = include("scripts.utility.collectiblextension")

    ---@type FamiliarModule
    Resouled.Familiar = include("scripts.utility.familiars")

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

    ---@type PlayerModule
    Resouled.Player = include("scripts.utility.player")

    include("scripts.utility.throwableitemlib").Init()

    include("scripts.stats")

    -- ALL MODULES UNIQUE TO RESOULED

    --if EID then
    --    ---@type ResouledEID
    --    Resouled.EID = include("scripts.utility.resouled.eid_functions")
    --end
    
    ---@type ResouledEID
    Resouled.EID = include("scripts.utility.resouled.eid")
    include("scripts.utility.resouled.misc")
    include("scripts.utility.resouled.buffs")
    include("scripts.utility.resouled.souls")
    include("scripts.utility.resouled.tear_effects")
    include("scripts.utility.resouled.curses")
    include("scripts.utility.resouled.room_events")
    include("scripts.utility.resouled.stat_tracker")


    ---@type ResouledEnums
    Resouled.Enums = include("scripts.utility.resouled.enums")

    --- ALL RESOULED SCRIPTS

    include("scripts.menu")
    include("scripts.character_start")
    include("scripts.status_effects")
    include("scripts.items")
    include("scripts.effects")
    include("scripts.curses")
    include("scripts.challenges")
    include("scripts.pickups")
    include("scripts.room_events")
    include("scripts.souls")
    include("scripts.buffs")
    include("scripts.entities")
    include("scripts.afterlife_shop")
    include("scripts.other")
    include("scripts.special_seed_effects")
    include("scripts.shaders")
    include("scripts.starting_items")
    include("scripts.shenanigans")
    include("scripts.social_goals")

    for _, func in ipairs(thingsToRunAfterImports) do
        func()
    end
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
            font:DrawStringScaled(message, player0position.X + initOffset.X,
                player0position.Y + initOffset.Y + i * diffOffset.Y, scale.X, scale.Y, color, boxWidth, center)
        end
    end)
end
