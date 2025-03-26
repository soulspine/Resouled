local GLITCH = Isaac.GetItemIdByName("Glitch")

local MORPH_COOLDOWN = 25
local ITEM_COUNT = 3
local DEFAULT_COLLECTIBLE = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_SAD_ONION)
local GLITCH_GFX = Isaac.GetItemConfig():GetCollectible(GLITCH).GfxFileName

local PICKUP_SFX = SoundEffect.SOUND_EDEN_GLITCH

local EID_DESCRIPTION = "Limits pedestal options to " .. ITEM_COUNT .. " other passive items from current item pool and inherits those effects. Only one effect takes place at a time and it changes after clearing a room.#Having multiple copies of this item increases effect pool.#"

local ITEM_BLACKLIST = {
    [CollectibleType.COLLECTIBLE_R_KEY] = true,
    [CollectibleType.COLLECTIBLE_FORGET_ME_NOW] = true,
    [CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER] = true,
    [CollectibleType.COLLECTIBLE_INNER_CHILD] = true,
    [CollectibleType.COLLECTIBLE_WAVY_CAP] = true,
    [CollectibleType.COLLECTIBLE_MEGA_MUSH] = true,
    [CollectibleType.COLLECTIBLE_KEEPERS_BOX] = true,
    [CollectibleType.COLLECTIBLE_CLEAR_RUNE] = true,
    [CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE] = true,
    [CollectibleType.COLLECTIBLE_SPINDOWN_DICE] = true,
    [CollectibleType.COLLECTIBLE_ESAU_JR] = true,
    [CollectibleType.COLLECTIBLE_ETERNAL_D6] = true,
    [CollectibleType.COLLECTIBLE_D_INFINITY] = true,
    [CollectibleType.COLLECTIBLE_RED_KEY] = true,
    [CollectibleType.COLLECTIBLE_FLIP] = true,
    [CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS] = true,
    [CollectibleType.COLLECTIBLE_BLANK_CARD] = true,
    [CollectibleType.COLLECTIBLE_PLACEBO] = true,
    [CollectibleType.COLLECTIBLE_NECRONOMICON] = true,
}

---@param pickup EntityPickup
local function onPickupInit(_, pickup)
    local roomFloorSave = SAVE_MANAGER.GetRoomFloorSave(pickup).NoRerollSave
    if pickup.SubType == GLITCH then
        if not roomFloorSave.Glitch then -- first spawn
            roomFloorSave.Glitch = {
                Cooldown = MORPH_COOLDOWN,
                ItemIndex = 0,
                Items = {},
            }
    
            local pool = Game():GetItemPool()
            for _ = 1, ITEM_COUNT do
                ::reroll::
                local item = Isaac.GetItemConfig():GetCollectible(pool:GetCollectible(pool:GetLastPool(), false, nil,  DEFAULT_COLLECTIBLE.ID))
                if not ITEM_BLACKLIST[item.ID] and item:IsAvailable() and item.MaxCharges == 0 and not item:HasTags(ItemConfig.TAG_QUEST) and item:HasTags(ItemConfig.TAG_OFFENSIVE) then
                    table.insert(roomFloorSave.Glitch.Items, {
                        Id = item.ID,
                        Gfx = item.GfxFileName,
                    })
                else
                    pool:AddRoomBlacklist(item.ID)
                    goto reroll
                end
            end
            pickup:Morph(pickup.Type, pickup.Variant, pickup.SubType, true, true, true)
        else -- floor save has been initialized before
            if not Resouled:IsQuestionMarkItem(pickup) then
                local data = pickup:GetData()
                data["EID_Description"] = EID_DESCRIPTION

                for i = 1, #roomFloorSave.Glitch.Items do
                    local item = Isaac.GetItemConfig():GetCollectible(roomFloorSave.Glitch.Items[i].Id)
                    data["EID_Description"] = data["EID_Description"] .. "{{Blank}} {{Collectible" .. item.ID .. "}} "
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
local function onPickupUpdate(_, pickup)
    local roomFloorSave = SAVE_MANAGER.GetRoomFloorSave(pickup).NoRerollSave
    if roomFloorSave.Glitch and not Resouled:IsQuestionMarkItem(pickup) then
        if roomFloorSave.Glitch.Cooldown > 0 then
            roomFloorSave.Glitch.Cooldown = roomFloorSave.Glitch.Cooldown - 1
            return
        else
            roomFloorSave.Glitch.ItemIndex = roomFloorSave.Glitch.ItemIndex == #roomFloorSave.Glitch.Items and 0 or roomFloorSave.Glitch.ItemIndex + 1
            roomFloorSave.Glitch.Cooldown = MORPH_COOLDOWN

            local sprite = pickup:GetSprite()
            local newSpritesheet = roomFloorSave.Glitch.ItemIndex == 0 and GLITCH_GFX or roomFloorSave.Glitch.Items[roomFloorSave.Glitch.ItemIndex].Gfx

            sprite:ReplaceSpritesheet(1, newSpritesheet)
            sprite:LoadGraphics()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
---@param collider Entity
local function onPickupCollision(_, pickup, collider)
    local player = collider:ToPlayer()
    if player then
        local roomFloorSave = SAVE_MANAGER.GetRoomFloorSave(pickup).NoRerollSave
        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        if roomFloorSave.Glitch then
            if playerRunSave.Glitch == nil then
                playerRunSave.Glitch = {
                    Items = {},
                    ItemIndex = 1,
                    HistoryTime = nil,
                }
            end
            
            for i = 1, #roomFloorSave.Glitch.Items do
                table.insert(playerRunSave.Glitch.Items, roomFloorSave.Glitch.Items[i].Id)
            end

            player:AnimateCollectible(GLITCH)
            player:AddCollectible(GLITCH)
            SFXManager():Play(PICKUP_SFX)
            pickup:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onPickupCollision, PickupVariant.PICKUP_COLLECTIBLE)

---@param rng RNG
---@param spawnPos Vector
local function onRoomClear(_, rng, spawnPos)
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        if player:HasCollectible(GLITCH) then
            local playerRunSave = SAVE_MANAGER.GetRunSave(player)
            if playerRunSave.Glitch then
                local itemConfig = Isaac.GetItemConfig()
                local itemToDelete = itemConfig:GetCollectible(playerRunSave.Glitch.Items[playerRunSave.Glitch.ItemIndex])
                
                local history = player:GetHistory()
                for i, historyItem in pairs(history:GetCollectiblesHistory()) do
                    if historyItem:GetItemID() == itemToDelete.ID and playerRunSave.Glitch.HistoryTime == historyItem:GetTime() then
                        player:RemoveCollectibleByHistoryIndex(i - 1)
                        break
                    end
                end
                
                playerRunSave.Glitch.ItemIndex = playerRunSave.Glitch.ItemIndex == #playerRunSave.Glitch.Items and 1 or playerRunSave.Glitch.ItemIndex + 1
                local itemToAdd = itemConfig:GetCollectible(playerRunSave.Glitch.Items[playerRunSave.Glitch.ItemIndex])
                
                itemToAdd.Tags = itemToDelete.Tags | ItemConfig.TAG_QUEST
                player:AddCollectible(playerRunSave.Glitch.Items[playerRunSave.Glitch.ItemIndex], nil, false)
                itemToAdd.Tags = itemToDelete.Tags & ~ ItemConfig.TAG_QUEST
 
                history = player:GetHistory()
                for i, historyItem in pairs(history:GetCollectiblesHistory()) do
                    if historyItem:GetItemID() == itemToAdd.ID then
                        playerRunSave.Glitch.HistoryTime = historyItem:GetTime()
                    end
                end
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, onRoomClear)