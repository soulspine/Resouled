---@enum AfterlifeShopRoomType
AfterlifeShopRoomTypes = {
    None = 0,
    MainShop = 1,
    SpecialBuffsRoom = 2,
    SoulSanctum = 3,
}

--Sets the next entered stage to the afterlife shop
function Resouled:SetAfterlifeShop()
    local RunSave = SAVE_MANAGER.GetRunSave()
    RunSave.AfterlifeShopNext = true
end

local function preNewLevel()
    local RunSave = SAVE_MANAGER.GetRunSave()
    if RunSave.AfterlifeShopNext then
        RunSave.AfterlifeShop = {}
        RunSave.AfterlifeShopNext = nil
    end

    Resouled:SetAfterlifeShop()
end
Resouled:AddPriorityCallback(ModCallbacks.MC_PRE_LEVEL_INIT, CallbackPriority.IMPORTANT, preNewLevel)

include("scripts.afterlife_shop.backdrop")
include("scripts.afterlife_shop.doors_and_floor_layout")