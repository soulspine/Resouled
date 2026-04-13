local around = {
    Vector(-1, -1),
    Vector(0, -1),
    Vector(1, -1),
    Vector(1, 0),
    Vector(1, 1),
    Vector(0, 1),
    Vector(-1, 1),
    Vector(-1, 0),
    
    Vector(-1, -2),
    Vector(0, -2),
    Vector(1, -2),

    Vector(2, -1),
    Vector(2, 0),
    Vector(2, 1),

    Vector(-1, 2),
    Vector(0, 2),
    Vector(1, 2),

    Vector(-2, -1),
    Vector(-2, 0),
    Vector(-2, 1)
}

local TILES = {
    TopLeft = Vector(0, 0),
    Top = Vector(1, 0),
    TopRight = Vector(2, 0),
    Left = Vector(0, 1),
    Center = Vector(1, 1),
    Right = Vector(2, 1),
    BottomLeft = Vector(0, 2),
    Bottom = Vector(1, 2),
    BottomRight = Vector(2, 2),
    ConnectorBottomRight = Vector(3, 0),
    ConnectorBottomLeft = Vector(4, 0),
    ConnectorTopRight = Vector(3, 1),
    ConnectorTopLeft = Vector(4, 1)
}

local TILE_SIZE = Vector(16, 16)
--local GRASS_COLOR = KColor(20/255 * 2, 31.4/255 * 2, 24.7/255 * 2, 1)
local GRASS_COLOR = KColor(43.1/255 * 2, 43.1/255 * 2, 43.1/255 * 2, 1)

local rng = RNG()
local sprite = Sprite()
sprite:Load("gfx_resouled/misc/grass_tiles.anm2", true)
sprite:Play("Idle", true)
local layer = sprite:GetLayer(0)
if not layer then return end

---@param tile Vector
local function setTile(tile)
    layer:SetCropOffset(TILE_SIZE * tile)
end


local map = {}
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if true then return end
    Resouled:OverlayScreen(GRASS_COLOR)

    local startSeed = Resouled.Seeds:GetStartSeed()
    local startPos = Isaac.ScreenToWorld(Vector.Zero)
    local scrollOffset = Resouled.Game:GetRoom():GetRenderScrollOffset()/2
    local startOffset = startPos + scrollOffset
    startOffset.X = startOffset.X % TILE_SIZE.X
    startOffset.Y = startOffset.Y % TILE_SIZE.Y
    local startIdx = startPos + scrollOffset
    startIdx.X = (startIdx.X - (startIdx.X % TILE_SIZE.X))//(TILE_SIZE.X)
    startIdx.Y = (startIdx.Y - (startIdx.Y % TILE_SIZE.Y))//(TILE_SIZE.Y)

    local screen = Resouled.Screen()
    local pos = Vector.Zero

    for y = -10, math.ceil(screen.Y/TILE_SIZE.Y) + 9 do for x = -10, math.ceil(screen.X/TILE_SIZE.X) + 9 do
        
        local Y = startIdx.Y + y
        local X = startIdx.X + x
        if not map[Y] then map[Y] = {} end
        if not map[Y][X] then
            rng:SetSeed(math.max(startSeed + math.floor((startSeed/1000 * X * Y)) + 10 * X * Y, 1))
            map[Y][X] = rng:PhantomInt(10) == 0 and 1 or 0

            if map[Y][X] == 1 then
                for _, offset in ipairs(around) do
                    local Y2 = Y + offset.Y
                    local X2 = X + offset.X
                    
                    if not map[Y2] then map[Y2] = {} end
                    map[Y2][X2] = 1
                end
            end
        end

    end end



    for y = -1, math.ceil(screen.Y/TILE_SIZE.Y) do for x = -1, math.ceil(screen.X/TILE_SIZE.X) do

        local Y = startIdx.Y + y
        local X = startIdx.X + x

        if map[Y][X] == 1 then
            setTile(TILES.Center)

            local aroundTiles = {
                map[Y - 1][X - 1],
                map[Y - 1][X],
                map[Y - 1][X + 1],
                map[Y][X + 1],
                map[Y + 1][X + 1],
                map[Y + 1][X],
                map[Y + 1][X - 1],
                map[Y][X - 1]
            }
            local emptyCount = 0
            for _, val in ipairs(aroundTiles) do if val == 0 then emptyCount = emptyCount + 1 end end
            
            if (aroundTiles[2] == 1
            and aroundTiles[4] == 1
            and aroundTiles[6] == 0
            and aroundTiles[8] == 0)
            or
            (aroundTiles[2] == 1
            and aroundTiles[4] == 1
            and aroundTiles[6] == 1
            and aroundTiles[8] == 0
            and aroundTiles[5] == 0)
            or
            (aroundTiles[2] == 1
            and aroundTiles[4] == 1
            and aroundTiles[6] == 0
            and aroundTiles[8] == 1
            and aroundTiles[1] == 0) then setTile(TILES.BottomLeft)
            
            elseif (aroundTiles[2] == 0
            and aroundTiles[4] == 1
            and aroundTiles[6] == 1
            and aroundTiles[8] == 0)
            or
            (aroundTiles[2] == 1
            and aroundTiles[4] == 1
            and aroundTiles[6] == 1
            and aroundTiles[8] == 0
            and aroundTiles[3] == 0)
            or
            (aroundTiles[2] == 0
            and aroundTiles[4] == 1
            and aroundTiles[6] == 1
            and aroundTiles[8] == 1
            and aroundTiles[7] == 0) then setTile(TILES.TopLeft)
            
            elseif (aroundTiles[2] == 0
            and aroundTiles[4] == 0
            and aroundTiles[6] == 1
            and aroundTiles[8] == 1)
            or
            (aroundTiles[2] == 0
            and aroundTiles[4] == 1
            and aroundTiles[6] == 1
            and aroundTiles[8] == 1
            and aroundTiles[5] == 0)
            or
            (aroundTiles[2] == 1
            and aroundTiles[4] == 0
            and aroundTiles[6] == 1
            and aroundTiles[8] == 1
            and aroundTiles[1] == 0) then setTile(TILES.TopRight)
            
            elseif (aroundTiles[2] == 1
            and aroundTiles[4] == 0
            and aroundTiles[6] == 0
            and aroundTiles[8] == 1)
            or
            (aroundTiles[2] == 1
            and aroundTiles[4] == 1
            and aroundTiles[6] == 0
            and aroundTiles[8] == 1
            and aroundTiles[3] == 0)
            or
            (aroundTiles[2] == 1
            and aroundTiles[4] == 0
            and aroundTiles[6] == 1
            and aroundTiles[8] == 1
            and aroundTiles[7] == 0) then setTile(TILES.BottomRight)
            
            elseif aroundTiles[2] == 0
            and aroundTiles[4] == 1
            and aroundTiles[6] == 1
            and aroundTiles[8] == 1 then setTile(TILES.Top)
            
            elseif aroundTiles[2] == 1
            and aroundTiles[4] == 0
            and aroundTiles[6] == 1
            and aroundTiles[8] == 1 then setTile(TILES.Right)
            
            elseif aroundTiles[2] == 1
            and aroundTiles[4] == 1
            and aroundTiles[6] == 0
            and aroundTiles[8] == 1 then setTile(TILES.Bottom)
            
            elseif aroundTiles[2] == 1
            and aroundTiles[4] == 1
            and aroundTiles[6] == 1
            and aroundTiles[8] == 0 then setTile(TILES.Left)
            
            elseif emptyCount == 1
            and aroundTiles[1] == 0 then setTile(TILES.ConnectorTopLeft)
            
            elseif emptyCount == 1
            and aroundTiles[3] == 0 then setTile(TILES.ConnectorTopRight)
            
            elseif emptyCount == 1
            and aroundTiles[5] == 0 then setTile(TILES.ConnectorBottomRight)
            
            elseif emptyCount == 1
            and aroundTiles[7] == 0 then setTile(TILES.ConnectorBottomLeft) end

            sprite:Render(pos + TILE_SIZE * Vector(x, y) - startOffset)

        end

    end end
end)

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    map = {}
end)