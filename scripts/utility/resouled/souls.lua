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
    CARRIOR_QUEEN = 10,
    PANDORAS_BOX = 11,
    CHUB = 12,
    CONQUEST = 13,
    DADDY_LONG_LEGS = 14,
    DARK_ONE = 15,
    DEATH = 16,
    ENVY = 17,
    FAMINE = 18,
    GEMINI = 19,
    GLUTTONY = 20,
    GREED = 21,
    GURDY = 22,
    GURDY_JR = 23,
    LARRY_JR = 24,
    LUST = 25,
    MASK_OF_INFAMY = 26,
    MEGA_FATTY = 27,
    PEEP = 28,
    PESTILENCE = 29,
    PIN = 30,
    PRIDE = 31,
    RAG_MAN = 32,
    SCOLEX = 33,
    SLOTH = 34,
    HAUNT = 35,
    THE_LAMB = 36,
    WAR = 37,
    MOM = 38,
    SATAN = 39,
    HEADLESS_HORSEMAN = 40,
    BLASTOCYST = 41,
    DINGLE = 42,
    KRAMPUS = 43,
    MONSTRO_II = 44,
    THE_FALLEN = 45,
    ISAAC = 46,
    MOMS_HEART = 47,
    HOLY_CHEST = 48,
    EXPERIMENTAL_TREATMENT = 49,
    ULTRA_FLESH_KID = 50,
    CURSED_SOUL = 51,
    BABY_PLUM = 52,
    BROWNIE = 53,
    CHARMED_MONSTRO = 54,
    CLOG = 55,
    HORNFEL = 56,
    MAMA_GURDY = 57,
    RAG_MEGA = 58,
    SISTERS_VIS = 59,
    THE_RAINMAKER = 60,
    THE_SCOURGE = 61,
    THE_SIREN = 62,
    TURDLINGS = 63,
    ULTRA_GREED = 64,
    MEGA_SATAN = 65,
    MOTHER = 66,
    GUS = 67,
    A_FRIEND = 68,
    HUSH = 69,
    HOLY_GREED = 70,
    HOT_POTATO = 71,
    FISTULA = 72,
    GURGLINGS = 73,
    POLYCEPHALUS = 74,
    STEVEN = 75,
    THE_CAGE = 76,
    BIG_HORN = 77,
    LOKI = 78,
    THE_ADVERSARY = 79,
    TERATOMA = 78,
    IT_LIVES = 79,
    CHARMED_MOMS_HEART = 80,
    THE_LOST = 81,
    THE_BEAST = 82,
}

include("scripts.utility.resouled.soul_spawning")

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