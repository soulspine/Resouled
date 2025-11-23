local game = Game()

local Soul = Resouled.Stats.Soul

local DEFAULT_WEIGHT = 1

local SOULS_UI_TEXT_COLOR = KColor(1, 1, 1, 0.7)

COLLIDER_COLOR_R0 = 0.5
COLLIDER_COLOR_G0 = 0.5
COLLIDER_COLOR_B0 = 0.5
COLLIDER_COLOR_DURATION = 10
COLLIDER_COLOR_PRIORITY = 1
COLLIDER_COLOR_FADEOUT = true
COLLIDER_COLOR_SHARE = true

local basicSpawnLookupTable = {} -- NOT STATIC, POPULATED AT RUNTIME by Resouled:AddNewBasicSoulSpawnRule

local font = Font()
font:Load("font/pftempestasevencondensed.fnt")

local ICON_DIMENSIONS = 16
local iconSprite = Sprite()
iconSprite:Load("gfx/ui/soul_icon.anm2", true)
iconSprite:Play(iconSprite:GetDefaultAnimation(), true)
iconSprite:SetFrame(1)

local cachedSoulsNum = 0

local HUD_COLLECT_DISPLAY_TIME = 100
local HUD_DEFAULT_FADEOUT_TIME = 10
local HUD_OPACITY_STEP = 0.08

local hudDisplayTimer = 0
local hudOpacity = 0

---@param duration? integer
function Resouled:DisplaySoulsHud(duration)
    hudDisplayTimer = duration or HUD_DEFAULT_FADEOUT_TIME
end

---@param entity Entity
---@param hook InputHook
---@param action ButtonAction
local function onInput(_, entity, hook, action)
    if entity
        and action == ButtonAction.ACTION_MAP
        and Input.IsActionPressed(action, entity:ToPlayer().ControllerIndex)
    then
        hudDisplayTimer = HUD_DEFAULT_FADEOUT_TIME
    end
end
Resouled:AddCallback(ModCallbacks.MC_INPUT_ACTION, onInput, InputHook.IS_ACTION_PRESSED)

local function hudRenderer()
    if hudDisplayTimer > 0 then
        hudOpacity = math.min(hudOpacity + HUD_OPACITY_STEP, 1)
        hudDisplayTimer = hudDisplayTimer - 1
    else
        hudOpacity = math.max(hudOpacity - HUD_OPACITY_STEP, 0)
    end


    if game:GetHUD():IsVisible() and hudOpacity > 0 then
        local screenWidth = Isaac.GetScreenWidth()
        local screenHeight = Isaac.GetScreenHeight()

        local text = tostring(cachedSoulsNum)
        local xGap = ICON_DIMENSIONS / 4

        local textColor = SOULS_UI_TEXT_COLOR
        textColor.Alpha = hudOpacity

        font:DrawString(
            text,
            screenWidth / 2 + xGap,
            screenHeight - ICON_DIMENSIONS,
            textColor
        )

        iconSprite.Color.A = hudOpacity
        iconSprite:Render(Vector(screenWidth / 2 - xGap, screenHeight - ICON_DIMENSIONS / 2))
    end
end
Resouled:AddCallback(ModCallbacks.MC_HUD_RENDER, hudRenderer)

---@param isContinued boolean
local function createSoulsContainerOnRunStart(_, isContinued)
    local runSave = Resouled.SaveManager.GetRunSave()
    if not isContinued then
        runSave.Souls = {
            Spawned = {},
            Possessed = 0,
        }
        cachedSoulsNum = 0
    else
        if runSave.Souls then
            cachedSoulsNum = runSave.Souls.Possessed
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, createSoulsContainerOnRunStart)

---@param soul ResouledSoul
function Resouled:WasSoulSpawned(soul)
    local runSave = Resouled.SaveManager.GetRunSave()
    if runSave.Souls and runSave.Spawned and runSave.Spawned[soul] > 0 then
        return true
    end
    return false
end

---@return integer
function Resouled:GetPossessedSoulsNum()
    local runSave = Resouled.SaveManager.GetRunSave()
    return (runSave.Souls) and runSave.Souls.Possessed or 0
end

---@param num integer
function Resouled:SetPossessedSoulsNum(num)
    local runSave = Resouled.SaveManager.GetRunSave()
    if runSave.Souls then
        runSave.Souls.Possessed = num
        cachedSoulsNum = num
    end
end

---@param soul ResouledSoul
---@param position Vector
---@param weight? integer -- default 1
---@return boolean
function Resouled:TrySpawnSoulPickup(soul, position, weight)
    if Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.SoulsBeGone) then return false end
    local runSave = Resouled.SaveManager.GetRunSave()
    if
        runSave.Souls and
        not runSave.Souls.Spawned[tostring(soul)] and
        not Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_SOULLESS) then
        local pickup = game:Spawn(EntityType.ENTITY_PICKUP, Soul.Variant, position, Vector.Zero, nil, Soul.SubType,
            Resouled:NewSeed())
        if weight and weight ~= DEFAULT_WEIGHT then
            local pickupSave = Resouled.SaveManager.GetRoomFloorSave(pickup)
            pickupSave.SoulWeight = weight
        end
        runSave.Souls.Spawned[tostring(soul)] = true

        local buffID = Resouled:TryGetBuffTiedToSpecialSoul(soul)
        if buffID then
            Resouled.AfterlifeShop:AddSpecialBuffToSpawn(buffID)
        end

        return true
    else
        return false
    end
end

---@param pickup EntityPickup
local function onSoulPickupInit(_, pickup)
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    pickup:GetSprite():Play("Idle", true)
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onSoulPickupInit, Soul.Variant)

---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
local function onSoulPickupCollision(_, pickup, collider, low)
    if pickup.SubType == Soul.SubType then
        if collider.Type == EntityType.ENTITY_PLAYER then
            local runSave = Resouled.SaveManager.GetRunSave()
            if runSave.Souls then
                local pickupSave = Resouled.SaveManager.GetRoomFloorSave(pickup)
                local weight = pickupSave.SoulWeight or DEFAULT_WEIGHT
                runSave.Souls.Possessed = runSave.Souls.Possessed + weight
                cachedSoulsNum = runSave.Souls.Possessed
            end
            Soul:PlayPickupSound()

            local color = collider.Color
            collider:SetColor(
                Color(color.R, color.G, color.B, color.A, COLLIDER_COLOR_R0, COLLIDER_COLOR_G0, COLLIDER_COLOR_B0),
                COLLIDER_COLOR_DURATION,
                COLLIDER_COLOR_PRIORITY,
                COLLIDER_COLOR_FADEOUT,
                COLLIDER_COLOR_SHARE
            )

            Resouled:DisplaySoulsHud(HUD_COLLECT_DISPLAY_TIME)

            local save = Resouled.StatTracker:GetSave()
            if not save[Resouled.StatTracker.Fields.SoulsCollected] then save[Resouled.StatTracker.Fields.SoulsCollected] = 0 end
            save[Resouled.StatTracker.Fields.SoulsCollected] = save[Resouled.StatTracker.Fields.SoulsCollected] + 1

            pickup:Remove()

            if Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.NoSoulChallenge) then Game():End(Ending.DIE) end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onSoulPickupCollision, Soul.Variant)

---@param type integer
---@param variant integer
---@param subtype? integer
local function makeLookupTableKey(type, variant, subtype)
    if subtype then
        return string.format("%d_%d_%d", type, variant, subtype)
    else
        return string.format("%d_%d", type, variant)
    end
end

---@param type EntityType
---@param variant integer
---@param subtype? integer
---@param soul ResouledSoul
---@param weight? integer -- default 1
---@param filter? function -- default nil
function Resouled:AddNewBasicSoulSpawnRule(type, variant, subtype, soul, weight, filter)
    weight = weight or DEFAULT_WEIGHT
    local key
    if subtype then
        key = makeLookupTableKey(type, variant, subtype)
    else
        key = makeLookupTableKey(type, variant)
    end

    if not basicSpawnLookupTable[key] then
        basicSpawnLookupTable[key] = {}
    end

    table.insert(
        basicSpawnLookupTable[key],
        {
            Soul = soul,
            Weight = weight,
            Filter = filter,
        }
    )
end

---@param npc EntityNPC
local function basicSoulSpawnHandler(_, npc)
    local key = makeLookupTableKey(npc.Type, npc.Variant, npc.SubType)
    local keyNoSubType = makeLookupTableKey(npc.Type, npc.Variant)
    local spawnRules = basicSpawnLookupTable[key]
    local spawnRulesNoSubType = basicSpawnLookupTable[keyNoSubType]
    if spawnRules then
        for _, rule in ipairs(spawnRules) do
            if rule.Filter and not rule.Filter(npc) then
                goto continue -- skip this rule if the filter is not met
            end

            Resouled:TrySpawnSoulPickup(rule.Soul, npc.Position, rule.Weight)
            ::continue::
        end
    end

    if spawnRulesNoSubType then
        for _, rule in ipairs(spawnRulesNoSubType) do
            if rule.Filter and not rule.Filter(npc) then
                goto continue -- skip this rule if the filter is not met
            end

            Resouled:TrySpawnSoulPickup(rule.Soul, npc.Position, rule.Weight)
            ::continue::
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, basicSoulSpawnHandler)

function Resouled:GetNumBasicSoulSpawnRules()
    local num = 0
    for _, rules in pairs(basicSpawnLookupTable) do
        for _, rule in ipairs(rules) do
            num = num + rule.Weight
        end
    end
    return num
end
