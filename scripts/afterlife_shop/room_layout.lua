local DeathStatue = Resouled.Stats.DeathStatue
local BuffPedestal = Resouled.Stats.BuffPedestal

local ShopLevels = Resouled.AfterlifeShop.ShopLevels

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

local function specialBuffsLayout()
    for i = 1, #specialBuffPos do
        local room = Game():GetRoom()
        local centerPos = room:GetCenterPos()
        Resouled:SpawnSetBuffPedestal(Resouled.Buffs.WAR, centerPos + specialBuffPos[i])
    end
end

local layouts = {
    [Resouled.AfterlifeShop.RoomTypes.MainShop] = mainShopLayout,
    [Resouled.AfterlifeShop.RoomTypes.SpecialBuffsRoom] = specialBuffsLayout
}

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

    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)