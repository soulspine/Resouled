local font = Font()
font:Load("font/luaminioutlined.fnt")

local CONFIG = {
    BlockSize = 32,
    Perlin = {
        Scale = 9,
        FallofPower = 0.7,
        ThresholdMax = 0.63,
        ThresholdMin = 0.45,
    }
}


local Map = {}
local rng = RNG()

local generate = true

---@param block table
---@return table
local function polishBlock(block)
    local polishedBlock = {}

    for x = 1, CONFIG.BlockSize do
        polishedBlock[x] = {}
        for y = 1, CONFIG.BlockSize do
            polishedBlock[x][y] = block[x][y]
        end
    end

    for x = 2, CONFIG.BlockSize - 1 do for y = 2, CONFIG.BlockSize - 1 do

        local val = block[x][y]

        local aroundValues = {
            block[x - 1][y],
            block[x][y - 1],
            block[x + 1][y],
            block[x][y + 1]
        }

        local differentAround = 0
        for i = 1, 4 do
            if aroundValues[i] ~= val then
                differentAround = differentAround + 1
            end
        end

        if differentAround > 2 then val = val == 1 and 0 or 1 end

        polishedBlock[x][y] = val

    end end

    return polishedBlock
end

function Resouled:GenerateShadowGrassMap()
    generate = true
end

---@param blockX integer
---@param blockY integer
---@param topNeigh? integer[][]
---@param botNeigh? integer[][]
---@param rightNeigh? integer[][]
---@param leftNeigh? integer[][]
local function generateBlock(blockX, blockY, topNeigh, botNeigh, rightNeigh, leftNeigh)
    
    rng:SetSeed((blockX * 73856093 ~ blockY * 19349663) + 1, 43)
    local random2d = {}
    local output = {}

    -- Generate random grid for this block
    for x = 1, CONFIG.BlockSize do
        random2d[x] = {}
        output[x] = {}
        for y = 1, CONFIG.BlockSize do
            random2d[x][y] = rng:RandomFloat()
            rng:Next()
            output[x][y] = 0
        end
    end

    -- https://github.com/Davidandrocket/blank-app/blob/main/streamlit_app.py#L51

    -- Perlin noise interpolation
    for x = 1, CONFIG.BlockSize do
        for y = 1, CONFIG.BlockSize do
            local fX = x / CONFIG.Perlin.Scale
            local fY = y / CONFIG.Perlin.Scale

            local x0 = math.floor(fX)
            local y0 = math.floor(fY)

            local dX = fX - x0
            local dY = fY - y0

            -- Sample from current block or neighbors at edges
            local function sampleGrid(gx, gy)
                -- Check if we need to sample from a neighbor
                if gx < 1 then
                    return leftNeigh and leftNeigh[CONFIG.BlockSize][gy] or random2d[CONFIG.BlockSize][gy]
                elseif gx > CONFIG.BlockSize then
                    return rightNeigh and rightNeigh[1][gy] or random2d[1][gy]
                elseif gy < 1 then
                    return topNeigh and topNeigh[gx][CONFIG.BlockSize] or random2d[gx][CONFIG.BlockSize]
                elseif gy > CONFIG.BlockSize then
                    return botNeigh and botNeigh[gx][1] or random2d[gx][1]
                else
                    return random2d[gx][gy]
                end
            end

            local tl = sampleGrid((x0 - 1) % CONFIG.BlockSize + 1, (y0 - 1) % CONFIG.BlockSize + 1)
            local tr = sampleGrid((x0) % CONFIG.BlockSize + 1, (y0 - 1) % CONFIG.BlockSize + 1)
            local bl = sampleGrid((x0 - 1) % CONFIG.BlockSize + 1, (y0) % CONFIG.BlockSize + 1)
            local br = sampleGrid((x0) % CONFIG.BlockSize + 1, (y0) % CONFIG.BlockSize + 1)

            dX = dX * dX * (3 - 2 * dX)
            dY = dY * dY * (3 - 2 * dY)

            local top = tl + (tr - tl) * dX
            local bot = bl + (br - bl) * dX

            local val = (top + (bot - top) * dY) ^ CONFIG.Perlin.FallofPower
            val = math.max(0, math.min(1, val))

            if val > (CONFIG.Perlin.ThresholdMin + CONFIG.Perlin.ThresholdMax) / 2 then
                val = 1
            else
                val = 0
            end

            output[x][y] = val
        end
    end

    return polishBlock(output)
end

-- Helper function to get or generate a block
local function getOrGenerateBlock(blockX, blockY)
    if true then return end
    if not Map[blockX] then
        Map[blockX] = {}
    end
    
    if Map[blockX][blockY] then
        return Map[blockX][blockY]
    end
    
    -- Get neighbor blocks (they may not exist yet)
    local topNeigh = Map[blockX] and Map[blockX][blockY - 1]
    local botNeigh = Map[blockX] and Map[blockX][blockY + 1]
    local leftNeigh = Map[blockX - 1] and Map[blockX - 1][blockY]
    local rightNeigh = Map[blockX + 1] and Map[blockX + 1][blockY]
    
    Map[blockX][blockY] = generateBlock(blockX, blockY, topNeigh, botNeigh, rightNeigh, leftNeigh)
    
    return Map[blockX][blockY]
end

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if generate then
        generate = false
        
        -- generate initial block cluster (3x3)
        Map = {}
        for bx = -1, 1 do
            for by = -1, 1 do
                getOrGenerateBlock(bx, by)
            end
        end
    end

    -- Draw blocks
    for bx = -1, 1 do
        for by = -1, 1 do
            local block = getOrGenerateBlock(bx, by)
            
            for x = 1, CONFIG.BlockSize do for y = 1, CONFIG.BlockSize do
                    
                local z = block[x][y]
                local c = KColor(z, z, z, 1)
                font:DrawString(".", 100 + bx * 64 + x * 2, 100 + by * 64 + y * 2, c)
            end end
        end
    end
end)