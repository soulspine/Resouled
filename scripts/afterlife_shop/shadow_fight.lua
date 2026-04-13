local g = Resouled.Game

Resouled.AfterlifeShop.ShadowFight = {

    Active = false,
    Backdrop = Isaac.GetBackdropIdByName("Resouled Shadow Fight"),
    LevelName = "Purgatory",
    FootprintColor = KColor(0, 0, 0, 0),

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
    local save = Resouled.SaveManager.GetRunSave()
    save.IsShadowFight = true

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
    Isaac.ExecuteCommand("stage 13")

    config.CurrentOverlayTimout = config.MaxOverlayEndTimout

    Resouled:RemoveCallback(ModCallbacks.MC_POST_UPDATE, config.RoomTransitionFunctions.Start.OverlayScreenUpdate)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.Start.OverlayScreenRender)

    Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.Middle.OverlayScreen)
    Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, config.RoomTransitionFunctions.End.Start)

    config.Active = true

    Isaac.ExecuteCommand("goto d.1")
end

local blackColor = KColor(0, 0, 0, 1)
function config.RoomTransitionFunctions.Middle.OverlayScreen()
    Resouled:OverlayScreen(blackColor)
end

function config.RoomTransitionFunctions.End.Start()
    local room = g:GetRoom()
    local level = g:GetLevel()
    level:SetName(Resouled.AfterlifeShop.ShadowFight.LevelName)
    room:SetBackdropType(Resouled.AfterlifeShop.ShadowFight.Backdrop, 1)

    Resouled.Iterators:IterateOverPlayers(function(player)
        player:AnimateAppear()
        player:SetFootprintColor(Resouled.AfterlifeShop.ShadowFight.FootprintColor)
        player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    end)

    ---@param pickup EntityPickup
    Resouled.Iterators:IterateOverRoomPickups(function(pickup)
        pickup:Remove()
    end)

    ---@param effect EntityEffect
    Resouled.Iterators:IterateOverRoomEffects(function(effect)
        effect:Remove()
    end)

    local camera = room:GetCamera()
    camera:SetClampEnabled(false)

    local roomDesc = level:GetCurrentRoomDesc()
    roomDesc.Flags = roomDesc.Flags | RoomDescriptor.FLAG_NO_WALLS

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

local function removeAllEnterCallbacks()
    Resouled:RemoveCallback(ModCallbacks.MC_POST_UPDATE, config.RoomTransitionFunctions.Start.OverlayScreenUpdate)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.Start.OverlayScreenRender)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.Middle.OverlayScreen)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_UPDATE, config.RoomTransitionFunctions.End.OverlayScreenUpdate)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.End.OverlayScreenRender)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, config.RoomTransitionFunctions.End.Start)
end

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    removeAllEnterCallbacks()
    Resouled.AfterlifeShop.ShadowFight.Active = false
    local save = Resouled.SaveManager.GetRunSave()
    if save.IsShadowFight then
        Resouled.Game:FinishChallenge()
    end
end)

Resouled:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
    if Resouled.AfterlifeShop.ShadowFight.Active then
        Resouled.Game:GetRoom():GetCamera():SetClampEnabled(true)
    end
end)

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, function()
    config.CurrentOverlayTimout = 0
    config.Active = false
end)

Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    local level = Resouled.Game:GetLevel()
    if level:GetName() == Resouled.AfterlifeShop.ShadowFight.LevelName and not Resouled.AfterlifeShop.ShadowFight.Active then
        level:SetName("")
    end
end)

local z = 0
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    local room = g:GetRoom()
    local pos = room:GetCenterPos()
    local playerPos = Isaac.GetPlayer().Position
    Resouled:SetFogPos(pos + Vector(z, 0))
    z = z + 1
    local camera = room:GetCamera()

    local x = (playerPos - pos)
    --camera:SetFocusPosition(Resouled:GetFogCenterPos() + x * 0.75)
    --camera:SetClampEnabled(false)
end)

include("scripts.afterlife_shop.shadow_fight.grass")