local HOLY_BRAIN_TYPE = Isaac.GetEntityTypeByName("Holy Brain")
local HOLY_BRAIN_VARIANT = Isaac.GetEntityVariantByName("Holy Brain")
local HOLY_BRAIN_SUBTYPE = Isaac.GetEntitySubTypeByName("Holy Brain")

local TARGET_POS_FOLLOW_SPEED = 1.5
local TARGET_POS_CAHNCE_CHANCE = 0.5
local TARGET_POS_RESET_DISTANCE = 35
local PLAYER_FOLLOW_SPEED = 0.35
local SPEED_MULTI = 0.75

local CREEP_SPAWN_CHANCE = 0.1
local CREEP_PETRIFY_DISTANCE = 16
local CREEP_COLOR = Color(0, 0, 0, 1, 0.5, 0.6, 0.75)
local COLOR_MAX_GAIN = 0.2
local BLINK_SPEED = 10

local PETRIFY_COLOR = Color(0.1, 0.1, 0.1, 1, 0.35, 0.35, 0.35)

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == HOLY_BRAIN_VARIANT and npc.SubType == HOLY_BRAIN_SUBTYPE then
        local sprite = npc:GetSprite()
        sprite:Play("Idle", true)
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, HOLY_BRAIN_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == HOLY_BRAIN_VARIANT and npc.SubType == HOLY_BRAIN_SUBTYPE then
        local data = npc:GetData()
        local room = Game():GetRoom()
        if not data.TargetPos then
            data.TargetPos = room:GetRandomPosition(0)
        end
        
        if data.TargetPos then
            npc.Velocity = (npc.Velocity + (data.TargetPos - npc.Position):Normalized() * TARGET_POS_FOLLOW_SPEED + (npc:GetPlayerTarget().Position - npc.Position):Normalized() * PLAYER_FOLLOW_SPEED) * SPEED_MULTI
            if npc.Position:Distance(data.TargetPos) < TARGET_POS_RESET_DISTANCE then
                local randomNum = math.random()
                if randomNum < TARGET_POS_CAHNCE_CHANCE then
                    data.TargetPos = room:GetRandomPosition(0)
                end
            end
        end

        local randomNum = math.random()
        if randomNum < CREEP_SPAWN_CHANCE then
            local creep = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, npc.Position, Vector.Zero, npc, 0, npc.InitSeed)
            creep.Color = CREEP_COLOR
            creep:Update()
            creep:GetData().Resouled_Petrify = true
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, HOLY_BRAIN_TYPE)

---@param effect EntityEffect
local function postEffectUpdate(_, effect)
    local data = effect:GetData()
    if data.Resouled_Petrify then

        local frameCount = Game():GetFrameCount()

        local maxAnimTime = BLINK_SPEED
        local maxAnimTime2 = BLINK_SPEED * 2
        local animTime = frameCount % maxAnimTime / maxAnimTime
        local animTime2 = frameCount % maxAnimTime2 / maxAnimTime2

        animTime = (math.abs(animTime - animTime2) * 2) * COLOR_MAX_GAIN

        local newColor = Color(CREEP_COLOR.R, CREEP_COLOR.G, CREEP_COLOR.B, CREEP_COLOR.A,
        CREEP_COLOR.RO, CREEP_COLOR.GO, CREEP_COLOR.BO)

        newColor.RO = newColor.RO + animTime
        newColor.GO = newColor.GO + animTime
        newColor.BO = newColor.BO + animTime
        effect.Color = newColor

        for _, en in ipairs(Isaac.FindInRadius(effect.Position, CREEP_PETRIFY_DISTANCE, EntityPartition.PLAYER)) do
            local player = en:ToPlayer()
            if player and player.ControlsCooldown == 0 then
                player:AddControlsCooldown(4)
                player:SetMinDamageCooldown(6)
                player:SetColor(PETRIFY_COLOR, 3, 1, false, true)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, postEffectUpdate, EffectVariant.CREEP_RED)

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    if npc.Variant == HOLY_BRAIN_VARIANT and npc.SubType == HOLY_BRAIN_SUBTYPE then
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, player.Position, Vector.Zero, npc, 2, player.InitSeed)
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath, HOLY_BRAIN_TYPE)