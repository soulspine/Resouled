local GFX_EMPTY_SOUL_CARD = "gfx/souls/cards/empty.png"
local GFX_BLANK_SOUL_CARD = "gfx/souls/cards/blank.png"
local GFX_NEON_SOUL_CARD = "gfx/souls/cards/neon.png"

local SOUL_PICKUP_VARIANT = Isaac.GetEntityVariantByName("Soul Pickup")

---@types <integer, Sprite>
local soulCardSprites ={
    [1] = {
        Sprite = Sprite(),
        Spritesheet = nil,
        Reload = false,
        FakeTabDuration = 0,
        Selected = false,
        SelectionOngoing = false,
        ExpandValue = 0,
    },
    [2] = {
        Sprite = Sprite(),
        Spritesheet = nil,
        Reload = false,
        FakeTabDuration = 0,
        Selected = false,
        SelectionOngoing = false,
        ExpandValue = 0,
    },
    [3] = {
        Sprite = Sprite(),
        Spritesheet = nil,
        Reload = false,
        FakeTabDuration = 0,
        Selected = false,
        SelectionOngoing = false,
        ExpandValue = 0,
    },
    [4] = {
        Sprite = Sprite(),
        Spritesheet = nil,
        Reload = false,
        FakeTabDuration = 0,
        Selected = false,
        SelectionOngoing = false,
        ExpandValue = 0,
    },
}

---@class ResouledSoul
---@field Name string
---@field Gfx string

---@class ResouledSouls
---@field MONSTRO ResouledSoul
---@field DUKE ResouledSoul
---@field LITTLE_HORN ResouledSoul
---@field BLOAT ResouledSoul
---@field WRATH ResouledSoul
Resouled.Souls = {
    MONSTRO = {
        Name = "Monstro's Soul",
        Gfx = GFX_NEON_SOUL_CARD,
    },
    DUKE = {
        Name = "Duke's Soul",
        Gfx = GFX_NEON_SOUL_CARD,
    },
    LITTLE_HORN = {
        Name = "Little Horn's Soul",
        Gfx = GFX_NEON_SOUL_CARD,
    },
    BLOAT = {
        Name = "Bloat's Soul",
        Gfx = GFX_NEON_SOUL_CARD,
    },
    WRATH = {
        Name = "Wrath's Soul",
        Gfx = GFX_NEON_SOUL_CARD,
    },
}

---@enum ResouledTearEffects
Resouled.TearEffects = {
    CHEESE_GRATER = 0
}

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
    if data.ResouledTarget then
        ---@type EntityNPC
        local npc = data.ResouledTarget.Entity:ToNPC()

        if npc and npc:IsVulnerableEnemy() and npc:IsActiveEnemy() and npc:IsVisible() and not npc:IsDead() then
            return npc
        end
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
    if noRerollData and (noRerollData.Type ~= pickup.Type or noRerollData.Variant ~= pickup.Variant or noRerollData.SubType ~= pickup.SubType) and pickup.SubType ~= CollectibleType.COLLECTIBLE_NULL then
        pickup:Morph(noRerollData.Type, noRerollData.Variant, noRerollData.SubType, false, true, true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

local function prepareSoulContainerOnRunStart(_, isContinued)
    if not isContinued then
        local runSave = SAVE_MANAGER.GetRunSave()
        runSave.Souls = {
            Spawned = {},
            Possessed = {
                [1] = nil,
                [2] = nil,
                [3] = nil,
                [4] = nil
            },
        }
        Resouled:ReloadAllSoulCardSprites()
        Resouled:ResetCardSelection()
        print("Soul container prepared")
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, prepareSoulContainerOnRunStart)

function Resouled:SoulContainerCreated()
    local runSave = SAVE_MANAGER.GetRunSave()
    return runSave.Souls ~= nil
end

---@param soul ResouledSoul
---@return boolean
function Resouled:WasSoulSpawned(soul)
    local runSave = SAVE_MANAGER.GetRunSave()
    return runSave.Souls.Spawned[soul.Name] == true
end

---@param soul ResouledSoul
---@return boolean
function Resouled:IsSoulPossessed(soul)
    local runSave = SAVE_MANAGER.GetRunSave()
    for _, possessedSoul in pairs(runSave.Souls.Possessed) do
        if possessedSoul == soul.Name then
            return true
        end
    end
    return false
end

---@param name string
---@return ResouledSoul | nil
function Resouled:GetSoulByName(name)
    for _, soul in pairs(Resouled.Souls) do
        if soul.Name == name then
            return soul
        end
    end
    return nil
end


---@return table<integer, nil | string>
function Resouled:GetPossessedSouls()
    local runSave = SAVE_MANAGER.GetRunSave()
    return runSave.Souls.Possessed
end


---@return integer
function Resouled:GetPossessedSoulsNum()
    local runSave = SAVE_MANAGER.GetRunSave()
    local num = 0
    for _, soul in pairs(runSave.Souls.Possessed) do
        if soul then
            num = num + 1
        end
    end
    return num
end

---@return integer
function Resouled:GetHighestPossesedSoulIndex()
    local runSave = SAVE_MANAGER.GetRunSave()
    local highestIndex = 0
    for _ = 1, 4 do
        if runSave.Souls.Possessed[_] ~= nil then
            highestIndex = _
        end
    end
    return highestIndex
end

---@return integer
function Resouled:GetLowestPossesedSoulIndex()
    local runSave = SAVE_MANAGER.GetRunSave()
    local lowestIndex = 0
    local foundLowest = false
    for _ = 1, 4 do
        if runSave.Souls.Possessed[_] ~= nil and not foundLowest then
            lowestIndex = _
            foundLowest = true
        end
    end
    return lowestIndex
end

---@param soul ResouledSoul
---@return integer | nil
function Resouled:TryAddSoulToPossessed(soul)
    local runSave = SAVE_MANAGER.GetRunSave()
    for i = 1, 4 do
        if runSave.Souls.Possessed[i] == nil then
            runSave.Souls.Possessed[i] = soul.Name
            
            return i
        end
    end
    return nil
end

--- Index 1-4
---@param index integer
---@return boolean
---@overload fun(self: ModReference, soul: ResouledSoul): boolean
function Resouled:TryRemoveSoulFromPossessed(index)
    local runSave = SAVE_MANAGER.GetRunSave()
    local returnVal = false
    if type(index) == "table" then
        for i, possessedSoul in pairs(runSave.Souls.Possessed) do
            ---@diagnostic disable-next-line: undefined-field
            if possessedSoul == index.Name then
                runSave.Souls.Possessed[i] = nil
                returnVal = true
            end
        end
    else
        if runSave.Souls.Possessed[index] then
            runSave.Souls.Possessed[index] = nil
            returnVal = true
        end
    end
    if returnVal then
        Resouled:ReloadAllSoulCardSprites()
    end
    return returnVal
end

---@param soul ResouledSoul
function Resouled:MarkSoulAsSpawned(soul)
    local runSave = SAVE_MANAGER.GetRunSave()
    runSave.Souls.Spawned[soul.Name] = true
end

---@param soul ResouledSoul
---@param position Vector
---@return boolean
function Resouled:TrySpawnSoulPickup(soul, position)
    if not Resouled:WasSoulSpawned(soul) and Resouled:GetPossessedSoulsNum() ~= 4 and not Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_LOSS) then
        local seed = 0
        while seed == 0 do
            seed = Random()
        end
        local soulPickup = Game():Spawn(EntityType.ENTITY_PICKUP, SOUL_PICKUP_VARIANT, position, Vector.Zero, nil, 0, seed)
        local floorSave = SAVE_MANAGER.GetRoomFloorSave(soulPickup)
        floorSave.Soul = soul
        Resouled:MarkSoulAsSpawned(soul)
        return true
    else
        return false
    end
end

--duration in game frames
---@param duration integer
function Resouled:ForceExpandCard(index, duration)
    soulCardSprites[index].FakeTabDuration = duration
end

function Resouled:SelectCard(index)
    for i, spriteData in pairs(soulCardSprites) do
        if i == index then
            spriteData.Selected = true
        else
            spriteData.Selected = false
        end
        spriteData.SelectionOngoing = true
    end
end

function Resouled:SelectPreviousCard()
    local selected = Resouled:GetSelectedCardIndex()
    if selected then
        local possessedSouls = Resouled:GetPossessedSouls()
        local selection = nil

        while not selection do
            selected = selected - 1
            if selected < 1 then
                selected = 4
            end
            if possessedSouls[selected] then
                selection = selected
            end
            if selected == Resouled:GetSelectedCardIndex() then
                break
            end
        end
        Resouled:SelectCard(selection)
    end
end

function Resouled:SelectNextCard()
    local selected = Resouled:GetSelectedCardIndex()
    if selected then
        local possessedSouls = Resouled:GetPossessedSouls()
        local selection = nil

        while not selection do
            selected = selected + 1
            if selected > 4 then
                selected = 1
            end
            if possessedSouls[selected] then
                selection = selected
            end
            if selected == Resouled:GetSelectedCardIndex() then
                break
            end
        end
        Resouled:SelectCard(selection)
    end
end

function Resouled:ResetCardSelection()
    for _, spriteData in pairs(soulCardSprites) do
        spriteData.Selected = false
        spriteData.SelectionOngoing = false
    end
end

---@return integer | nil
function Resouled:GetSelectedCardIndex()
    for i, spriteData in pairs(soulCardSprites) do
        if spriteData.Selected then
            return i
        end
    end
    return nil
end

function Resouled:GetSelectedCardName()
    local selected = Resouled:GetSelectedCardIndex()
    if selected then
        return Resouled:GetPossessedSouls()[selected]
    end
end

---@param pickup EntityPickup
local function onSoulPickupInit(_, pickup)
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    pickup.GridCollisionClass = GridCollisionClass.COLLISION_OBJECT
    pickup.PositionOffset = Vector(0, -20)
    pickup:GetSprite():Play("Appear", true)
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onSoulPickupInit, SOUL_PICKUP_VARIANT)

---@param pickup EntityPickup
---@param offset Vector
local function onSoulPickupRender(_, pickup, offset)
    local data = pickup:GetData()
    if not data.ResouledLoadedSpritesheet then
        local floorSave = SAVE_MANAGER.GetRoomFloorSave(pickup)
        data.ResouledLoadedSpritesheet = true
        local sprite = pickup:GetSprite()
        sprite:ReplaceSpritesheet(0, floorSave.Soul.Gfx)
        sprite:LoadGraphics()
        if sprite:IsFinished("Appear") then
            sprite:Play("Idle", true)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, onSoulPickupRender, SOUL_PICKUP_VARIANT)

---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
local function onSoulPickupCollision(_, pickup, collider, low)
    local player = collider:ToPlayer()
    if pickup.Variant == SOUL_PICKUP_VARIANT and player then
        local floorSave = SAVE_MANAGER.GetRoomFloorSave(pickup)
        local addedIndex = Resouled:TryAddSoulToPossessed(floorSave.Soul)
        if addedIndex then
            player:AnimatePickup(pickup:GetSprite(), true)
            Game():GetHUD():ShowItemText(floorSave.Soul.Name, Resouled:GetPossessedSoulsNum() .. "/4 souls collected")
            SFXManager():Play(SoundEffect.SOUND_HOLY)
            Resouled:ForceExpandCard(addedIndex, 180)
            Resouled:ReloadAllSoulCardSprites()
            pickup:Remove()
            return true
        else
            return false
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onSoulPickupCollision)

local ANIMATION_HUD_APPEAR = "HudAppear"
local ANIMATION_HUD_IDLE = "HudIdle"
local ANIMATION_HUD_DISAPPEAR = "HudDisappear"
local ANIMATION_HUD_HIDE = "HudHide"
local EVENT_TRIGGER_RESOULED_CARD_FLIP = "ResouledCardFlip"
local SFX_CARD_FLIP = {SoundEffect.SOUND_MENU_NOTE_HIDE, SoundEffect.SOUND_MENU_NOTE_HIDE}
local ANM2_SOUL_CARD = "gfx/soul_card.anm2"
local CARD_MARGIN = 20
local CARD_OFFSET = Vector(0, 18)
local EXAPAND_STEP = 1
local EXPAND_HEIGHT = 7

local function soulCardsHudRender()
    if Game():GetHUD():IsVisible() then
        for i, spriteData in pairs(soulCardSprites) do

            local sprite = spriteData.Sprite

            --print(i, spriteData.Spritesheet, sprite:GetAnimation(), sprite:GetFrame())
            if spriteData.Reload then

                if not sprite:IsLoaded() then
                    sprite:Load(ANM2_SOUL_CARD, true)
                    sprite:Play(ANIMATION_HUD_HIDE, true)
                end

                local runSave = SAVE_MANAGER.GetRunSave()

                if not runSave.Souls then
                    prepareSoulContainerOnRunStart(nil, true)
                end

                local soul = Resouled:GetSoulByName(Resouled:GetPossessedSouls()[i])

                if soul then
                    if soul.Gfx ~= spriteData.Spritesheet then
                        spriteData.Spritesheet = soul.Gfx
                        sprite:ReplaceSpritesheet(0, soul.Gfx)
                        sprite:LoadGraphics()
                    end
                else
                    spriteData.Spritesheet = nil
                end
            end
            spriteData.Reload = false -- reset reload after render is finished
            
            
            if spriteData.Spritesheet then
                local animationName = sprite:GetAnimation()
                
                local screenDimensions = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())
                local w = screenDimensions.X/2 + CARD_MARGIN*(i-2.5)
                local h = CARD_OFFSET.Y + spriteData.ExpandValue

                local targetSelectionHeight = CARD_OFFSET.Y + EXPAND_HEIGHT

                if spriteData.Selected then
                    if h < targetSelectionHeight then
                        h = h + EXAPAND_STEP
                        spriteData.ExpandValue = spriteData.ExpandValue + EXAPAND_STEP
                    end
                else
                    if h > CARD_OFFSET.Y then
                        h = h - EXAPAND_STEP
                        spriteData.ExpandValue = spriteData.ExpandValue - EXAPAND_STEP
                    end
                end
                
                if sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_CARD_FLIP) then
                    SFXManager():Play(SFX_CARD_FLIP[math.random(#SFX_CARD_FLIP)], 1, 10)
                end
                
                if animationName == ANIMATION_HUD_HIDE then
                    if (Resouled:IsAnyonePressingAction(ButtonAction.ACTION_MAP) or spriteData.FakeTabDuration > 0 or spriteData.SelectionOngoing) then
                        sprite.PlaybackSpeed = math.random(40, 100) / 100 -- to make them feel more random, otherwise they are just mega synced and it looks weird
                        sprite:Play(ANIMATION_HUD_APPEAR, true)
                    end
                elseif animationName == ANIMATION_HUD_APPEAR then
                    if sprite:IsFinished(ANIMATION_HUD_APPEAR) then
                        sprite:Play(ANIMATION_HUD_IDLE, true)
                        sprite:SetFrame(math.random(0, 30))
                    end
                elseif animationName == ANIMATION_HUD_IDLE then
                    if not (Resouled:IsAnyonePressingAction(ButtonAction.ACTION_MAP) or spriteData.FakeTabDuration > 0 or spriteData.SelectionOngoing) then
                        sprite:Play(ANIMATION_HUD_DISAPPEAR, true)
                    end
                elseif animationName == ANIMATION_HUD_DISAPPEAR then
                    if sprite:IsFinished(ANIMATION_HUD_DISAPPEAR) then
                        sprite:Play(ANIMATION_HUD_HIDE, true)
                    end
                end

                sprite:Update()
                sprite:Render(Vector(w, h), Vector.Zero, Vector.Zero)
            end

            if spriteData.FakeTabDuration > 0 then
                spriteData.FakeTabDuration = spriteData.FakeTabDuration - 1
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, soulCardsHudRender)

function Resouled:ReloadAllSoulCardSprites()
    for _, spriteData in pairs(soulCardSprites) do
        spriteData.Reload = true
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Resouled.ReloadAllSoulCardSprites)

---@param action ButtonAction
function Resouled:IsAnyonePressingAction(action)
    local isPressed = false
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        if Input.IsActionPressed(action, player.ControllerIndex) then
            isPressed = true
        end
    end)
    return isPressed
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

--- Applies a custom tear effect to the tear entity
--- @param tear EntityTear | EntityLaser
--- @param effect ResouledTearEffects
function Resouled:ApplyCustomTearEffect(tear, effect)
    local data = tear:GetData()
    if data.ResouledTearEffect then
        data.ResouledTearEffect = data.ResouledTearEffect | effect
    else
        data.ResouledTearEffect = effect
    end
end

--- Returns an bitmask representing custom tear effects applied to the tear entity
--- @param tear EntityTear | EntityLaser
function Resouled:GetCustomTearEffects(tear)
    return tear:GetData().ResouledTearEffect
end

--- Applies a cooldown so that the custom tear effect can't be applied again for the specified duration
--- @param npc EntityNPC
--- @param effect ResouledTearEffects
--- @param duration integer
function Resouled:ApplyCustomTearEffectCooldown(npc, effect, duration)
    local data = npc:GetData()
    if data.ResouledTearEffectCooldown then
        data.ResouledTearEffectCooldown[effect] = duration
    else
        data.ResouledTearEffectCooldown = {
            [effect] = duration
        }
    end
end

--- Returns whether the custom tear effect is on cooldown
--- @param npc EntityNPC
--- @param effect ResouledTearEffects
--- @return boolean
function Resouled:IsCustomTearEffectOnCooldown(npc, effect)
    local data = npc:GetData()
    if data.ResouledTearEffectCooldown then
        return data.ResouledTearEffectCooldown[effect] > 0
    else
        return false
    end
end

---@param npc EntityNPC
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    local data = npc:GetData()
    if data.ResouledTearEffectCooldown then
        for effect, cooldown in pairs(data.ResouledTearEffectCooldown) do
            if cooldown > 0 then
                data.ResouledTearEffectCooldown[effect] = cooldown - 1
            end
        end
    end
end)

--- Returns a table of all doors in the room
--- @param room? Room defaults to current room if not specified
--- @return GridEntityDoor[]
function Resouled:GetRoomDoors(room)
    local doors = {}
    local room = room or Game():GetRoom()
    for i = DoorSlot.LEFT0, DoorSlot.NUM_DOOR_SLOTS - 1  do
        local door = room:GetDoor(i)
        if door then
            table.insert(doors, door)
        end
    end
    return doors
end

---@param position Vector
---@return GridEntityDoor | nil
function Resouled:GetClosestDoor(position)
    local doors = Resouled:GetRoomDoors()
    local closestDoor = nil
    for _, door in ipairs(doors) do
        if not closestDoor or position:Distance(door.Position) < position:Distance(closestDoor.Position) then
            closestDoor = door
        end
    end
    return closestDoor
end

---@param player EntityPlayer
function Resouled:IsPlayingPickupAnimation(player)
    local sprite = player:GetSprite()
    local animationName = sprite:GetAnimation()
    return animationName == "PickupWalkUp"
    or animationName == "PickupWalkDown"
    or animationName == "PickupWalkLeft"
    or animationName == "PickupWalkRight"
end

---@param player EntityPlayer
---@param collectibleId CollectibleType
---@return ActiveSlot | nil
function Resouled:GetCollectibleActiveSlot(player, collectibleId)
    local activeSlot = nil
    for i = 0, ActiveSlot.SLOT_POCKET2 do
        local item = player:GetActiveItem(i)
        if item and item == collectibleId then
            activeSlot = i
            break
        end
    end
    return activeSlot
end

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    ---@param pickup EntityPickup
    Resouled:IterateOverRoomEntities(function(pickup)
        local data = pickup:GetData()
        if data.Soul then
            local font = Font()
            if not font:IsLoaded() then 
                font:Load("font/terminus.fnt")
            end
            font:DrawString(data.Soul, Isaac.WorldToRenderPosition(pickup.Position).X, Isaac.WorldToRenderPosition(pickup.Position).Y - 50, KColor(1, 1 ,1 ,1), 1, true)
        end
    end)
end)

---@return Vector
function Resouled:GetScreenDimensions()
    return Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())
end

---@return integer
function Resouled:NewSeed()
    local seed = 0
    while seed == 0 do
        seed = Random()
    end
    return seed
end

---@param pedestal Entity
---@param variant? PickupVariant
---@param subtype? integer
function Resouled:ChangePedestalShopPrice(pedestal, newPrice, variant, subtype)
    if variant == nil and subtype == nil then
        if pedestal.Type == EntityType.ENTITY_PICKUP then
            if pedestal:ToPickup().Price ~= 0 and pedestal:ToPickup():IsShopItem() then
                pedestal:ToPickup():GetData().ChangedPrice = true
                pedestal:ToPickup():GetData().NewPrice = newPrice
            end
        end
    elseif variant ~= nil and subtype == nil then
        if pedestal.Type == EntityType.ENTITY_PICKUP and pedestal.Variant == variant then
            if pedestal:ToPickup().Price ~= 0 and pedestal:ToPickup():IsShopItem() then
                pedestal:ToPickup():GetData().ChangedPrice = true
                pedestal:ToPickup():GetData().NewPrice = newPrice
            end
        end
    elseif variant ~= nil and subtype ~= nil then
        if pedestal.Type == EntityType.ENTITY_PICKUP and pedestal.Variant == variant and pedestal.SubType == subtype then
            if pedestal:ToPickup().Price ~= 0 and pedestal:ToPickup():IsShopItem() then
                pedestal:ToPickup():GetData().ChangedPrice = true
                pedestal:ToPickup():GetData().NewPrice = newPrice
            end
        end
    end
end

---@param pedestal EntityPickup
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pedestal)
    if pedestal:GetData().ChangedPrice then
        pedestal:ToPickup().Price = pedestal:GetData().NewPrice
    end
end)