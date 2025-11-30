local CHEESE_GRATER = Resouled.Enums.Items.CHEESE_GRATER

local DAMAGE_MULTIPLIER = 2.5
local COOLDOWN = 10

local SPECIAL_TEAR_COLOR = Color(1, 0.6, 1, 0.7, 0.7, 0.7, 0)
local SPECIAL_TEAR_COLOR_DURATION = 300
local SPECIAL_TEAR_COLOR_PRIORITY = 1

local NORMAL_CHEESE_SPRITESHEET = "gfx_resouled/tears/tears_cheese.png"

local MAGGOT_INNACURACY = 50
local INNACURACY_ROTATION = 30

local GRATED_OFF_ENEMY_HEALTH_FRACTION = 0.01
local GRATED_OFF_ENEMY_TYPE = EntityType.ENTITY_SMALL_MAGGOT
local GRATED_OFF_ENEMY_VARIANT = 0
local GRATED_OFF_ENEMY_SUBTYPE = 0
local GRATED_OFF_ENEMY_SPAWN_VELOCITY_MULTIPLIER = 3

---@param luck number
---@return number
local APPLY_TEAR_EFFECT_CHANCE = function(luck)
    return math.max(0.1, 0.12 * math.log(luck + 1, 2.8) + 0.1)
end

---@param tear EntityTear
local function onTearInit(_, tear)
    if tear.SpawnerEntity then
        local player = tear.SpawnerEntity:ToPlayer()
        if player and player:HasCollectible(CHEESE_GRATER) and tear:GetDropRNG():RandomFloat() < APPLY_TEAR_EFFECT_CHANCE(player.Luck) then
            Resouled:ApplyCustomTearEffect(tear, Resouled.TearEffects.CHEESE_GRATER)
            local sprite = tear:GetSprite()
            sprite:ReplaceSpritesheet(0, NORMAL_CHEESE_SPRITESHEET, true)
        end
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

        if (tear or knife) and source.Entity.SpawnerEntity then
            player = Resouled:TryFindPlayerSpawner(source.Entity)
        end

        if not player then
            return
        end

        local npc = entity:ToNPC()
        local npcData = entity:GetData()

        if npcData.Resouled_CheeseGraterMaggot then
            return
        end


        if tear then
            local tearEffects = Resouled:GetCustomTearEffects(tear)
            if tearEffects and tearEffects[Resouled.TearEffects.CHEESE_GRATER] then
                if npc and npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() and not Resouled:IsCustomTearEffectOnCooldown(npc, Resouled.TearEffects.CHEESE_GRATER) then
                    --Spawn pos explanation: I take an offset vector that's 10 pixels bigger than maggot innacuracy (so the maggot doesn't spawn in the enemy), i rotate it to the player and randomly rotate it within a -45 to 45 degree angle, then i take a vector that's size is between 0 and maggot innacuracy and i rotate it randomly from 0 to 360 degrees
                    local maggotSpawnPos = npc.Position +
                        (Vector(MAGGOT_INNACURACY + 10, 0):Rotated((player.Position - npc.Position):GetAngleDegrees() + math.random(-INNACURACY_ROTATION, INNACURACY_ROTATION)) + Vector(math.random(0, MAGGOT_INNACURACY), 0):Rotated(math.random(0, 360)))

                    local maggot = EntityNPC.ThrowMaggotAtPos(npc.Position, maggotSpawnPos, 0)
                    maggot.Velocity = maggot.Velocity:Normalized() * (0.8 - (math.random() / 2))
                    maggot.MaxHitPoints = 1 / 100
                    maggot.HitPoints = maggot.MaxHitPoints
                    maggot:GetData().Resouled_CheeseGraterMaggot = true

                    Resouled:ApplyCustomTearEffectCooldown(npc, Resouled.TearEffects.CHEESE_GRATER, COOLDOWN)

                    npc:TakeDamage(amount * DAMAGE_MULTIPLIER, damageFlag, source, countdown)
                    return false
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEntityTakeDamage)

---@param pickup EntityPickup
local function oncCollectibleUpdate(_, pickup)
    -- THIS HAS TO BE POST UPDATE BECAUSE POST INIT THERE IS NO SPRITE LOADED YET
    -- POST RENDER ALSO DOES NOT WORK CORRECTLY BECAUSE IT GOES BACK AND FORTH BETWEEN BEING A QUESTION MARK AND NOT
    if Resouled.Collectiblextension:CollectiblePresent(CHEESE_GRATER) then
        Resouled.Collectiblextension:TryRevealQuestionMarkItem(pickup)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, oncCollectibleUpdate, PickupVariant.PICKUP_COLLECTIBLE)
