local GFX_CARD_NORMAL = "gfx/souls/cards/card.png"
local GFX_CARD_CURSED = "gfx/souls/cards/card_cursed.png"
local GFX_CARD_SOUL = "gfx/souls/cards/card_soul.png"

local SOUL_PICKUP_VARIANT = Isaac.GetEntityVariantByName("Soul Pickup")

---@class ResouledSoul
---@field Name string
---@field Gfx string

--- ADD NEW SOULS HERE
---@class ResouledSouls
---@field MONSTRO ResouledSoul
---@field DUKE ResouledSoul
---@field LITTLE_HORN ResouledSoul
---@field BLOAT ResouledSoul
---@field WRATH ResouledSoul
---@field WIDOW ResouledSoul
---@field CURSED_HAUNT ResouledSoul
---@field THE_BONE ResouledSoul
---@field THE_CHEST ResouledSoul
Resouled.Souls = {
    MONSTRO = {
        Name = "Monstro's Soul",
        Gfx = GFX_CARD_NORMAL,
    },
    DUKE = {
        Name = "Duke's Soul",
        Gfx = GFX_CARD_NORMAL,
    },
    LITTLE_HORN = {
        Name = "Little Horn's Soul",
        Gfx = GFX_CARD_NORMAL,
    },
    BLOAT = {
        Name = "Bloat's Soul",
        Gfx = GFX_CARD_NORMAL,
    },
    WRATH = {
        Name = "Wrath's Soul",
        Gfx = GFX_CARD_NORMAL,
    },
    WIDOW = {
        Name = "Widow's Soul",
        Gfx = GFX_CARD_NORMAL,
    },
    CURSED_HAUNT = {
        Name = "Cursed Haunt's Soul",
        Gfx = GFX_CARD_CURSED,
    },
    THE_BONE = {
        Name = "Bone's Soul",
        Gfx = GFX_CARD_SOUL,
    },
    THE_CHEST = {
        Name = "Mimic's Soul",
        Gfx = GFX_CARD_NORMAL,
    }
}

--- THESE HANDLE SOUL CARDS IN THE HUD
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
    if not Resouled:WasSoulSpawned(soul) and Resouled:GetPossessedSoulsNum() ~= 4 and not Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_SOULLESS) then
        local soulPickup = Game():Spawn(EntityType.ENTITY_PICKUP, SOUL_PICKUP_VARIANT, position, Vector.Zero, nil, 0, Resouled:NewSeed())
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
local CARD_MARGIN = 26
local CARD_OFFSET = Vector(0, 18)
local EXAPAND_STEP = 1
local EXPAND_HEIGHT = 7

local function soulCardsHudRender()
    if Game():GetHUD():IsVisible() then
        for i, spriteData in pairs(soulCardSprites) do

            local sprite = spriteData.Sprite
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
