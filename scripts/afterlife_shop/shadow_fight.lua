local g = Game()

Resouled.AfterlifeShop.ShadowFight = {
    MaxOverlayEndTimout = 200,
    OverlayEndOffset = 550,
    MaxOverlayStartTimeout = 30
}
local config = Resouled.AfterlifeShop.ShadowFight

config.RoomTransitionFunctions = {}
config.RoomTransitionFunctions.Start = {} --Animation before entering the room
config.RoomTransitionFunctions.Middle = {} --Entering the room
config.RoomTransitionFunctions.End = {} --Entered the room

function config.RoomTransitionFunctions.Start.Begin()
    Resouled.Iterators:IterateOverPlayers(function(player)
        player:AnimateSad()
    end)

    config.CurrentOverlayTimout = config.MaxOverlayStartTimeout

    Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, config.RoomTransitionFunctions.Start.OverlayScreenUpdate)
    Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.Start.OverlayScreenRender)
end

function config.RoomTransitionFunctions.Start.OverlayScreenUpdate()
    config.CurrentOverlayTimout = math.max(config.CurrentOverlayTimout - 1, 0)
    if config.CurrentOverlayTimout == 0 then

        config.RoomTransitionFunctions.Middle.Enter()

        Resouled:RemoveCallback(ModCallbacks.MC_POST_UPDATE, config.RoomTransitionFunctions.Start.OverlayScreenUpdate)
    end
end

function config.RoomTransitionFunctions.Start.OverlayScreenRender()
    local x = config.MaxOverlayStartTimeout ^ 2
    Resouled:OverlayScreen(KColor(0, 0, 0, (x - config.CurrentOverlayTimout ^ 2)/x))
end

function config.RoomTransitionFunctions.Middle.Enter()
    config.CurrentOverlayTimout = config.MaxOverlayEndTimout

    Resouled:RemoveCallback(ModCallbacks.MC_POST_UPDATE, config.RoomTransitionFunctions.Start.OverlayScreenUpdate)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.Start.OverlayScreenRender)

    Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.Middle.OverlayScreen)
    Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, config.RoomTransitionFunctions.End.Start)
    Isaac.ExecuteCommand("goto d.124")
end

local blackColor = KColor(0, 0, 0, 1)
function config.RoomTransitionFunctions.Middle.OverlayScreen()
    Resouled:OverlayScreen(blackColor)
end

function config.RoomTransitionFunctions.End.Start()
    local room = g:GetRoom()
    local center = room:GetCenterPos()

    Resouled.Iterators:IterateOverPlayers(function(player)
        player.Position = center
        player:AnimateAppear()
    end)

    config.CurrentOverlayTimout = config.MaxOverlayEndTimout

    Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, config.RoomTransitionFunctions.End.OverlayScreenUpdate)
    Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.End.OverlayScreenRender)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.Middle.OverlayScreen)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, config.RoomTransitionFunctions.End.Start)
end

function config.RoomTransitionFunctions.End.OverlayScreenUpdate()
    config.CurrentOverlayTimout = math.max(config.CurrentOverlayTimout - 1, 0)
    if config.CurrentOverlayTimout == 0 then
        Resouled:RemoveCallback(ModCallbacks.MC_POST_UPDATE, config.RoomTransitionFunctions.End.OverlayScreenUpdate)
    end
end

function config.RoomTransitionFunctions.End.OverlayScreenRender()
    if not g:IsPaused() then
    local room = g:GetRoom()
    local camera = room:GetCamera()
    camera:SetFocusPosition(Isaac.GetPlayer().Position)
        camera:Update()
    end
    Resouled:OverlayScreen(KColor(0, 0, 0, ((config.CurrentOverlayTimout ^ 2) + config.OverlayEndOffset)/(config.MaxOverlayEndTimout ^ 2)))
    if config.CurrentOverlayTimout == 0 then
        Resouled:RemoveCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.End.OverlayScreenRender)
    end
end

function Resouled.AfterlifeShop:TeleportToShadowBossfight()
    config.RoomTransitionFunctions.Start.Begin()
end

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    config.CurrentOverlayTimout = 0
end)