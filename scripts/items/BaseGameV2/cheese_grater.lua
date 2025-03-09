local CHEESE_GRATER = Isaac.GetItemIdByName("Cheese Grater")

if EID then
    EID:addCollectible(CHEESE_GRATER, "Reveals all {{QuestionMark}} question mark items.#Works on alt path choices and {{CurseBlind}} Curse of the Blind.", "Cheese Grater")
end

local LAYER_TO_REPLACE = 1

---@param pickup EntityPickup
local function oncCollectibleUpdate(_, pickup) 
    -- THIS HAS TO BE POST UPDATE BECAUSE POST INIT THERE IS NO SPRITE LOADED YET
    -- POST RENDER ALSO DOES NOT WORK CORRECTLY BECAUSE IT GOES BACK AND FORTH BETWEEN BEING A QUESTION MARK AND NOT
    if Resouled:CollectiblePresent(CHEESE_GRATER) then
        Resouled:TryRevealQuestionMarkItem(pickup)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, oncCollectibleUpdate, PickupVariant.PICKUP_COLLECTIBLE)