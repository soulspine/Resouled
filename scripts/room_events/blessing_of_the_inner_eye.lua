local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BLESSING_OF_INNER_EYE) then
        local level = Game():GetLevel()
        local currentRoomDescriptor = level:GetCurrentRoomDesc()
        local roomsNear1st = currentRoomDescriptor:GetNeighboringRooms()
        
        for i = 0, #roomsNear1st do
            
            local roomDescriptor2nd = roomsNear1st[i]
            
            if roomDescriptor2nd then
                
                if roomDescriptor2nd.DisplayFlags ~= RoomDescriptor.DISPLAY_ALL then
                    roomDescriptor2nd.DisplayFlags = RoomDescriptor.DISPLAY_ALL
                end
                
                local roomsNear2nd = roomDescriptor2nd:GetNeighboringRooms()
                
                for j = 0, #roomsNear2nd do
                    
                    local roomDescriptor3rd = roomsNear2nd[j]
                    
                    if roomDescriptor3rd then
                        
                        if roomDescriptor3rd.DisplayFlags ~= RoomDescriptor.DISPLAY_ALL then
                            roomDescriptor3rd.DisplayFlags = RoomDescriptor.DISPLAY_ALL
                        end
                        
                        local roomsNear3rd = roomDescriptor3rd:GetNeighboringRooms()
                        
                        for l = 0, #roomsNear3rd do
                            local roomDescriptor4th = roomsNear3rd[l]
                            
                            if roomDescriptor4th then
                                
                                if roomDescriptor4th.DisplayFlags ~= RoomDescriptor.DISPLAY_ALL then
                                    roomDescriptor4th.DisplayFlags = RoomDescriptor.DISPLAY_ALL
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)