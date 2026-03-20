local fireSprite = Sprite()
fireSprite:Load("gfx_resouled/effects/fire.anm2", false)
fireSprite:ReplaceSpritesheet(0, "gfx/effects/effect_005_fire.png", true)
fireSprite:Play("Idle", true)
fireSprite.Color.A = 0.75
local ANIM_LENGTH = 12

local function postNewRoom()
    if not Resouled:RoomEventPresent(Resouled.RoomEvents.EVERYTHING_MUST_GO) then return end
    local roomSave = Resouled.SaveManager.GetRoomFloorSave()
    roomSave.EverythingMustGoPrices = {}
    ---@param pickup EntityPickup
    Resouled.Iterators:IterateOverRoomPickups(function(pickup)
        if pickup:IsShopItem() then
            roomSave.EverythingMustGoPrices[tostring(pickup.ShopItemId)] = 0.5
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function preRoomExit()
    if not Resouled:RoomEventPresent(Resouled.RoomEvents.EVERYTHING_MUST_GO) then return end
    local roomSave = Resouled.SaveManager.GetRoomFloorSave()
    if not roomSave.EverythingMustGoPrices then return end

    ---@param pickup EntityPickup
    Resouled.Iterators:IterateOverRoomPickups(function(pickup)
        if roomSave.EverythingMustGoPrices[tostring(pickup.ShopItemId)] then
            pickup:Remove()
        end
    end)
    roomSave.EverythingMustGoPrices = nil
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, preRoomExit)

---@param variant integer
---@param subtype integer
---@param shopItemId integer
---@param price integer
local function onGetShopItemPrice(_, variant, subtype, shopItemId, price)
    if not Resouled:RoomEventPresent(Resouled.RoomEvents.EVERYTHING_MUST_GO) then return end
    local roomSave = Resouled.SaveManager.GetRoomFloorSave()
    if not roomSave.EverythingMustGoPrices then return end
    local key = tostring(shopItemId)
    if roomSave.EverythingMustGoPrices[key] then
        return math.floor(price * roomSave.EverythingMustGoPrices[key] + 0.5)
    end
end
Resouled:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, onGetShopItemPrice)

---@param pic EntityPickup
local function prePickupRender(_, pic)
    if not Resouled:RoomEventPresent(Resouled.RoomEvents.EVERYTHING_MUST_GO) or not pic:IsShopItem() then return end
    fireSprite:SetFrame((Resouled.Game:GetFrameCount() + pic.InitSeed)%ANIM_LENGTH)
    fireSprite:Render(Isaac.WorldToScreen(pic.Position))
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_RENDER, prePickupRender)