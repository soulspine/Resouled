local CHEESE_GRATER = Isaac.GetItemIdByName("Cheese Grater")

local DAMAGE_MULTIPLIER = 2.5
local COOLDOWN = 100

local SPECIAL_TEAR_COLOR = Color(1, 0.6, 1, 0.7, 0.7, 0.7, 0)
local SPECIAL_TEAR_COLOR_DURATION = 300
local SPECIAL_TEAR_COLOR_PRIORITY = 1

local GRATED_OFF_ENEMY_HEALTH_FRACTION = 0.01
local GRATED_OFF_ENEMY_TYPE = EntityType.ENTITY_SMALL_MAGGOT
local GRATED_OFF_ENEMY_VARIANT = 0
local GRATED_OFF_ENEMY_SUBTYPE = 0
local GRATED_OFF_ENEMY_SPAWN_VELOCITY_MULTIPLIER = 3

if EID then
    EID:addCollectible(CHEESE_GRATER, "Adds a luck based chance to shoot a special tear that deals " .. DAMAGE_MULTIPLIER .. "x damage but spawns a leech with 1HP.#Reveals all {{QuestionMark}} question mark items.", "Cheese Grater")
end

---@param luck number
---@return number
local APPLY_TEAR_EFFECT_CHANCE = function(luck)
    return ((6 + luck) / 18)^2
end

---@param tear EntityTear
local function onTearInit(_, tear)
    local player = tear.SpawnerEntity:ToPlayer()
    if player and player:HasCollectible(CHEESE_GRATER) and tear:GetDropRNG():RandomFloat() < APPLY_TEAR_EFFECT_CHANCE(player.Luck) then
        Resouled:ApplyCustomTearEffect(tear, Resouled.TearEffects.CHEESE_GRATER)
        tear:SetColor(SPECIAL_TEAR_COLOR, SPECIAL_TEAR_COLOR_DURATION, SPECIAL_TEAR_COLOR_PRIORITY, true, false)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, onTearInit)

---@param entity Entity
---@param amount number
---@param damageFlag integer
---@param source EntityRef
---@param countdown integer
local function onEntityTakeDamage(_, entity, amount, damageFlag, source, countdown)
    if source.Entity then
        local player = source.Entity:ToPlayer()
        local knife = source.Entity:ToKnife()
        local tear = source.Entity:ToTear()

        if tear or knife then
            player = source.Entity.SpawnerEntity:ToPlayer()
        end

        local npc = entity:ToNPC()
        local npcData = entity:GetData()
        if
        (player and player:HasCollectible(CHEESE_GRATER) and player:GetCollectibleRNG(CHEESE_GRATER):RandomFloat() < APPLY_TEAR_EFFECT_CHANCE(player.Luck)) or
        (tear and Resouled:GetCustomTearEffects(tear) and Resouled:GetCustomTearEffects(tear) | Resouled.TearEffects.CHEESE_GRATER == Resouled.TearEffects.CHEESE_GRATER) then
            if npc and npc:IsVulnerableEnemy() and not npcData.CheeseGraterMultiDamage and not Resouled:IsCustomTearEffectOnCooldown(npc, Resouled.TearEffects.CHEESE_GRATER) then

                local newAmount = DAMAGE_MULTIPLIER * amount
                if npc.HitPoints - newAmount > 0 then
                    npcData.CheeseGraterMultiDamage = true
                    entity:TakeDamage(newAmount, damageFlag, source, countdown)
                    Resouled:ApplyCustomTearEffectCooldown(npc, Resouled.TearEffects.CHEESE_GRATER, COOLDOWN)

                    local gratedOffEntity = Game():Spawn(GRATED_OFF_ENEMY_TYPE, GRATED_OFF_ENEMY_VARIANT, npc.Position, Vector.FromAngle(math.random(360)):Normalized() * GRATED_OFF_ENEMY_SPAWN_VELOCITY_MULTIPLIER, npc, GRATED_OFF_ENEMY_SUBTYPE, npc.DropSeed)
                    gratedOffEntity:AddHealth(-1*(1-GRATED_OFF_ENEMY_HEALTH_FRACTION)*gratedOffEntity.MaxHitPoints)
                    return false
                end
            else
                npcData.CheeseGraterMultiDamage = false
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEntityTakeDamage)

---@param pickup EntityPickup
local function oncCollectibleUpdate(_, pickup)
-- THIS HAS TO BE POST UPDATE BECAUSE POST INIT THERE IS NO SPRITE LOADED YET
-- POST RENDER ALSO DOES NOT WORK CORRECTLY BECAUSE IT GOES BACK AND FORTH BETWEEN BEING A QUESTION MARK AND NOT
    if Resouled:CollectiblePresent(CHEESE_GRATER) then
        Resouled:TryRevealQuestionMarkItem(pickup)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, oncCollectibleUpdate, PickupVariant.PICKUP_COLLECTIBLE)