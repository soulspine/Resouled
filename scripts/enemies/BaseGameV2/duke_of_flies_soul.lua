local DUKE_OF_FLIES_SOUL_VARIANT = Isaac.GetEntityVariantByName("Duke's Soul")
local DUKE_OF_FLIES_SOUL_ITEM_SUBTYPE = Isaac.GetItemIdByName("Duke's Soul")

local DUKIE_SOUL_TYPE = Isaac.GetEntityTypeByName("Dukie's Soul")
local DUKIE_SOUL_VARIANT = Isaac.GetEntityVariantByName("Dukie's Soul")

local SPRITE_PLAYBACK_SPEED_MULTIPLIER = 1.7

local SPRITE_SCALE_TO_ADD = 0.5
local SPRITE_OFFSET = Vector(0, 10)
local HITBOX_SIZE_MULTI = Vector(1, 0.5)
local HITBOX_SIZE_SCALE = 1.5

local EVENT_TRIGGER_RESOULED_ATTACK1 = "ResouledAttack"
local EVENT_TRIGGER_RESOULED_ATTACK2 = "ResouledAttack2"
local EVENT_TRIGGER_RESOULED_ATTACK_360 = "ResouledAttack3"

local DUKIES_COUNT = 5

local PROJECTILE_COUNT = 12
local PROJECTILE_PARAMS = ProjectileParams()
local PROJECTILE_SCALE = 1.5
local PROJECTILE_VARIANT = 6
local PROJECTILE_COLOR = Color(2, 5, 12.5, 0.5)
local PROJECTILE_SPEED_MULTIPLIER = 12.5

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == DUKE_OF_FLIES_SOUL_VARIANT then
        npc.Scale = npc.Scale + SPRITE_SCALE_TO_ADD --Sprite Scale
        npc.SpriteOffset = SPRITE_OFFSET --Sprite Offset
        npc.Size = npc.Size * HITBOX_SIZE_SCALE --Hitbox Size
        npc.SizeMulti = HITBOX_SIZE_MULTI
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, EntityType.ENTITY_DUKE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == DUKE_OF_FLIES_SOUL_VARIANT then
        local sprite = npc:GetSprite()
        sprite.PlaybackSpeed = SPRITE_PLAYBACK_SPEED_MULTIPLIER
        npc.Velocity = npc.Velocity * 1.15

        
        if sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_ATTACK1) then
            for _ = 1, DUKIES_COUNT do
                local DUKIES_POSITION = Vector(math.random(-75, 75), math.random(-75, 75))
                Game():Spawn(DUKIE_SOUL_TYPE, DUKIE_SOUL_VARIANT, npc.Position + DUKIES_POSITION, Vector.Zero, npc, 0, npc.InitSeed)
            end
        end
        
        if sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_ATTACK2) then
            PROJECTILE_PARAMS.Scale = PROJECTILE_SCALE
            PROJECTILE_PARAMS.Color = PROJECTILE_COLOR
            PROJECTILE_PARAMS.Variant = PROJECTILE_VARIANT
            for i = 1, PROJECTILE_COUNT do
                npc:FireProjectiles(npc.Position, Vector.FromAngle(i * 360 / PROJECTILE_COUNT):Resized(1)*PROJECTILE_SPEED_MULTIPLIER, 0, PROJECTILE_PARAMS)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, EntityType.ENTITY_DUKE)

local function postNpcDeath(_, npc)
    local itemConfig = Isaac.GetItemConfig()
    local collectible = itemConfig:GetCollectible(DUKE_OF_FLIES_SOUL_ITEM_SUBTYPE)
    if npc.Variant ~= DUKE_OF_FLIES_SOUL_VARIANT and collectible:IsAvailable() then
        Resouled:TrySpawnSoulItem(ResouledSouls.DUKE, npc.Position)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath, EntityType.ENTITY_DUKE)
