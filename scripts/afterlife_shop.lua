Resouled.AfterlifeShop = {}

---@enum AfterlifeShopRoomType
Resouled.AfterlifeShop.RoomTypes = {
    None = 0,
    MainShop = 1,
    SpecialBuffsRoom = 2,
    SoulSanctum = 3,
}

---@param integer integer
---@return string
local function makeLookupKey(integer)
    return tostring(math.floor(integer + 0.5))
end

--Sets the next entered stage to the afterlife shop
function Resouled.AfterlifeShop:SetAfterlifeShop()
    local RunSave = SAVE_MANAGER.GetRunSave()
    RunSave.AfterlifeShopNext = true
end

---@return integer | nil
function Resouled.AfterlifeShop:getRoomTypeFromIdx(index)
    local RunSave = SAVE_MANAGER.GetRunSave()
    if RunSave.AfterlifeShop and RunSave.AfterlifeShop["LevelLayout"] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(index)] then
        return RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(index)]
    end
    return nil
end

---@return boolean
function Resouled.AfterlifeShop:IsAfterlifeShop()
    local RunSave = SAVE_MANAGER.GetRunSave()
    return RunSave.AfterlifeShop
end

---@enum AfterlifeShopLevel
Resouled.AfterlifeShop.ShopLevels = {
    Level0 = 0,
    Level1 = 1,
    Level2 = 2,
    Level3 = 3,
    Level4 = 4,
    Level5 = 5,
}

---@return AfterlifeShopLevel
function Resouled.AfterlifeShop:GetShopLevel()
    local FileSave = SAVE_MANAGER.GetPersistentSave()
    if not FileSave then
        FileSave = {}
    end
    if not FileSave.AfterlifeShopLevel then
        FileSave.AfterlifeShopLevel =  Resouled.AfterlifeShop.ShopLevels.Level0
    end
    return FileSave.AfterlifeShopLevel
end

---@param level AfterlifeShopLevel
function Resouled.AfterlifeShop:SetShopLevel(level)
    local FileSave = SAVE_MANAGER.GetPersistentSave()
    if not FileSave then
        FileSave = {}
    end
    if not FileSave.AfterlifeShopLevel then
        FileSave.AfterlifeShopLevel = Resouled.AfterlifeShop.ShopLevels.Level0
    end
    FileSave.AfterlifeShopLevel = level
end

local function preNewLevel()
    local RunSave = SAVE_MANAGER.GetRunSave()
    if RunSave.AfterlifeShopNext then
        RunSave.AfterlifeShop = {}
        RunSave.AfterlifeShopNext = nil
    end

    Resouled.AfterlifeShop:SetAfterlifeShop()
end
Resouled:AddPriorityCallback(ModCallbacks.MC_PRE_LEVEL_INIT, CallbackPriority.IMPORTANT, preNewLevel)

include("scripts.afterlife_shop.backdrop")
include("scripts.afterlife_shop.doors_and_floor_layout")
include("scripts.afterlife_shop.room_layout")