local game = Game()

local Soul = Resouled.Stats.Soul

local DEFAULT_WEIGHT = 1

local SOULS_UI_TEXT_COLOR = KColor(1, 1, 1, 0.7)

local basicSpawnLookupTable = {} -- NOT STATIC, POPULATED AT RUNTIME by Resouled:AddNewBasicSoulSpawnRule

local font = Font()
font:Load("font/luaminioutlined.fnt")

local ICON_DIMENSIONS = 16
local iconSprite = Sprite()
iconSprite:Load("gfx/ui/soul_icon.anm2", true)
iconSprite:Play(iconSprite:GetDefaultAnimation(), true)
iconSprite:SetFrame(1)

local cachedSoulsNum = 0

local function hudRenderer()
    if game:GetHUD():IsVisible() then
        local screenWidth = Isaac.GetScreenWidth()
        local screenHeight = Isaac.GetScreenHeight()

        local text = tostring(cachedSoulsNum)
        local xGap = ICON_DIMENSIONS / 4

        font:DrawString(
            tostring(cachedSoulsNum),
            screenWidth / 2 + xGap,
            screenHeight - ICON_DIMENSIONS,
            SOULS_UI_TEXT_COLOR
        )

        iconSprite:Render(Vector(screenWidth / 2 - xGap, screenHeight - ICON_DIMENSIONS / 2))
    end
end
Resouled:AddCallback(ModCallbacks.MC_HUD_RENDER, hudRenderer)

---@param isContinued boolean
local function createSoulsContainerOnRunStart(_, isContinued)
    local runSave = SAVE_MANAGER.GetRunSave()
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
    local runSave = SAVE_MANAGER.GetRunSave()
    if runSave.Souls and runSave.Spawned and runSave.Spawned[soul] > 0 then
        return true
    end
    return false
end

---@return integer
function Resouled:GetPossessedSoulsNum()
    local runSave = SAVE_MANAGER.GetRunSave()
    return (runSave.Souls) and runSave.Souls.Possessed or 0
end

---@param num integer
function Resouled:SetPossessedSoulsNum(num)
    local runSave = SAVE_MANAGER.GetRunSave()
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
    local runSave = SAVE_MANAGER.GetRunSave()
    if
    runSave.Souls and
    not runSave.Souls.Spawned[tostring(soul)] and
    not Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_SOULLESS) then
        local pickup = game:Spawn(EntityType.ENTITY_PICKUP, Soul.Variant, position, Vector.Zero, nil, Soul.SubType, Resouled:NewSeed())
        if weight and weight ~= DEFAULT_WEIGHT then
            local pickupSave = SAVE_MANAGER.GetRoomFloorSave(pickup)
            pickupSave.SoulWeight = weight
        end
        runSave.Souls.Spawned[tostring(soul)] = true
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
            local runSave = SAVE_MANAGER.GetRunSave()
            if runSave.Souls then
                local pickupSave = SAVE_MANAGER.GetRoomFloorSave(pickup)
                local weight = pickupSave.SoulWeight or DEFAULT_WEIGHT
                runSave.Souls.Possessed = runSave.Souls.Possessed + weight
                cachedSoulsNum = runSave.Souls.Possessed
            end
            Soul:PlayPickupSound()

            local color = collider.Color
            collider:SetColor(Color(color.R, color.G, color.B, color.A, 0.5, 0.5, 0.5), 10, 1, true, true)

            pickup:Remove()
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