---@class CollectiblextensionModule
local collectiblextension = {}

--- Returns a table where numerical keys represent count
--- of non-hidden, non-quest items of the corresponding quality that player currently possesses \
--- Access those fields by `table[0]` / `table[1]` / `table[2]` / `table[3]` / `table[4]`
---@param player EntityPlayer
---@return table
function collectiblextension:GetCollectibleQualityNum(player)
    local qCount = {
        [0] = 0,
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0
    }
    local itemConfig = Isaac.GetItemConfig()

    ---@diagnostic disable-next-line: undefined-field
    for i = 1, itemConfig:GetCollectibles().Size - 1 do
        local item = itemConfig:GetCollectible(i)
        if item and not item.Hidden and item:IsAvailable() and not item:HasTags(ItemConfig.TAG_QUEST) and player:HasCollectible(i) then
            qCount[item.Quality] = qCount[item.Quality] + player:GetCollectibleNum(i)
        end
    end

    return qCount
end

--- Whether a specified collectible is held by any player in the game
---@param collectibleId CollectibleType
---@return boolean
function collectiblextension:CollectiblePresent(collectibleId)
    local itemPresent = false
    local game = Game()
    for i = 0, game:GetNumPlayers() - 1 do
        local player = game:GetPlayer(i)
        if player:HasCollectible(collectibleId) then
            itemPresent = true
        end
    end
    return itemPresent
end

--- Returns number representing total number of occurences of a collectible in all players' inventories
--- @param collectibleId CollectibleType
--- @return integer
function collectiblextension:TotalCollectibleNum(collectibleId)
    local totalNum = 0

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Game():GetPlayer(i)
        if player:HasCollectible(collectibleId) then
            totalNum = totalNum + player:GetCollectibleNum(collectibleId)
        end
    end
    return totalNum
end

--- Returns a table of all items held by the player where keys are collectible IDs and values are their counts
--- @param player EntityPlayer
--- @return table
function collectiblextension:GetPlayerCollectibles(player)
    local items = {}
    local itemConfig = Isaac.GetItemConfig()
    for i = 1, #itemConfig:GetCollectibles() do
        local collectible = itemConfig:GetCollectible(i)
        if collectible and not collectible.Hidden and not collectible:HasTags(ItemConfig.TAG_QUEST) then
            items[i] = player:GetCollectibleNum(i)
        end
    end
    return items
end

--- Returns ID of a random item held by the player. If there is no suitable item, returns `nil` \
--- TODO ADD FILTER
--- @param player EntityPlayer
--- @param rng RNG
--- @return CollectibleType | nil
function collectiblextension:ChooseRandomPlayerItemID(player, rng)
    local items = {}
    local itemConfig = Isaac.GetItemConfig()
    for i = 1, #itemConfig:GetCollectibles() do
        local collectible = itemConfig:GetCollectible(i)
        if collectible
        and not collectible.Hidden
        and not collectible:HasTags(ItemConfig.TAG_QUEST)
        and player:HasCollectible(i)
        and collectible.ID ~= player:GetActiveItem(ActiveSlot.SLOT_POCKET)
        and collectible.ID ~= player:GetActiveItem(ActiveSlot.SLOT_POCKET2)
        then
            table.insert(items, i)
        end
    end

    if #items == 0 then
        return nil
    else
        return items[rng:RandomInt(#items) + 1]
    end
end

-- THIS IS FROM EID'S CODE BUT MODIFIED A BIT
-- https://github.com/wofsauge/External-Item-Descriptions/blob/9908279ec579f2b1ec128c9c513e4cb3c3138a93/main.lua#L221
local questionMarkSprite = Sprite()
questionMarkSprite:Load("gfx/005.100_collectible.anm2",true)
questionMarkSprite:ReplaceSpritesheet(1,"gfx/items/collectibles/questionmark.png")
questionMarkSprite:LoadGraphics()

--- Checks whether the pickup is a question mark item. \
--- If pickup is not a collectible, returns `nil`
---@param pickup EntityPickup
---@return boolean | nil
function collectiblextension:IsQuestionMarkItem(pickup)

    

    if pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
        return nil
    end

    local entitySprite = pickup:GetSprite()
    local animationName = entitySprite:GetAnimation()
    if animationName ~= "Idle" and animationName ~= "ShopIdle" then
        return false
    end

    local offsetY = 0
    local overlayFrame = entitySprite:GetOverlayFrame()

    if overlayFrame == 4 -- this is so stupid XD
    or overlayFrame == 5
    or overlayFrame == 6
    or overlayFrame == 7
    or overlayFrame == 8
    or overlayFrame == 9
    or overlayFrame == 10
    or overlayFrame == 12
    or overlayFrame == 13
    or overlayFrame == 14
    or overlayFrame == 16
    or overlayFrame == 17
    or overlayFrame == 18
    or overlayFrame == 19 then
        offsetY = -5
    elseif overlayFrame == 11 then
        offsetY = -8
    end

    questionMarkSprite:SetFrame(entitySprite:GetAnimation(),entitySprite:GetFrame())

    for i = -1,1,1 do
		for j = -40,10,3 do
			local qcolor = questionMarkSprite:GetTexel(Vector(i,j - offsetY), Vector.Zero, 1, 1)
			local ecolor = entitySprite:GetTexel(Vector(i,j), Vector.Zero, 1, 1)
			if qcolor.Red ~= ecolor.Red or qcolor.Green ~= ecolor.Green or qcolor.Blue ~= ecolor.Blue then
				-- it is not same with question mark sprite
				return false
			end
		end
	end
    return true
end

--- Tries to reveal a question mark item. \
--- If it succeeds, returns `true`, otherwise `false` \
--- If pickup is not a collectible, returns `nil`
---@param pickup EntityPickup
---@return boolean | nil
function collectiblextension:TryRevealQuestionMarkItem(pickup)

    if pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
        return nil
    end

    local data = pickup:GetData()
    
    if not data.QuestionmarkRevealed and collectiblextension:IsQuestionMarkItem(pickup) then
        local sprite = pickup:GetSprite()
        local item = Isaac.GetItemConfig():GetCollectible(pickup.SubType)
        sprite:ReplaceSpritesheet(1, item.GfxFileName)
        sprite:LoadGraphics()
        data.EID_DontHide = true
        data.QuestionmarkRevealed = true
        return true
    else
        return false
    end
end

--- Returns the index of a history item from the player's history by time or `nil` if not found.
---@param player EntityPlayer
---@param time integer
---@param posOffset? integer
---@return integer | nil
function collectiblextension:GetOldestHistoryItemIndexByTime(player, time, posOffset)
    posOffset = posOffset or 0
    local posOffsetCounter = 0
    local history = player:GetHistory()
    for i, historyItem in pairs(history:GetCollectiblesHistory()) do
        if historyItem:GetTime() == time then
            if posOffsetCounter == posOffset then
                return i
            else
                posOffsetCounter = posOffsetCounter + 1
            end
        elseif historyItem:GetTime() > time then -- History is sorted by time, so if we found a time greater than the one we are looking for, we can stop searching
            break
        end
    end
    return nil
end

--- Returns a table of history items from the player's history by time.
---@param player EntityPlayer
---@param time integer
---@return HistoryItem[]
function collectiblextension:GetHistoryItemsByTime(player, time)
    local history = player:GetHistory()
    local items = {}
    for i, historyItem in ipairs(history:GetCollectiblesHistory()) do
        if historyItem:GetTime() == time then
            table.insert(items, historyItem)
        elseif historyItem:GetTime() > time then -- History is sorted by time, so if we found a time greater than the one we are looking for, we can stop searching
            break
        end
    end
    return items
end

--- Returns the index of a history item from the player's history by time and item ID or `nil` if not found.
---@param player EntityPlayer
---@param time integer
---@param itemId CollectibleType | integer
---@return integer | nil
function collectiblextension:GetHistoryIndexByTimeAndItemId(player, time, itemId)
    local history = player:GetHistory()
    for i, historyItem in ipairs(history:GetCollectiblesHistory()) do
        if historyItem:GetTime() == time and historyItem:GetItemID() == itemId then
            return i
        elseif historyItem:GetTime() > time then -- History is sorted by time, so if we found a time greater than the one we are looking for, we can stop searching
            break
        end
    end
    return nil
end 

return collectiblextension