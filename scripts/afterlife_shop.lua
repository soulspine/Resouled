Resouled.AfterlifeShop = {}

---@enum AfterlifeShopRoomType
Resouled.AfterlifeShop.RoomTypes = {
    None = 0, -- No room
    MainShop = 1, -- Afterlife main shop
    SpecialBuffsRoom = 2, -- Special buffs obtained through the run spawn there
    SoulSanctum = 3, -- You learn how to obtain special souls
    Graveyard = 4, -- You finish the run there
    StartingRoom = 5, -- You come out of a big chest there
    SecretFight = 6, -- You fight wise skull there to unlock soul sanctum
}

Resouled.AfterlifeShop.SpecialBuffRoomsConnectionWhitelist = {
    [Resouled.AfterlifeShop.RoomTypes.SoulSanctum] = true,
    [Resouled.AfterlifeShop.RoomTypes.SpecialBuffsRoom] = true
}

Resouled.AfterlifeShop.ChanceToGoBackToSoulSanctumDuringGeneration = 0.15

Resouled.AfterlifeShop.Themes = {
    Main = Isaac.GetMusicIdByName("Goodbye Cruel World"),
    Limbo = Isaac.GetMusicIdByName("Limbo"),
    LimboTutorial = Isaac.GetMusicIdByName("Limbo Tutorial")
}

Resouled.AfterlifeShop.Themes[Resouled.AfterlifeShop.Themes.Main] = true
Resouled.AfterlifeShop.Themes[Resouled.AfterlifeShop.Themes.Limbo] = true
Resouled.AfterlifeShop.Themes[Resouled.AfterlifeShop.Themes.LimboTutorial] = true

---@param integer integer
---@return string
local function makeLookupKey(integer)
    return tostring(math.floor(integer + 0.5))
end

--Sets the next entered stage to the afterlife shop
function Resouled.AfterlifeShop:SetAfterlifeShop()
    local RunSave = Resouled.SaveManager.GetRunSave()
    RunSave.AfterlifeShopNext = true
end

---@return integer | nil
function Resouled.AfterlifeShop:getRoomTypeFromIdx(index)
    local RunSave = Resouled.SaveManager.GetRunSave()
    if RunSave.AfterlifeShop and RunSave.AfterlifeShop["LevelLayout"] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(index)] then
        return RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(index)]
    end
    return nil
end

---@return boolean
function Resouled.AfterlifeShop:IsAfterlifeShop()
    local RunSave = Resouled.SaveManager.GetRunSave()
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
    local FileSave = Resouled.SaveManager.GetPersistentSave()
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
    local FileSave = Resouled.SaveManager.GetPersistentSave()
    if not FileSave then
        FileSave = {}
    end
    if not FileSave.AfterlifeShopLevel then
        FileSave.AfterlifeShopLevel = Resouled.AfterlifeShop.ShopLevels.Level0
    end
    FileSave.AfterlifeShopLevel = level
end

local function preNewLevel()
    local RunSave = Resouled.SaveManager.GetRunSave()
    if RunSave.AfterlifeShopNext then
        RunSave.AfterlifeShop = {}
        RunSave.AfterlifeShopNext = nil
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_PRE_LEVEL_INIT, CallbackPriority.IMPORTANT, preNewLevel)

---@param visible boolean
function Resouled.AfterlifeShop:SetMapVisibility(visible)
    MinimapAPI.Config.Disable = not visible
end

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if not Resouled.AfterlifeShop:IsAfterlifeShop() then
        Resouled.AfterlifeShop:SetMapVisibility(true)
    end
end)

local pillarSize = 30

---@param player EntityPlayer
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player) -- Players are ghosts
    if Resouled.AfterlifeShop:IsAfterlifeShop() then
    --    local effect = player:GetEffects()
    --    if not effect:HasNullEffect(NullItemID.ID_LOST_CURSE) then
    --        effect:AddNullEffect(NullItemID.ID_LOST_CURSE)
    --    end

        local room = Game():GetRoom()

        local topLeft = room:GetTopLeftPos()
        local bottomRight = room:GetBottomRightPos()
        local topRight = Vector(bottomRight.X, topLeft.Y)
        local bottomLeft = Vector(topLeft.X, bottomRight.Y)

        local pillarPosTable = {
            topLeft,
            bottomRight,
            topRight,
            bottomLeft,
        }

        for _, pos in ipairs(pillarPosTable) do
            if player.Position:Distance(pos) <= pillarSize then
                player.Velocity = player.Velocity/5 + (player.Position - pos):Normalized()
            end
        end
    end
end)

include("scripts.afterlife_shop.buff_pedestal")
include("scripts.afterlife_shop.reroll_machine")
include("scripts.afterlife_shop.backdrop")
include("scripts.afterlife_shop.doors_and_floor_layout")
include("scripts.afterlife_shop.room_layout")
include("scripts.afterlife_shop.entities")
include("scripts.afterlife_shop.entering")
include("scripts.afterlife_shop.music")
include("scripts.afterlife_shop.casket")
include("scripts.afterlife_shop.wise_skull")
--include("scripts.afterlife_shop.minimap")
include("scripts.afterlife_shop.buff_descriptions")
include("scripts.afterlife_shop.donation_machine")