local tileSprite = Sprite()
tileSprite:Load("gfx/backdrop/backdrop_outside.anm2", true)
tileSprite:Play("Idle", true)

local rng = RNG()

local arenaSize = 500

local maxX = 3
local maxY = 2
local tileSize = Vector(48, 48)

---@param pos Vector
local function setSeededTile(pos)
    local layer = tileSprite:GetLayer(0)
    if not layer then return end
    local seed = math.floor(math.max(pos.X * 7 + pos.Y * 5, 1))
    rng:SetSeed(seed)
    layer:SetCropOffset(Vector(
        rng:RandomInt(maxX) * tileSize.X,
        rng:RandomInt(maxY) * tileSize.Y
    ))
end

Resouled:AddCallback(ModCallbacks.MC_PRE_BACKDROP_RENDER_WALLS, function()

    local room = Game():GetRoom()

    local roomTopLeft = Isaac.WorldToScreen(room:GetTopLeftPos())

    room:SetBackdropType(BackdropType.DARKROOM, 0)

    local topLeft = -tileSize * 2
    local bottomRight = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight()) + tileSize * 2
    local offset = Game():GetRoom():GetRenderScrollOffset()
    offset = Vector(offset.X, offset.Y)
    offset.X = offset.X % tileSize.X
    offset.Y = offset.Y % tileSize.Y

    local i = 0

    local x = topLeft.X
    local y = topLeft.Y

    while x <= bottomRight.X do
        while y <= bottomRight.Y do
            local pos = Vector(x, y) + tileSize

            pos = pos + offset

            local seed = Vector((math.abs((pos.X - roomTopLeft.X) // tileSize.X) * tileSize.X), math.abs(((pos.Y - roomTopLeft.Y) // tileSize.Y) * tileSize.Y))

            setSeededTile(seed)


            tileSprite:Render(pos)

            y = y + tileSize.Y
        end

        i = i + 1
        x = x + tileSize.X
        y = topLeft.Y + 24 * (x//24 % 2)
    end
end)

Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    local roomLevel = Game():GetLevel():GetCurrentRoomDesc()
    roomLevel.Flags = RoomDescriptor.FLAG_NO_WALLS
end)

---@param player EntityPlayer
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    local center = Game():GetRoom():GetCenterPos()
    if player.Position:Distance(center) > arenaSize then
        local centerToPlayer = center - player.Position
        player.Velocity = (player.Velocity * 0.95 + (centerToPlayer):Resized((centerToPlayer:Length() - arenaSize)/25))
    end

    if player.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_NONE then player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE end
end)

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    local center = Game():GetRoom():GetCenterPos()
    local offset = Vector(arenaSize, 0)
    for _ = 1, 360 do
        Isaac.DrawLine(Isaac.WorldToScreen(center + offset), Isaac.WorldToScreen(center + offset:Rotated(1)), KColor(1, 0, 0, 1), KColor(1, 0, 0, 1), 1)
        offset = offset:Rotated(1)
    end
end)