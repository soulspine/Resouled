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

local function rollItemChoicesWithGfx(count)
    local items = {}

    local pool = Game():GetItemPool()
    for _ = 1, count do
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
            table.insert(items, {
                Id = item.ID,
                Gfx = item.GfxFileName,
            })
        else goto reroll
        end
    end

    return items
end

local function rollItemChoicesWithoutGfx(count)
    local itemIds = {}
    local items = rollItemChoicesWithGfx(count)
    for _, item in pairs(items) do
        table.insert(itemIds, item.Id)
    end
    return itemIds
end

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
            
            roomFloorSave.Glitch.Items = rollItemChoicesWithGfx(ITEM_COUNT)
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

local function onRoomClear()
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        if playerRunSave.Glitch then
            playerRunSave.Glitch.UpdateIndex = 1
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, onRoomClear)

local function onUpdate()
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        if playerRunSave.Glitch then
            local i = playerRunSave.Glitch.UpdateIndex
            if i then
                local glitchData = playerRunSave.Glitch.Data[i]
                if glitchData then
                    print(glitchData.HistoryTime)
                    local historyItemIndex = Resouled.Collectiblextension:GetOldestHistoryItemIndexByTime(player, glitchData.HistoryTime)
                    if historyItemIndex then
                        local collectibleHistory = player:GetHistory():GetCollectiblesHistory()
                        local historyItem = collectibleHistory[historyItemIndex]
                        local itemId = historyItem:GetItemID()
                        ::postRerollReplace::
                        local nextItemId = nil
                        for j, id in ipairs(glitchData.Items) do
                            if id == itemId then
                                nextItemId = glitchData.Items[j % #glitchData.Items + 1] -- +1 because Lua is 1-indexed
                            end
                        end
                        if nextItemId then
                            player:RemoveCollectibleByHistoryIndex(historyItemIndex - 1)
                            player:AddCollectible(nextItemId)
                            collectibleHistory = player:GetHistory():GetCollectiblesHistory() -- refresh variable
                            playerRunSave.Glitch.Data[i].HistoryTime = collectibleHistory[#collectibleHistory]:GetTime()-- update the history time to the new item
                        else -- item must have been rerolled
                            local newItems = rollItemChoicesWithoutGfx(ITEM_COUNT - 1) -- -1 because we already have one item
                            table.insert(newItems, itemId)
                            playerRunSave.Glitch.Data[i].Items = newItems
                            goto postRerollReplace
                        end
                    else
                        -- item was removed from history, so we remove it from the glitch save
                        table.remove(playerRunSave.Glitch.Data, i)
                    end
                    playerRunSave.Glitch.UpdateIndex = playerRunSave.Glitch.UpdateIndex + 1
                else
                    --print(playerRunSave.Glitch.UpdateIndex - 1)
                    playerRunSave.Glitch.UpdateIndex = nil
                end
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param pickup EntityPickup
---@param collider Entity
local function onPickupCollision(_, pickup, collider)
    local player = collider:ToPlayer()
    if player then
        local roomFloorSave = SAVE_MANAGER.GetRoomFloorSave(pickup).RerollSave
        if roomFloorSave.Glitch then
            local playerRunSave = SAVE_MANAGER.GetRunSave(player)

            local itemIndex = math.max(1, roomFloorSave.Glitch.ItemIndex)
            local collectibleToAdd = roomFloorSave.Glitch.Items[itemIndex].Id

            player:AddCollectible(collectibleToAdd) -- we add it here so we can get the history time in this method

            local history = player:GetHistory():GetCollectiblesHistory()
            local historyItem = history[#history] -- last item in history is the one we just added

            if playerRunSave.Glitch == nil then
                playerRunSave.Glitch = {
                    UpdateIndex = nil,
                    Data = {} -- keys don't matter, they are just numerical counting up but values are tables with effects and their tracked data
                }
            end

            local items = {}
            for _, item in pairs(roomFloorSave.Glitch.Items) do
                table.insert(items, item.Id)
            end

            table.insert(playerRunSave.Glitch.Data, {
                Items = items,
                HistoryTime = historyItem:GetTime()
            })

            player:AnimateCollectible(GLITCH)
            SFXManager():Play(PICKUP_SFX)
            pickup:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onPickupCollision, PickupVariant.PICKUP_COLLECTIBLE)