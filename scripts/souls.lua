local SOUL_TYPE = Isaac.GetEntityTypeByName("Soul Pickup")
local SOUL_VARIANT = Isaac.GetEntityVariantByName("Soul Pickup")

---@param pickup EntityPickup
local function onPickupCollision(_, pickup)
    if pickup.Type == SOUL_TYPE and pickup.Variant == SOUL_VARIANT then
        local RunSave = SAVE_MANAGER.GetRunSave()
        local data = pickup:GetData()

        if not RunSave.Souls then
            RunSave.Souls = {}
        end

        local soulAlreadyCollected = false

        for _ = 1, #RunSave.Souls do
            if RunSave.Souls[_] == data.Soul then
                soulAlreadyCollected = true
            end
        end

        for _ = 1, #RunSave.Souls do
            print(RunSave.Souls[_])
        end

        if not soulAlreadyCollected then
            for _ = 1, 4 do
                if RunSave.Souls[_] == nil then
                    table.insert(RunSave.Souls, _, data.Soul)
                    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    data.PickedUp = true
                    pickup.Color = Color(1, 1, 1, 0.5)
                    break
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onPickupCollision)

---@param pickup EntityPickup
local function onPickupUpdate(_, pickup)
    if pickup.Type == SOUL_TYPE and pickup.Variant == SOUL_VARIANT then
        local data = pickup:GetData()
        local sprite = pickup:GetSprite()
        if data.PickedUp then
            
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate)