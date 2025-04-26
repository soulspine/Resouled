local THE_MONSTER = Isaac.GetItemIdByName("The Monster")
local THE_MONSTER_VARIANT = Isaac.GetEntityVariantByName("The Monster")

local IDLE = "Idle"
local WALK_DOWN = "WalkDown"
local WALK_UP = "WalkUp"
local WALK_LEFT = "WalkLeft"
local WALK_RIGHT = "WalkRight"

local playerHeadDirectionTranslation = {
    [-1] = IDLE,
    [0] = WALK_LEFT,
    [1] = WALK_UP,
    [2] = WALK_RIGHT,
    [3] = WALK_DOWN,
}

local HITBOX_SIZE_INCREASE = 4

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    if cacheFlag & CacheFlag.CACHE_FAMILIARS then
        local itemConfigItem = Isaac.GetItemConfig():GetCollectible(THE_MONSTER)
        player:CheckFamiliar(THE_MONSTER_VARIANT, player:GetCollectibleNum(THE_MONSTER), player:GetCollectibleRNG(THE_MONSTER), itemConfigItem)
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval)

---@param familiar EntityFamiliar
local function familiarInit(_, familiar)
    familiar.Position = familiar.SpawnerEntity.Position
    familiar.SpawnerEntity.SpriteOffset = Vector(0, -25)
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, familiarInit, THE_MONSTER_VARIANT)

---@param familiar EntityFamiliar
local function npcUpdate(_, familiar)
    familiar.SpawnerEntity.Size = familiar.SpawnerEntity.Size + HITBOX_SIZE_INCREASE

    local sprite = familiar:GetSprite()

    if familiar.Position ~= familiar.SpawnerEntity.Position then
        familiar.Position = familiar.SpawnerEntity.Position
    end
    familiar.Velocity = familiar.SpawnerEntity.Velocity * 1.5

    local dir = familiar.SpawnerEntity:ToPlayer():GetMovementDirection()

    sprite:Play(playerHeadDirectionTranslation[dir], true)
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, npcUpdate, THE_MONSTER_VARIANT)