local SOULBOND = Isaac.GetItemIdByName("Soulbond")

local DAMAGE_SHARE = 0.25

local BOND_ENTITY_1_COLOR = Color(5, 5, 5, 0.7)
local BOND_ENTITY_2_COLOR = Color(0.5, 2, 10, 0.7)

local POST_DEATH_GHOST_TYPE =  EntityType.ENTITY_EFFECT
local POST_DEATH_GHOST_VARIANT = EffectVariant.PURGATORY
local POST_DEATH_GHOST_SUBTYPE = 1

local TARGET_BONDS_COUNT = function(enemyCount)
    return math.max(math.floor(enemyCount / 4), 1)
end

local chainSprite = Sprite()
chainSprite:Load("gfx/soulbond_chain.anm2", true)
chainSprite:Play("Idle", true)

local function onUpdate()
    if PlayerManager.AnyoneHasCollectible(SOULBOND) then
        local bondedEnemies = 0
        local totalEnemies = 0
        local bindableEnemies = {}
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then
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
                Beam = Beam(chainSprite, 0, false, false)
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
            local ghost = Game():Spawn(POST_DEATH_GHOST_TYPE, POST_DEATH_GHOST_VARIANT, npc.Position, Vector.Zero, nil, POST_DEATH_GHOST_SUBTYPE, npc.InitSeed)
            ghost.Target = other
            ghost.Color = data.ResouledSoulbond.Beam and BOND_ENTITY_2_COLOR or BOND_ENTITY_1_COLOR
            data.ResouledSoulbond = nil
            otherData.ResouledSoulbond = nil
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate)

---@param npc EntityNPC
---@param offset Vector
local function onNpcRender(_, npc, offset)
    local data = npc:GetData()
    if data.ResouledSoulbond and data.ResouledSoulbond.Beam then
        ---@type Entity
        local other = data.ResouledSoulbond.Other.Entity
        ---@type Beam
        local beam = data.ResouledSoulbond.Beam
        beam:Add(Isaac.WorldToScreen(npc.Position), 0)
        beam:Add(Isaac.WorldToScreen(other.Position), 64)
        beam:Render()
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_RENDER, onNpcRender)

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
        otherData.ResouledSoulbond.Damage = true
        other:TakeDamage(amount*DAMAGE_SHARE, damageFlags, source, countdown)
        otherData.ResouledSoulbond.Damage = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, npcTakeDamage)

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    local data = npc:GetData()
    if data.ResouledSoulbond then
        data.ResouledSoulbond = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath)