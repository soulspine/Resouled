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
---@param spawner? Entity @Entity that spawned the item
function Resouled:SpawnChaosItemOfQuality(quality, rng, position, spawner)
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

        local entity = Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, Isaac.GetFreeNearPosition(position, 60), Vector.Zero, spawner, randomItem, rng:GetSeed())
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

--- Sets targeet of the familiar to a random enemy in the room. It is stored in its data as an `EntityRef`. \
--- Returns `true` if a target was found, `false` otherwise
---@param familiar EntityFamiliar
function Resouled:SelectRandomEnemyTarget(familiar)
    local data = familiar:GetData()
    local room = Game():GetRoom()
    local entities = room:GetEntities()
    
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
    data.ResouledTarget = validEnemies[math.random(#validEnemies)]
    return true
end

--- Returns the target of the familiar. If the target is not set, returns `nil`
--- @param familiar EntityFamiliar
--- @return EntityNPC | nil
function Resouled:GetEnemyTarget(familiar)
    local data = familiar:GetData()
    if data.ResouledTarget and not data.ResouledTarget.Entity:IsDead() then
        return data.ResouledTarget.Entity:ToNPC()
    else
        return nil
    end
end

---@param familiar EntityFamiliar
function Resouled:ClearEnemyTarget(familiar)
    familiar:GetData().ResouledTarget = nil
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

-- DO NOT TOUCH THIS UNLESS CHANGING SOMETHING IN AddHaloToNpc
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

--- Returns ID of a random item held by the player. If there is no suitable item, returns `nil` \
--- TODO ADD FILTER
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

--- Tries to morph an NPC into a different type, variant and subtype based on its drop RNG.
---@param npc EntityNPC
---@param morphChance number
---@param type EntityType
---@param variant integer
---@param subtype integer
function Resouled:TryEnemyMorph(npc, morphChance, type, variant, subtype)
    local rng = RNG()
    rng:SetSeed(npc:GetDropRNG():GetSeed(), 0)
    if npc.Type == type and npc:IsActiveEnemy() and rng:RandomFloat() < morphChance then
        npc:Morph(type, variant, subtype, npc:GetChampionColorIdx())
    end
end


function Resouled:SetNoReroll(entityPickup)
    local save = SAVE_MANAGER.GetRoomFloorSave(entityPickup)
    save.NoReroll = {
        Type = entityPickup.Type,
        Variant = entityPickup.Variant,
        SubType = entityPickup.SubType
    }
end


---@param pickup EntityPickup
local function onPickupUpdate(_, pickup)
    local noRerollData = SAVE_MANAGER.GetRoomFloorSave(pickup).NoReroll
    if noRerollData and noRerollData.Type ~= pickup.Type and noRerollData.Variant ~= pickup.Variant and noRerollData.SubType ~= pickup.SubType and pickup.SubType ~= CollectibleType.COLLECTIBLE_NULL then
        pickup:Morph(noRerollData.Type, noRerollData.Variant, noRerollData.SubType, false, true, true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

---@param soul ResouledSouls
---@param position Vector
function Resouled:TrySpawnSoulItem(soul, position)
    local soulId = Isaac.GetItemIdByName(soul)
    local runSave = SAVE_MANAGER.GetRunSave()
    if not runSave.Souls then
        runSave.Souls = {}
    end

    if not runSave.Souls[soul] then
        runSave.Souls[soul] = true
        local entity = Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, position, Vector.Zero, nil, soulId, Isaac.GetPlayer(0):GetCollectibleRNG(soulId):GetSeed())
        local pickup = entity:ToPickup()
        if pickup then
            pickup:Morph(pickup.Type, pickup.Variant, pickup.SubType, false, true, true)
            Resouled:SetNoReroll(pickup)
        end
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
function Resouled:IsQuestionMarkItem(pickup)

    if pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
        return nil
    end

    local entitySprite = pickup:GetSprite()
    local animationName = entitySprite:GetAnimation()
    if animationName ~= "Idle" and animationName ~= "ShopIdle" then
        return false
    end

    questionMarkSprite:SetFrame(entitySprite:GetAnimation(),entitySprite:GetFrame())
    for i = -1,1,1 do
		for j = -40,10,3 do
			local qcolor = questionMarkSprite:GetTexel(Vector(i,j), Vector.Zero, 1, 1)
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
function Resouled:TryRevealQuestionMarkItem(pickup)

    if pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
        return nil
    end

    local data = pickup:GetData()
    
    if not data.ResouledRevealed and Resouled:IsQuestionMarkItem(pickup) then
        local sprite = pickup:GetSprite()
        local item = Isaac.GetItemConfig():GetCollectible(pickup.SubType)
        sprite:ReplaceSpritesheet(1, item.GfxFileName)
        sprite:LoadGraphics()
        data.EID_DontHide = true
        data.ResouledRevealed = true
        return true
    else
        return false
    end
end