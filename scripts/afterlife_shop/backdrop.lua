local function postNewRoom()
    local room = Game():GetRoom()
    if false == true then --placeholder for a condition check if the room is an Afterlife Shop
        room:SetBackdropType(Isaac.GetBackdropIdByName("Afterlife Shop"), 1)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)