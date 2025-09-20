local EMPTY_GRID_REPLACE_CHANCE = 0.7

local EFFECT_SPRITE = Resouled:CreateLoadedSprite("gfx/ui/spider_webs_room_event.anm2", "Idle")
local EFFECT_WIDTH_HEIGHT = 26

local renderWeb = false

local function onRoomEnter()
    local room = Game():GetRoom()
    local rng = RNG(Game():GetRoom():GetSpawnSeed(), 21)
    if not Resouled:RoomEventPresent(Resouled.RoomEvents.SPIDER_WEBS) then
        renderWeb = false
        return
    else
        renderWeb = true
        EFFECT_SPRITE:SetFrame(rng:RandomInt(3)) -- frames 0, 1, 2 are different variations of the effect
        local randomOnScreenPos = Vector(rng:RandomInt(Isaac.GetScreenWidth()), rng:RandomInt(Isaac.GetScreenHeight()))
        local scale = randomOnScreenPos / (2 * EFFECT_WIDTH_HEIGHT)
        EFFECT_SPRITE.Scale = scale
        EFFECT_SPRITE.Offset = randomOnScreenPos
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
    if not renderWeb then return end

    local screenSize = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())
    EFFECT_SPRITE:Render(Vector.Zero)
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)
