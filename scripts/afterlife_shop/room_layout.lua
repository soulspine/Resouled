local game = Game()

local DeathStatue = Resouled.Stats.DeathStatue
local BuffPedestal = Resouled.Stats.BuffPedestal
local WiseSkull = Resouled.Stats.WiseSkull

local ShopLevels = Resouled.AfterlifeShop.ShopLevels

local DecorationConfig = {
    MinDecorations = 5,
    MaxDecorations = 15,

    Variant = Isaac.GetEntityVariantByName("Afterlife Backdrop Decoration"),
    SubType = Isaac.GetEntitySubTypeByName("Afterlife Backdrop Decoration"),

    AniamationNum = 21,

    SpriteWidth = 24,
}

---@param position Vector
local function spawnBuffPedestal(position)
    Isaac.Spawn(BuffPedestal.Type, BuffPedestal.Variant, BuffPedestal.SubType, position, Vector.Zero, nil)
end

local buffPos = {
    [ShopLevels.Level0] = {
        [1] = Vector(50, -25),
        [2] = Vector(-50, -25)
    },
    [ShopLevels.Level1] = {
        [1] = Vector(70, -35),
        [2] = Vector(-70, -35),
        [3] = Vector(0, -20)
    },
    [ShopLevels.Level2] = {
        [1] = Vector(70, -35),
        [2] = Vector(-70, -35),
        [3] = Vector(0, -20)
    },
    [ShopLevels.Level3] = {
        [1] = Vector(70, -35),
        [2] = Vector(-70, -35),
        [3] = Vector(0, -20)
    },
    [ShopLevels.Level4] = {
        [1] = Vector(55, -35),
        [2] = Vector(-55, -35),
        [3] = Vector(0, -25),
        [4] = Vector(-100, -50),
        [5] = Vector(100, -50)
    },
    [ShopLevels.Level5] = {
        [1] = Vector(55, -35),
        [2] = Vector(-55, -35),
        [3] = Vector(0, -25),
        [4] = Vector(-90, -65),
        [5] = Vector(90, -65)
    },
}

local function mainShopLayout()
    local room = Game():GetRoom()
    local topLeft = room:GetTopLeftPos()
    local bottomRight = room:GetBottomRightPos()
    local centerPos = room:GetCenterPos()

    local statuePos = Vector(
        (topLeft.X + bottomRight.X)/2,
        (topLeft.Y + bottomRight.Y)/3
    )
    Isaac.Spawn(EntityType.ENTITY_EFFECT, DeathStatue.Variant, DeathStatue.SubType, statuePos, Vector.Zero, nil)

    Resouled.AfterlifeShop:SetShopLevel(Resouled.AfterlifeShop.ShopLevels.Level5)
    local shopLevel = Resouled.AfterlifeShop:GetShopLevel()
    for i = 1, #buffPos[shopLevel] do
        spawnBuffPedestal(centerPos + buffPos[shopLevel][i])
    end
end

local specialBuffPos = {
    [1] = Vector(-200, -75),
    [2] = Vector(-100, -75),
    [3] = Vector(200, -75),
    [4] = Vector(100, -75),
    [5] = Vector(-200, 75),
    [6] = Vector(-100, 75),
    [7] = Vector(200, 75),
    [8] = Vector(100, 75),
}

Resouled.AfterlifeShop.SpecialBuffsPerRoom = #specialBuffPos

local function specialBuffsLayout()
    local buffs = {}

    local i = 1
    for key, buffID in pairs(Resouled.AfterlifeShop.Goto.SpecialBuffs) do

        if i <= #specialBuffPos then
            buffs[i] = buffID
            Resouled.AfterlifeShop.Goto.SpecialBuffs[key] = nil
        end

        i = i + 1
    end

    for j = 1, #specialBuffPos do
        if buffs[j] then
            local room = Game():GetRoom()
            local centerPos = room:GetCenterPos()
            Resouled:SpawnSetBuffPedestal(buffs[j], centerPos + specialBuffPos[j])
        end
    end
end

local Casket = Resouled.Stats.Casket

local function graveyardLayout()
    local room = Game():GetRoom()

    Isaac.Spawn(Casket.Type, Casket.Variant, Casket.SubType, room:GetCenterPos(), Vector.Zero, nil)
end

local function bossfightLayout()
    local FileSave = SAVE_MANAGER.GetPersistentSave()
    if not FileSave then FileSave = {} end
    if not FileSave.WiseSkullKilled then FileSave.WiseSkullKilled = false end
    local room = Game():GetRoom()

    if FileSave.WiseSkullKilled == false then
        Isaac.Spawn(WiseSkull.Type, WiseSkull.Variant, WiseSkull.SubType, room:GetCenterPos(), Vector.Zero, nil)
    end
end

local layouts = {
    [Resouled.AfterlifeShop.RoomTypes.MainShop] = mainShopLayout,
    [Resouled.AfterlifeShop.RoomTypes.SpecialBuffsRoom] = specialBuffsLayout,
    [Resouled.AfterlifeShop.RoomTypes.Graveyard] = graveyardLayout,
    [Resouled.AfterlifeShop.RoomTypes.SecretFight] = bossfightLayout,
}

---@param seed integer
local function advanceSeed(seed)
    return seed + 169
end

---@param squarePos Vector
---@param squareSize number
---@param pos Vector
local function isInSquareArea(squarePos, squareSize, pos)
    local topLeft = squarePos - Vector(squareSize/2, squareSize/2)
    local bottomRight = squarePos + Vector(squareSize/2, squareSize/2)

    return pos.X >= topLeft.X and pos.X <= bottomRight.X and pos.Y >= topLeft.Y and pos.Y <= bottomRight.Y
end

---@param room Room
local function replaceBackdropDetails(room)
    local level = game:GetLevel()
    local startSeed = game:GetSeeds():GetStartSeed()

    ---@param grid GridEntity | nil
    Resouled.Iterators:IterateOverGrid(function(grid)
        if grid and grid:GetType() == GridEntityType.GRID_DECORATION then
            room:RemoveGridEntityImmediate(grid:GetGridIndex(), 0, false)
        end
    end)

    local seed = level:GetCurrentRoomIndex() + startSeed

    local rng = RNG(seed)

    local decorationNum = rng:RandomInt(DecorationConfig.MinDecorations, DecorationConfig.MaxDecorations + 1)

    local decorationPositions = {}

    local topLeft = room:GetTopLeftPos() + Vector(DecorationConfig.SpriteWidth, DecorationConfig.SpriteWidth)
    local bottomRight = room:GetBottomRightPos() + Vector(-DecorationConfig.SpriteWidth, -DecorationConfig.SpriteWidth)

    for _ = 1, decorationNum do
        rng:SetSeed(seed)

        local pos = Vector(rng:RandomInt(topLeft.X, bottomRight.X), rng:RandomInt(topLeft.Y, bottomRight.Y))
        for _, position in pairs(decorationPositions) do
            while isInSquareArea(position, DecorationConfig.SpriteWidth, pos) do
                seed = advanceSeed(seed)
                rng:SetSeed(seed)
                pos = Vector(rng:RandomInt(topLeft.X, bottomRight.X), rng:RandomInt(topLeft.Y, bottomRight.Y))
            end
        end

        table.insert(decorationPositions, pos)

        local detail = game:Spawn(EntityType.ENTITY_EFFECT, DecorationConfig.Variant, pos, Vector.Zero, nil, DecorationConfig.SubType, seed):ToEffect()
        detail.DepthOffset = -1000
        detail:AddEntityFlags(EntityFlag.FLAG_BACKDROP_DETAIL)
        detail:GetSprite():Play(tostring(rng:RandomInt(DecorationConfig.AniamationNum + 1)), true)

        seed = advanceSeed(seed)
    end
end

local function postNewRoom()
    if Resouled.AfterlifeShop:IsAfterlifeShop() then
        
        local level = Game():GetLevel()
        local room = level:GetCurrentRoom()

        if room:IsFirstVisit() then
            if room:IsFirstVisit() then
                ---@param pickup EntityPickup
                Resouled.Iterators:IterateOverRoomPickups(function(pickup)
                    pickup:Remove()
                end)
            end

            local roomType = Resouled.AfterlifeShop:getRoomTypeFromIdx(level:GetCurrentRoomIndex())
            if roomType and layouts[roomType] then
                layouts[roomType]()
            end
        end

        replaceBackdropDetails(room)
        
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)