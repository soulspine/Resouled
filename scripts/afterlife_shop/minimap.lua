local Sprites = {
    Map = Sprite(),
    Room = Sprite(),
    CurrentRoom = Sprite(),
    RoomConnection = Sprite(),
    MapBig = Sprite()
}

local DISTANCE_BETWEEN_ROOMS = 9
local MAP_SIZE = 54
local MAP_CENTER = 6

for _, sprite in pairs(Sprites) do
    sprite:Load("gfx/ui/afterlife_minimap.anm2", true)
end

local Map = Sprites.Map
local Room = Sprites.Room
local CurrentRoom = Sprites.CurrentRoom
local RoomConnection = Sprites.RoomConnection
local MapBig = Sprites.MapBig

Map:Play("Map", true)
Room:Play("Room", true)
CurrentRoom:Play("CurrentRoom", true)
RoomConnection:Play("RoomConnection", true)
MapBig:Play("MapBig", true)

---@return Vector
local function getMapPosition()
    local map = MAP_SIZE/2
    map = map + map/2 * Options.HUDOffset
    return Vector(Isaac.GetScreenWidth() - map, map)
end

---@param position Vector
---@return boolean
local function IsPosInsideMap(position)
    local mapPos = getMapPosition()
    local mapSize = MAP_SIZE/2
    local x = math.ceil(DISTANCE_BETWEEN_ROOMS/2)
    return position.X > mapPos.X - mapSize + x and position.X < mapPos.X + mapSize - x and position.Y > mapPos.Y - mapSize + x and position.Y < mapPos.Y + mapSize - x
end

local function postHudRender()
    if Resouled.AfterlifeShop:IsAfterlifeShop() then
        local minimapState = Minimap:GetState()
        if minimapState == MinimapState.NORMAL then
            local mapPos = getMapPosition()
            Map:Render(mapPos)
            
            for i = 0, 12 do
                for j = 0, 12 do
                    
                    local roomIdx = 13 * i + j
                    local room = Resouled.AfterlifeShop:getRoomTypeFromIdx(roomIdx)
                    
                    if room and room ~= 0 then
                        
                        local currentIndex = Game():GetLevel():GetCurrentRoomIndex()
                        local currentRoomPos = Resouled:GetRoomColumnAndRowFromIdx(currentIndex)
                        local roomPos = mapPos + Vector(DISTANCE_BETWEEN_ROOMS * (j - currentRoomPos.X), DISTANCE_BETWEEN_ROOMS * (i - currentRoomPos.Y))
                        
                        if IsPosInsideMap(roomPos) then
                            Room:Render(roomPos)
                        end
                        
                        for d = 0, 3 do
                            local otherRoomIdx = Resouled:GetRoomIdxFromDir(d, roomIdx)
                            if otherRoomIdx then
                                local otherRoom = Resouled.AfterlifeShop:getRoomTypeFromIdx(otherRoomIdx)
                                if otherRoom and otherRoom ~= 0 and Resouled.AfterlifeShop:AreRoomsConnected(roomIdx, otherRoomIdx) then
                                    
                                    RoomConnection.Rotation = d * 90 + 90
                                    local otherRoomConnectorPos = roomPos + Vector(math.floor(DISTANCE_BETWEEN_ROOMS/2), 0):Rotated(RoomConnection.Rotation + 90)
                                    
                                    if IsPosInsideMap(otherRoomConnectorPos) then
                                        RoomConnection:Render(otherRoomConnectorPos)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            CurrentRoom:Render(mapPos)
        else
            local mapPos = Vector(Isaac.GetScreenWidth()/2, Isaac.GetScreenHeight()/2)
            MapBig:Render(mapPos)

            for i = 0, 12 do
                for j = 0, 12 do
                    
                    local roomIdx = 13 * i + j
                    local room = Resouled.AfterlifeShop:getRoomTypeFromIdx(roomIdx)
                    
                    if room and room ~= 0 then
                        
                        local roomPos = mapPos + Vector(DISTANCE_BETWEEN_ROOMS * (j - MAP_CENTER), DISTANCE_BETWEEN_ROOMS * (i - MAP_CENTER))
                        
                        Room:Render(roomPos)
                        
                        for d = 0, 3 do
                            local otherRoomIdx = Resouled:GetRoomIdxFromDir(d, roomIdx)
                            if otherRoomIdx then
                                local otherRoom = Resouled.AfterlifeShop:getRoomTypeFromIdx(otherRoomIdx)
                                if otherRoom and otherRoom ~= 0 and Resouled.AfterlifeShop:AreRoomsConnected(roomIdx, otherRoomIdx) then
                                    
                                    RoomConnection.Rotation = d * 90 + 90
                                    local otherRoomConnectorPos = roomPos + Vector(math.floor(DISTANCE_BETWEEN_ROOMS/2), 0):Rotated(RoomConnection.Rotation + 90)
                                    
                                    RoomConnection:Render(otherRoomConnectorPos)
                                end
                            end
                        end
                    end
                end
            end
            local currentIndex = Game():GetLevel():GetCurrentRoomIndex()
            local currentRoomPos = Resouled:GetRoomColumnAndRowFromIdx(currentIndex)
            local roomPos = mapPos + Vector(DISTANCE_BETWEEN_ROOMS * (currentRoomPos.X - MAP_CENTER), DISTANCE_BETWEEN_ROOMS * (currentRoomPos.Y - MAP_CENTER))

            CurrentRoom:Render(roomPos)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, postHudRender)