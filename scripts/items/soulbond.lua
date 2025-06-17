local SOULBOND = Isaac.GetItemIdByName("Soulbond")

local DAMAGE_SHARE = 0.25

local BEAM_SPRITE_MIN = 0
local BEAM_SPRITE_MAX = 64

local CHAIN_OPACITY = 1

local EFFECT_VARIANT = Isaac.GetEntityVariantByName("Chain Particle")
local EFFECT_SUBTYPE = Isaac.GetEntitySubTypeByName("Chain Particle")
local CHAIN_PARTICLES_SPAWN_CHANCE_ON_BREAK_PER_POINT = 0.5
local SPAWN_HEIGHT = 15
local MAX_HEIGHT_ROTATION = 45
local MIN_HEIGHT_ROTATIOn = -5
local WEIGHT = 1.1
local BOUNCINESS = 0.5
local SLIPPERINESS = 1
local SIZE = 1
local MAX_SIZE_VARIETY = 20
local SPEED_MAX = 10
local SPEED_MIN = 5


local TARGET_BONDS_COUNT = function(enemyCount)
    return math.max(math.floor(enemyCount / 4), 1)
end

---@param entity Entity
local SPAWN_CHAIN_PARTICLES = function(entity)
    local data = entity:GetData()
    local other = data.ResouledSoulbond.Other.Entity
    local currentPos = entity.Position
    local otherPos = other.Position
    local dirVector = (otherPos - currentPos):Normalized() * BEAM_SPRITE_MAX
    local dirVectorLength = dirVector:Length()
    local distance = currentPos:Distance(otherPos)
    local pointPos = currentPos
    while distance - dirVectorLength > dirVectorLength do
        local randomNum = math.random()
        if randomNum < CHAIN_PARTICLES_SPAWN_CHANCE_ON_BREAK_PER_POINT then
            Resouled:SpawnRealisticParticles(GridCollisionClass.COLLISION_SOLID, pointPos, math.random(1, 3), SPAWN_HEIGHT,
            MAX_HEIGHT_ROTATION, MIN_HEIGHT_ROTATIOn, WEIGHT, BOUNCINESS, SLIPPERINESS, SIZE, MAX_SIZE_VARIETY, math.random(SPEED_MIN, SPEED_MAX), nil, nil, false, EFFECT_VARIANT, EFFECT_SUBTYPE)
        end
            
        pointPos = pointPos + dirVector
        distance = distance - dirVectorLength
    end

    Resouled:SpawnRealisticParticles(GridCollisionClass.COLLISION_SOLID, currentPos, math.random(2, 6), SPAWN_HEIGHT,
    MAX_HEIGHT_ROTATION, MIN_HEIGHT_ROTATIOn, WEIGHT, BOUNCINESS, SLIPPERINESS, SIZE, MAX_SIZE_VARIETY, math.random(SPEED_MIN, SPEED_MAX), nil, nil, false, EFFECT_VARIANT, EFFECT_SUBTYPE)
    Resouled:SpawnRealisticParticles(GridCollisionClass.COLLISION_SOLID, otherPos, math.random(2, 6), SPAWN_HEIGHT,
    MAX_HEIGHT_ROTATION, MIN_HEIGHT_ROTATIOn, WEIGHT, BOUNCINESS, SLIPPERINESS, SIZE, MAX_SIZE_VARIETY, math.random(SPEED_MIN, SPEED_MAX), nil, nil, false, EFFECT_VARIANT, EFFECT_SUBTYPE)
end

local chainSprite = Sprite()
chainSprite:Load("gfx/soulbond_chain.anm2", true)
chainSprite:Play("Idle", true)
chainSprite.Color.A = CHAIN_OPACITY

local chainLockSprite = Sprite()
chainLockSprite:Load("gfx/soulbond_chain_2.anm2", true)
chainLockSprite:Play("Idle", true)
chainLockSprite.Color.A = CHAIN_OPACITY

local function onUpdate()
    if PlayerManager.AnyoneHasCollectible(SOULBOND) then
        local bondedEnemies = 0
        local totalEnemies = 0
        local bindableEnemies = {}
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() and entity:IsEnemy() then
                totalEnemies = totalEnemies + 1
                local data = entity:GetData()
                if data.ResouledSoulbond then
                    bondedEnemies = bondedEnemies + 1
                elseif not data.ResouledSoulbondBlock then
                    table.insert(bindableEnemies, EntityRef(entity))
                end
            end
        end)
        local targetbondedEnemies = TARGET_BONDS_COUNT(totalEnemies) * 2

        if targetbondedEnemies > bondedEnemies and #bindableEnemies > 1 then
            local enemyIndex1 = math.random(1, #bindableEnemies)
            local enemy1 = bindableEnemies[enemyIndex1]
            table.remove(bindableEnemies, enemyIndex1)
            local enemy2 = bindableEnemies[math.random(1, #bindableEnemies)]
            local data1 = enemy1.Entity:GetData()
            local data2 = enemy2.Entity:GetData()
            data1.ResouledSoulbond = {
                Other = enemy2,
                Beam = Beam(chainSprite, 0, false, false),
            }
            data1.ResouledSoulbondBlock = true
            data2.ResouledSoulbond = {
                Other = enemy1,
            }
            data2.ResouledSoulbondBlock = true
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    local data = npc:GetData()
    if data.ResouledSoulbond and npc:IsDead() then
        ---@type Entity
        local other = data.ResouledSoulbond.Other.Entity
        local otherData = other:GetData()
        if not other:IsDead() then
            SPAWN_CHAIN_PARTICLES(npc)
            data.ResouledSoulbond = nil
            otherData.ResouledSoulbond = nil
        end
    end

    if data.ResouledSoulbond and data.ResouledSoulbond.Other.Entity.HitPoints <= 0 then
        SPAWN_CHAIN_PARTICLES(npc)
        data.ResouledSoulbond.Other.Entity:GetData().ResouledSoulbond = nil
        data.ResouledSoulbond = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate)

---@param npc EntityNPC
---@param offset Vector
local function onNpcRender(_, npc, offset)
    local data = npc:GetData()
    if data.ResouledSoulbond then
        ---@type Entity
        local other = data.ResouledSoulbond.Other.Entity
        
        --Get the positions
        local currentPos = npc.Position
        local otherPos = other.Position
        --Apply the sprite offset
        currentPos = currentPos + npc.SpriteOffset + Vector(0, -(npc.Size/2))
        otherPos = otherPos + other.SpriteOffset + Vector(0, -(other.Size/2))
        if data.ResouledSoulbond.Beam then
            ---@type Beam
            local beam = data.ResouledSoulbond.Beam
            
            local dirVector = (otherPos - currentPos):Normalized() * BEAM_SPRITE_MAX
            local dirVectorLength = dirVector:Length()
            local distance = currentPos:Distance(otherPos)
            local pointPos = currentPos
            
            while distance - dirVectorLength > dirVectorLength do
                beam:Add(Isaac.WorldToScreen(pointPos), BEAM_SPRITE_MIN)
                beam:Add(Isaac.WorldToScreen(pointPos + dirVector), math.floor(pointPos:Distance(pointPos + dirVector)/2))
                
                pointPos = pointPos + dirVector
                distance = distance - dirVectorLength
            end
            
            beam:Add(Isaac.WorldToScreen(pointPos), BEAM_SPRITE_MIN)
            beam:Add(Isaac.WorldToScreen(otherPos), math.floor(pointPos:Distance(otherPos)/2))
            
            beam:Render()
        end

        chainLockSprite:Render(Isaac.WorldToScreen(currentPos))
        chainLockSprite:Render(Isaac.WorldToScreen(otherPos))

    end

    if data.Resouled_NewAlpha then
        npc:SetColor(Color(npc.Color.R, npc.Color.G, npc.Color.B, data.Resouled_NewAlpha), 2, 1, false, true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, onNpcRender)

---@param entity Entity
---@param amount integer
---@param damageFlags DamageFlag
---@param source EntityRef
---@param countdown integer
local function npcTakeDamage(_, entity, amount, damageFlags, source, countdown)
    local data = entity:GetData()
    if damageFlags | DamageFlag.DAMAGE_FAKE ~= 0 and data.ResouledSoulbond and not data.ResouledSoulbond.Damage then
        ---@type Entity
        local other = data.ResouledSoulbond.Other.Entity
        local otherData = other:GetData()
        if otherData.ResouledSoulbond then
            otherData.ResouledSoulbond.Damage = true
            other:TakeDamage(amount * DAMAGE_SHARE, damageFlags, source, countdown)
            otherData.ResouledSoulbond.Damage = nil
        end
        
        local newAlpha = (1 - (entity.HitPoints / entity.MaxHitPoints))/2
        local newAlphaOther = (1 - (other.HitPoints / other.MaxHitPoints))/2

        data.Resouled_NewAlpha = 1 - newAlpha
        otherData.Resouled_NewAlpha = 1 - newAlphaOther
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, npcTakeDamage)

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    local data = npc:GetData()
    if data.ResouledSoulbond then
        SPAWN_CHAIN_PARTICLES(npc)
        data.ResouledSoulbond.Other.Entity:GetData().ResouledSoulbond = nil
        data.ResouledSoulbond = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath)