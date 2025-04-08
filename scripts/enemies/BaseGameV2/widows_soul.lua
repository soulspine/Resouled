local stringName = "Widow's Sou"
local WIDOWS_SOUL_TYPE = Isaac.GetEntityTypeByName(stringName)
local WIDOWS_SOUL_VARIANT = Isaac.GetEntityVariantByName(stringName)
local WIDOWS_SOUL_SUBTYPE = Isaac.GetEntitySubTypeByName(stringName)

local NORMAL = true

local ACTION_TIMER = 1.5 * 30

local ATTACK1_SPIDER_COUNT = 3
local ATTACK2_TEAR_COUNT = 20

local IDLE = "Idle"
local JUMP = "Jump"
local ATTACK1 = "Attack01"
local ATTACK2 = "Attack02"

local TRIGGER_LAND = "Land"
local TRIGGER_JUMP = "Jump"
local TRIGGER_ATTACK1 = "Attack01"
local TRIGGER_ATTACK2 = "Attack02"

local function onNpcInit(_, npc)
    if npc.Variant == WIDOWS_SOUL_VARIANT and npc.SubType == WIDOWS_SOUL_SUBTYPE then
        local sprite = npc:GetSprite()
        if NORMAL then
            for _, i in pairs({0,1,3}) do
                sprite:ReplaceSpritesheet(i, "gfx/souls/widows_soul_normal.png")
            end
            sprite:LoadGraphics()
        end
        sprite:Play(IDLE, true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, WIDOWS_SOUL_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == WIDOWS_SOUL_VARIANT and npc.SubType == WIDOWS_SOUL_SUBTYPE then
        local data = npc:GetData()
        local sprite = npc:GetSprite()
        
        if not sprite:IsPlaying(JUMP) then
            npc.Velocity = Vector.Zero
        end

        if not data.ResouledWidowsSoul then
            data.ResouledWidowsSoul = {}
        end
        
        if data.ResouledWidowsSoul.ActionTimer == nil then
            data.ResouledWidowsSoul.ActionTimer = ACTION_TIMER
        end

        if data.ResouledWidowsSoul.ActionTimer > 0 then
            data.ResouledWidowsSoul.ActionTimer = data.ResouledWidowsSoul.ActionTimer - 1
        end
        
        if data.ResouledWidowsSoul.ActionTimer == 0 then
            data.ResouledWidowsSoul.CurrentAction = math.random(1, 3)
            data.ResouledWidowsSoul.ActionTimer = ACTION_TIMER
        end

        if data.ResouledWidowsSoul.CurrentAction then
            if data.ResouledWidowsSoul.CurrentAction == 1 then
                sprite:Play(JUMP, true)
            end
            if data.ResouledWidowsSoul.CurrentAction == 2 then
                sprite:Play(ATTACK1, true)
            end
            if data.ResouledWidowsSoul.CurrentAction == 3 then
                sprite:Play(ATTACK2, true)
            end
            data.ResouledWidowsSoul.CurrentAction = nil
        end

        if sprite:IsEventTriggered(TRIGGER_JUMP) then
            local target = npc:GetPlayerTarget()
            local jumpSpeed = 10
            local jumpVector = (target.Position - npc.Position):Resized(jumpSpeed)
            npc.Velocity = jumpVector
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end

        if sprite:IsEventTriggered(TRIGGER_LAND) then
            npc.Velocity = Vector.Zero
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            sprite:Play(IDLE, true)
        end
        
        if sprite:IsEventTriggered(TRIGGER_ATTACK1) then
            for _ = 1, ATTACK1_SPIDER_COUNT do
                local spider = Game():Spawn(EntityType.ENTITY_ROCK_SPIDER, 0, npc.Position, Vector.Zero, nil, 0, npc.InitSeed)
                spider.MaxHitPoints = spider.MaxHitPoints * 2
                spider.HitPoints = spider.MaxHitPoints
            end
        end

        if sprite:IsEventTriggered(TRIGGER_ATTACK2) then
            for i = 1, ATTACK2_TEAR_COUNT do
                npc:FireProjectiles(npc.Position, Vector(10, 0):Rotated(360/ATTACK2_TEAR_COUNT * i), 0, ProjectileParams())
            end
        end

        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate, WIDOWS_SOUL_TYPE)

---@param npc EntityNPC
local function onNpcDeath(_, npc)
    if npc.Variant ~= WIDOWS_SOUL_VARIANT then 
        Resouled:TrySpawnSoulPickup(Resouled.Souls.WIDOW, npc.Position)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNpcDeath, EntityType.ENTITY_WIDOW)