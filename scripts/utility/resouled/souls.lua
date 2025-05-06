local SOUL_PICKUP_VARIANT = Isaac.GetEntityVariantByName("Soul Pickup")

---@enum ResouledSoul
Resouled.Souls = {
    MONSTRO = 1,
    DUKE = 2,
    LITTLE_HORN = 3,
    BLOAT = 4,
    WRATH = 5,
    WIDOW = 6,
    CURSED_HAUNT = 7,
    THE_BONE = 8,
    THE_CHEST = 9,
}

local DEFAULT_WEIGHT = 1
local CUSTOM_WEIGHTS = {
    --[Resouled.Souls.MONSTRO] = 3, -- EXAMPLE
}





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
    if not isContinued then
        local runSave = SAVE_MANAGER.GetRunSave()
        runSave.Souls = {
            Spawned = {},
            Possessed = 0,
        }
        cachedSoulsNum = 0
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
---@return boolean
function Resouled:TrySpawnSoulPickup(soul, position)
    local runSave = SAVE_MANAGER.GetRunSave()
    if
    runSave.Souls and
    not runSave.Souls.Spawned[soul] and
    not Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_SOULLESS) then
        local pickup = Game():Spawn(EntityType.ENTITY_PICKUP, SOUL_PICKUP_VARIANT, position, Vector.Zero, nil, 0, Resouled:NewSeed())
        if CUSTOM_WEIGHTS[soul] then
            local pickupSave = SAVE_MANAGER.GetRoomFloorSave(pickup)
            pickupSave.SoulWeight = CUSTOM_WEIGHTS[soul]
        end
        return true
    else
        return false
    end
end

---@param pickup EntityPickup
local function onSoulPickupInit(_, pickup)
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
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