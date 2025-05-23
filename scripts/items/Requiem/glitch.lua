local GLITCH = Isaac.GetItemIdByName("Glitch")

local MORPH_COOLDOWN = 25
local ITEM_COUNT = 3
local DEFAULT_COLLECTIBLE = CollectibleType.COLLECTIBLE_SAD_ONION
local GLITCH_GFX = Isaac.GetItemConfig():GetCollectible(GLITCH).GfxFileName

local PICKUP_SFX = SoundEffect.SOUND_EDEN_GLITCH

local EID_DESCRIPTION = "Limits pedestal options to " .. ITEM_COUNT .. " other passive items from current item pool and inherits those effects. Only one effect takes place at a time and it changes after clearing a room.#Having multiple copies of this item increases effect pool.#"

if EID then
    EID:addCollectible(GLITCH, EID_DESCRIPTION, "Glitch")
end

local ITEM_BLACKLIST = {
    [CollectibleType.COLLECTIBLE_DOLLAR] = true,
    [CollectibleType.COLLECTIBLE_PYRO] = true,
    [CollectibleType.COLLECTIBLE_SKELETON_KEY] = true,
}

---@param pickup EntityPickup
---@param afterReroll boolean
local function onPickupInit(_, pickup, afterReroll)
    local roomFloorSave = SAVE_MANAGER.GetRoomFloorSave(pickup).RerollSave
    if pickup.SubType == GLITCH or afterReroll then
        if not roomFloorSave.Glitch then -- first spawn
            roomFloorSave.Glitch = {
                Cooldown = MORPH_COOLDOWN,
                ItemIndex = 0,
                Items = {},
            }
    
            local pool = Game():GetItemPool()
            for _ = 1, ITEM_COUNT do
                ::reroll::
                local itemId = Resouled:ChooseItemFromPool(Isaac.GetPlayer():GetCollectibleRNG(GLITCH), nil, DEFAULT_COLLECTIBLE)
                local item = Isaac.GetItemConfig():GetCollectible(itemId)

                if item.ID > 0 then -- tmtrainder (negative id) items cannot be blacklisted
                    pool:AddRoomBlacklist(item.ID)
                end

                if 
                not ITEM_BLACKLIST[item.ID] and
                item:IsAvailable() and
                item.Type == ItemType.ITEM_PASSIVE and
                not item:HasTags(ItemConfig.TAG_QUEST) and
                (item:HasTags(ItemConfig.TAG_OFFENSIVE) or item.ID < 0) then
                    table.insert(roomFloorSave.Glitch.Items, {
                        Id = item.ID,
                        Gfx = item.GfxFileName,
                    })
                else goto reroll
                end
            end
            pickup:Morph(pickup.Type, pickup.Variant, GLITCH, true, true, true)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
local function onPickupUpdate(_, pickup)
    local roomFloorSave = SAVE_MANAGER.GetRoomFloorSave(pickup).RerollSave

    if roomFloorSave.Glitch and pickup.SubType ~= GLITCH then
        roomFloorSave.Glitch = nil
        onPickupInit(_, pickup, true) -- REROLL CHOICES
    end

    if roomFloorSave.Glitch and not Resouled.Collectiblextension:IsQuestionMarkItem(pickup) then
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
        local roomFloorSave = SAVE_MANAGER.GetRoomFloorSave(pickup).RerollSave
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
    Resouled.Iterators:IterateOverPlayers(function(player)
        if player:HasCollectible(GLITCH) then
            local playerRunSave = SAVE_MANAGER.GetRunSave(player)
            if playerRunSave.Glitch then
                local itemConfig = Isaac.GetItemConfig()
                local itemToDelete = itemConfig:GetCollectible(playerRunSave.Glitch.Items[playerRunSave.Glitch.ItemIndex])
                
                local history = player:GetHistory()
                for i, historyItem in pairs(history:GetCollectiblesHistory()) do
                    if playerRunSave.Glitch.HistoryTime == historyItem:GetTime() then
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