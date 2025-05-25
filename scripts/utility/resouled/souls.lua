local SOUL_PICKUP_VARIANT = Isaac.GetEntityVariantByName("Soul Pickup")

local DEFAULT_WEIGHT = 1

local basicSpawnLookupTable = {} -- NOT STATIC, POPULATED AT RUNTIME by Resouled:AddNewBasicSoulSpawnRule

local font = Font()
font:Load("font/luaminioutlined.fnt")

local cachedSoulsNum = 0

local function hudRenderer()
    local screenWidth = Isaac.GetScreenWidth()
    font:DrawString(string.format("(placeholder) Souls Num: %d", cachedSoulsNum), screenWidth / 2, 20, KColor(1,1,1,1), nil, true)

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
        local pickup = Game():Spawn(EntityType.ENTITY_PICKUP, SOUL_PICKUP_VARIANT, position, Vector.Zero, nil, 0, Resouled:NewSeed())
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
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onSoulPickupInit, SOUL_PICKUP_VARIANT)

---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
local function onSoulPickupCollision(_, pickup, collider, low)
    if collider.Type == EntityType.ENTITY_PLAYER then
        local runSave = SAVE_MANAGER.GetRunSave()
        if runSave.Souls then
            local pickupSave = SAVE_MANAGER.GetRoomFloorSave(pickup)
            local weight = pickupSave.SoulWeight or DEFAULT_WEIGHT
            runSave.Souls.Possessed = runSave.Souls.Possessed + weight
            cachedSoulsNum = runSave.Souls.Possessed
        end
        pickup:Remove()
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onSoulPickupCollision, SOUL_PICKUP_VARIANT)

local function makeLookupTableKey(type, variant, subtype)
    return string.format("%d_%d_%d", type, variant, subtype)
end

---@param type EntityType
---@param variant integer
---@param subtype integer
---@param soul ResouledSoul
---@param weight? integer -- default 1
---@param filter? function -- default nil
function Resouled:AddNewBasicSoulSpawnRule(type, variant, subtype, soul, weight, filter)
    weight = weight or DEFAULT_WEIGHT
    local key = makeLookupTableKey(type, variant, subtype)

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
    local spawnRules = basicSpawnLookupTable[key]
    if spawnRules then
        for _, rule in ipairs(spawnRules) do

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