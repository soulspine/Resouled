local EMPTY_GRID_REPLACE_CHANCE = 0.7

local EFFECT_SPRITE = Resouled:CreateLoadedSprite("gfx_resouled/ui/spider_webs_room_event.anm2", "Idle")
EFFECT_SPRITE.Color = Color(1, 1, 1, 0, 0, 0, 0)
local EFFECT_WIDTH_HEIGHT = 238
local EFFECT_ALPHA = 0.67
local EFFECT_ALPHA_STEP = 0.03

local renderWeb = nil
local webPos = Vector.Zero

local function onRoomEnter()
    local room = Game():GetRoom()
    local rng = RNG(Game():GetRoom():GetSpawnSeed(), 21)
    if not Resouled:RoomEventPresent(Resouled.RoomEvents.SPIDER_WEBS) then
        renderWeb = false
        return
    else
        renderWeb = true
        webPos = Vector(rng:RandomFloat(), rng:RandomFloat()) -- this is percentage of screen from top left
    end

    if not room:IsFirstVisit() then return end

    Resouled.Iterators:IterateOverGrid(function(gridEntity, index)
        if gridEntity then return end

        if rng:RandomFloat() < EMPTY_GRID_REPLACE_CHANCE then
            room:SpawnGridEntity(index, GridEntityType.GRID_SPIDERWEB, nil, Resouled:NewSeed())
        end
    end)
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, onRoomEnter)

local function onRender()
    if not renderWeb and EFFECT_SPRITE.Color.A == 0 then return end

    local newAlpha = EFFECT_SPRITE.Color.A

    if renderWeb then
        newAlpha = math.min(EFFECT_ALPHA, newAlpha + EFFECT_ALPHA_STEP)
    else
        newAlpha = math.max(0, newAlpha - EFFECT_ALPHA_STEP)
    end

    local screenSize = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())

    EFFECT_SPRITE.Scale = Vector(screenSize.X, screenSize.Y) / EFFECT_WIDTH_HEIGHT * 2
    EFFECT_SPRITE.Color.A = newAlpha
    local renderPos = webPos * screenSize

    EFFECT_SPRITE:Render(renderPos)
end
Resouled:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, onRender)
