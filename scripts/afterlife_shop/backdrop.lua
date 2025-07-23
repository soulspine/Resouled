local game = Game()


local SoulLantern = {
    Variant = Isaac.GetEntityVariantByName("Soul Lantern"),
    SubType = Isaac.GetEntitySubTypeByName("Soul Lantern"),
}

---@param amount integer
local function spawnSoulLantern(amount)
    local room = Game():GetRoom()
    local topLeft = room:GetTopLeftPos()
    local bottomRight = room:GetBottomRightPos()
    for _ = 1, amount do
        local pos = Vector(math.random(topLeft.X, bottomRight.X), math.random(topLeft.Y, bottomRight.Y))
        Game():Spawn(EntityType.ENTITY_EFFECT, SoulLantern.Variant, pos, Vector.Zero, nil, SoulLantern.SubType, room:GetAwardSeed())
    end
end

local function postNewRoom()
    if Resouled.AfterlifeShop:IsAfterlifeShop() then
        local room = game:GetRoom()

        room:SetBackdropType(Isaac.GetBackdropIdByName("Afterlife Shop"), 1)

        if Resouled.AfterlifeShop:getRoomTypeFromIdx(Game():GetLevel():GetCurrentRoomIndex()) == Resouled.AfterlifeShop.RoomTypes.SoulSanctum then
            spawnSoulLantern(math.random(10, 15))
        end
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, postNewRoom)