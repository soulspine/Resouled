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



local MAP_SIZE = 32
local RENDER_SCALE = 50
local PIXEL_SIZE = RENDER_SCALE/MAP_SIZE
local OFFSET = Vector(PIXEL_SIZE/2, 0)
local THRESHOLD = 0.5
local RATIO = 5

---@param offset table {X, Y}
---@param currentIdx table {X, Y}
---@param gridSize integer
---@return table {X, Y}
local function getIdxFromOffset(offset, currentIdx, gridSize)
    local newIdx = {X = currentIdx.X + offset.X, Y = currentIdx.Y + offset.Y}

    while newIdx.X > gridSize do newIdx.X = newIdx.X - gridSize end
    while newIdx.X < 1 do newIdx.X = gridSize + newIdx.X end
    while newIdx.Y > gridSize do newIdx.Y = newIdx.Y - gridSize end
    while newIdx.Y < 1 do newIdx.Y = gridSize + newIdx.Y end

    return newIdx
end

local noise = {}
local noise2 = {}
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if true then return end
    

    -- initial noise
    if #noise < MAP_SIZE then
        
        for y = 1, MAP_SIZE do for x = 1, MAP_SIZE do
            
            if not noise[y] then noise[y] = {} end
            
            noise[y][x] = math.random()
            
        end end
    end

    local startPos = Resouled.Screen()/2 - (Vector(1, 1) * RENDER_SCALE/2)

    if #noise2 < MAP_SIZE then
        
        for y = 1, MAP_SIZE do for x = 1, MAP_SIZE do
            
            -- quant
            local idxAround = {
                getIdxFromOffset({X = 0, Y = -1}, {X = x, Y = y}, MAP_SIZE),
                getIdxFromOffset({X = -1, Y = 0}, {X = x, Y = y}, MAP_SIZE),
                getIdxFromOffset({X = 0, Y = 1}, {X = x, Y = y}, MAP_SIZE),
                getIdxFromOffset({X = 1, Y = 0}, {X = x, Y = y}, MAP_SIZE),
                getIdxFromOffset({X = 0, Y = 0}, {X = -math.floor((x - 1)/8), Y = -math.floor((y - 1)/8)}, MAP_SIZE)
            }
            
            local value =
                (noise[y][x]
                + noise[idxAround[1].Y][idxAround[1].X]
                + noise[idxAround[2].Y][idxAround[2].X]
                + noise[idxAround[3].Y][idxAround[3].X]
                + noise[idxAround[4].Y][idxAround[4].X]
            )/5
        
            value = (value * (RATIO - 1) + noise[idxAround[5].Y][idxAround[5].X])/RATIO
        
            value = -math.log(value, 5)
        
            value = value < THRESHOLD and 0 or 1
        
            if not noise2[y] then noise2[y] = {} end
            noise2[y][x] = value
        
        end end
        
        -- lowpass filter
        for y = 1, MAP_SIZE do for x = 1, MAP_SIZE do
            
            local idxAround = {
                getIdxFromOffset({X = 0, Y = -1}, {X = x, Y = y}, MAP_SIZE),
                getIdxFromOffset({X = -1, Y = 0}, {X = x, Y = y}, MAP_SIZE),
                getIdxFromOffset({X = 0, Y = 1}, {X = x, Y = y}, MAP_SIZE),
                getIdxFromOffset({X = 1, Y = 0}, {X = x, Y = y}, MAP_SIZE)
            }
            local valuesAround = {
                noise2[idxAround[1].Y][idxAround[1].X],
                noise2[idxAround[2].Y][idxAround[2].X],
                noise2[idxAround[3].Y][idxAround[3].X],
                noise2[idxAround[4].Y][idxAround[4].X]
            }
            local value = noise2[y][x]
            local differentValues = 0
            
            for i = 1, 4 do
                if valuesAround[i] ~= value then differentValues = differentValues + 1 end
            end
            
            if differentValues > 2 then noise2[y][x] = -value end
            
        end end
    end

    for y = 1, MAP_SIZE do for x = 1, MAP_SIZE do
        
        local value = noise2[y][x]
        local pos = startPos + Vector(PIXEL_SIZE * (x - 1), PIXEL_SIZE * (y - 1))
        local color = KColor(value, value, value, 1)

        Isaac.DrawLine(
            pos - OFFSET,
            pos + OFFSET,
            color,
            color,
            PIXEL_SIZE
        )

    end end

    for y = 1, MAP_SIZE do for x = 1, MAP_SIZE do
        
        local value = noise2[y][x]
        local pos = startPos + Vector(PIXEL_SIZE * (x - 1), PIXEL_SIZE * (y - 1)) - Vector(1, 0) * RENDER_SCALE
        local color = KColor(value, value, value, 1)

        Isaac.DrawLine(
            pos - OFFSET,
            pos + OFFSET,
            color,
            color,
            PIXEL_SIZE
        )

    end end

    for y = 1, MAP_SIZE do for x = 1, MAP_SIZE do
        
        local value = noise2[y][x]
        local pos = startPos + Vector(PIXEL_SIZE * (x - 1), PIXEL_SIZE * (y - 1)) + Vector(1, 0) * RENDER_SCALE
        local color = KColor(value, value, value, 1)

        Isaac.DrawLine(
            pos - OFFSET,
            pos + OFFSET,
            color,
            color,
            PIXEL_SIZE
        )

    end end

    for y = 1, MAP_SIZE do for x = 1, MAP_SIZE do
        
        local value = noise2[y][x]
        local pos = startPos + Vector(PIXEL_SIZE * (x - 1), PIXEL_SIZE * (y - 1)) - Vector(0, 1) * RENDER_SCALE
        local color = KColor(value, value, value, 1)

        Isaac.DrawLine(
            pos - OFFSET,
            pos + OFFSET,
            color,
            color,
            PIXEL_SIZE
        )

    end end

    for y = 1, MAP_SIZE do for x = 1, MAP_SIZE do
        
        local value = noise2[y][x]
        local pos = startPos + Vector(PIXEL_SIZE * (x - 1), PIXEL_SIZE * (y - 1)) + Vector(0, 1) * RENDER_SCALE
        local color = KColor(value, value, value, 1)

        Isaac.DrawLine(
            pos - OFFSET,
            pos + OFFSET,
            color,
            color,
            PIXEL_SIZE
        )

    end end
end)