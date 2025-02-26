-- Iterates over all players in the game and calls the callback function with first argument being `player`.
-- Passes all additional arguments to the callback function in the same order as they were passed to this function.
---@param callback function
function Resouled:IterateOverPlayers(callback, ...)
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        callback(player, ...)
    end
end

--- Iterates over all entities in the room and calls the callback function with first argument being `entity`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback function
function Resouled:IterateOverRoomEntities(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        callback(entity, ...)
    end
end

--- Spawns a random chaos pool item of the specified quality at specified position
---@param quality integer
---@param rng RNG
---@param position Vector
function Resouled:SpawnChaosItemOfQuality(quality, rng, position)
    local itemConfig = Isaac.GetItemConfig()
    local itemPool = Game():GetItemPool()
    local validItems = {}
    
    for i = 1, #itemConfig:GetCollectibles() do
        local item = itemConfig:GetCollectible(i)
        if item and item.Quality == quality and not item.Hidden and item:IsAvailable() and not item:HasTags(ItemConfig.TAG_QUEST) then
            table.insert(validItems, i)
        end
    end
    
    ::reroll::

    if #validItems > 0 then
        local randomItem = validItems[rng:RandomInt(#validItems) + 1]
        
        if not itemPool:RemoveCollectible(randomItem) then
            --remove raindomItem from valiudItems
            for i = 1, #validItems do
                if validItems[i] == randomItem then
                    table.remove(validItems, i)
                    break
                end
            end
            goto reroll
        end

        local entity = Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, Isaac.GetFreeNearPosition(position, 60), Vector.Zero, nil, randomItem, rng:GetSeed())
        rng:Next()
        return entity

    end
    return nil
end

--- Grants Guppy transformation to specified player
---@param player EntityPlayer
function Resouled:GrantGuppyTransformation(player)
    if not player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY)
    then
        for _ = 1, 4 do
            player:AddTrinket(TrinketType.TRINKET_KIDS_DRAWING, true)
        end

        player:TryRemoveTrinket(TrinketType.TRINKET_KIDS_DRAWING)
        player:TryRemoveTrinket(TrinketType.TRINKET_KIDS_DRAWING)
    end
end

--- Returns effective HP of the player. \
--- Every half a `red` / `soul` / `black` heart counts as 1 HP. \
--- Every `bone` / `rotten` / `eternal` heart counts as 1 HP.
---@param player EntityPlayer
---@return integer
function Resouled:GetEffectiveHP(player)
    -- TODO
    local red = player:GetHearts()
    local soul = player:GetSoulHearts() -- black hearts are counted in
    local bone = player:GetBoneHearts()
    local rotten = player:GetRottenHearts() -- we substract this because rotten hearts are counted in red hearts as well
    local eternal = player:GetEternalHearts()
    return red + soul + bone - rotten + eternal
end

-- Returns exactly how much red HP player has
---@param player EntityPlayer
---@return integer
function Resouled:GetEffectiveRedHP(player)
    return player:GetHearts() - 2*player:GetRottenHearts()
end

--- Returns exactly how much soul HP player has
---@param player EntityPlayer
---@return integer
function Resouled:GetEffectiveSoulHP(player)
    return math.max(player:GetSoulHearts() - 2*player:GetBlackHearts(), 0)
end

--- Returns exactly how much black HP player has
---@param player EntityPlayer
---@return integer
function Resouled:GetEffectiveBlackHP(player)
    return player:GetSoulHearts() - Resouled:GetEffectiveSoulHP(player)
end

--- Returns number representing player's in-game fire rate \
---@param player EntityPlayer
---@return number
function Resouled:GetFireRate(player)
    return 30 / (player.MaxFireDelay + 1)
end

--- Returns player's theoretical DPS if all tears hit a target
--- @param player EntityPlayer
--- @return number
function Resouled:GetDPS(player)
    return player.Damage * Resouled:GetFireRate(player)
end

--- Returns a table where numerical keys represent count
--- of non-hidden, non-quest items of the corresponding quality that player currently possesses \
--- Access those fields by `table[0]` / `table[1]` / `table[2]` / `table[3]` / `table[4]`
---@param player EntityPlayer
---@return table
function Resouled:GetCollectibleQualityNum(player)
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
function Resouled:CollectiblePresent(collectibleId)
    local itemPresent = false
    Resouled:IterateOverPlayers(function(player)
        if player:HasCollectible(collectibleId) then
            itemPresent = true
        end
    end)
    return itemPresent
end

--- Returns number representing total number of occurences of a collectible in all players' inventories
--- @param collectibleId CollectibleType
--- @return integer
function Resouled:TotalCollectibleNum(collectibleId)
    local totalNum = 0
    Resouled:IterateOverPlayers(function(player)
        totalNum = totalNum + player:GetCollectibleNum(collectibleId)
    end)
    return totalNum
end

--- Sets targeet of the familiar to a random enemy in the room. It is stored in the room save data as an `EntityRef`. \
--- Returns `true` if a target was found, `false` otherwise
---@param familiar EntityFamiliar
function Resouled:SelectRandomEnemyTarget(familiar)
    local roomSave = SAVE_MANAGER.GetRoomSave(familiar)
    local room = Game():GetRoom()
    local entities = room:GetEntities()
    local rng = RNG()
    rng:SetSeed(familiar.InitSeed, 0)
    
    local validEnemies = {}
            
    for i = 1, entities.Size do
        local entity = entities:Get(i)
        if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() and entity:IsVisible() then
            table.insert(validEnemies, EntityRef(entity))
        end
    end
    if #validEnemies == 0 then
        return false
    else

    end

    ---@type EntityRef
    roomSave.Target = validEnemies[math.random(#validEnemies)]
    return true
end

--- Returns the target of the familiar. If the target is not set, returns `nil`
--- @param familiar EntityFamiliar
--- @return EntityNPC | nil
function Resouled:GetEnemyTarget(familiar)
    local roomSave = SAVE_MANAGER.GetRoomSave(familiar)
    if roomSave.Target and not roomSave.Target.Entity:IsDead() then
        return roomSave.Target.Entity:ToNPC()
    else
        return nil
    end
end

---@param familiar EntityFamiliar
function Resouled:ClearEnemyTarget(familiar)
    local roomSave = SAVE_MANAGER.GetRoomSave(familiar)
    roomSave.Target = nil
end

-- borrowed from epiphany
---@param filter? fun(door: GridEntityDoor): boolean? @Filter which doors should be closed
function Resouled:ForceShutDoors(filter)
	local room = Game():GetRoom()
	for doorSlot = DoorSlot.LEFT0, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local door = room:GetDoor(doorSlot)
		if door
			and door:IsOpen()
			and door:GetSprite():GetAnimation() ~= door.CloseAnimation
			and (filter == nil or filter(door) == true)
		then
			door:Close(true)
			door:GetSprite():Play(door.CloseAnimation, true)
			door:SetVariant(DoorVariant.DOOR_HIDDEN)
			local grid_save = SAVE_MANAGER.GetRoomFloorSave(room:GetGridPosition(door:GetGridIndex()))
			if not grid_save.HasForcedShut then
				grid_save.HasForcedShut = true
			else
				door:GetSprite():SetLastFrame()
			end
		end
	end
end

---@param filter? fun(door: GridEntityDoor): boolean? @Filter which doors should be opened
function Resouled:ForceOpenDoors(filter)
    local room = Game():GetRoom()
    for doorSlot = DoorSlot.LEFT0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        local door = room:GetDoor(doorSlot)
        if door
            and not door:IsOpen()
            and door:GetSprite():GetAnimation() == door.CloseAnimation
            and (filter == nil or filter(door) == true)
        then
            door:Open()
            door:GetSprite():Play(door.OpenAnimation, true)
            door:SetVariant(DoorVariant.DOOR_UNLOCKED)
            local grid_save = SAVE_MANAGER.GetRoomFloorSave(room:GetGridPosition(door:GetGridIndex()))
            if grid_save.HasForcedShut then
                grid_save.HasForcedShut = false
            else
                door:GetSprite():SetLastFrame()
            end
        end
    end
end

function Resouled:GetRoomPickupsValue()
    local roomValue = 0
    ---@param entity Entity
    Resouled:IterateOverRoomEntities(function(entity)
        local pickup = entity:ToPickup()
        if pickup and pickup:IsShopItem() and pickup.Price > 0 then
            roomValue = roomValue + pickup.Price
        end
    end)
    return roomValue
end

--- Adds a following halo to the specified npc.
---@param npc EntityNPC
---@param haloSubtype integer
---@param scale Vector
---@param offset Vector
function Resouled:AddHaloToNpc(npc, haloSubtype, scale, offset)
    local haloEntity = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, npc.Position, Vector(0, 0), npc, haloSubtype, 0)
    local halo = haloEntity:ToEffect()

    if not halo then
        return nil
    end

    halo.Parent = npc
    halo.SpriteScale = scale
    npc:GetData().Halo = halo
    halo:GetData().Offset = offset
    return halo
end


Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE,
---@param npc EntityNPC
function(_, npc)
    local data = npc:GetData()
    if data.Halo then
        ---@type EntityEffect
        local halo = data.Halo
        halo.Position = halo.Parent.Position + halo:GetData().Offset
    end
end)

--- Returns a table of all items held by the player where keys are collectible IDs and values are their counts
--- @param player EntityPlayer
--- @return table
function Resouled:GetPlayerItems(player)
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

--- @param player EntityPlayer
--- @param rng RNG
--- @return CollectibleType | nil
function Resouled:ChooseRandomPlayerItemID(player, rng)
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