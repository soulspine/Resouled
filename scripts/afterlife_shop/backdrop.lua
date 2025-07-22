local game = Game()

local function postNewRoom()
    local RunSave = SAVE_MANAGER.GetRunSave()
    if RunSave.AfterlifeShop then
        local room = game:GetRoom()
        
        if room:IsFirstVisit() then
            ---@param pickup EntityPickup
            Resouled.Iterators:IterateOverRoomPickups(function(pickup)
                pickup:Remove()
            end)
        end

        room:SetBackdropType(Isaac.GetBackdropIdByName("Afterlife Shop"), 1)
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, postNewRoom)