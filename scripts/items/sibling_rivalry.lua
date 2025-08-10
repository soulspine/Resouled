local SiblingRivalry = {
    ID = Isaac.GetItemIdByName("Sibling Rivalry"),

    ChanceToGetAngry = 0.05,
    AngryChanceRate = 30,

    Damage = 10,
    Knockback = 50,

    TargetSpeed = 0.85
}

local e = Resouled.EID

if EID then
    EID:addCollectible(SiblingRivalry.ID, e:AutoIcons("Has a "..tostring(SiblingRivalry.ChanceToGetAngry*100).."% chance to make a random enemy angry # Angey enemies target a random other enemy of the same type # If the enemy gets close it punches the targeted enemy for "..tostring(SiblingRivalry.Damage).." damage and applies huge knockback"))
end

---@param npc EntityNPC
local function makeAngry(npc)
    local validEnemies = {}

    ---@param npc2 EntityNPC
    Resouled.Iterators:IterateOverRoomNpcs(function(npc2)
        if npc2.Index ~= npc.Index and npc2.Type == npc.Type then
            table.insert(validEnemies, EntityRef(npc2))
        end
    end)

    if #validEnemies > 0 then
        local data = npc:GetData()
        
        ---@type EntityRef
        data.Resouled_SiblingRivalryAngryTarget = validEnemies[math.random(#validEnemies)]
    end
end

---@param npc EntityNPC
local function checkTarget(npc)
    local data = npc:GetData()
    ---@return EntityRef | nil
    local target = data.Resouled_SiblingRivalryAngryTarget
    ---@type Entity | nil
    local targetE = target.Entity
    if target then
        if targetE then
            if targetE:IsDead() or targetE.HitPoints <= 0 then
                data.Resouled_SiblingRivalryAngryTarget = nil
                npc.Target = npc:GetPlayerTarget()
            end
        else
            data.Resouled_SiblingRivalryAngryTarget = nil
            npc.Target = npc:GetPlayerTarget()
        end
    end
end

---@param npc EntityNPC
---@return EntityRef | nil
local function getTarget(npc)
    return npc:GetData().Resouled_SiblingRivalryAngryTarget
end

---@param target EntityNPC
---@param angryNpc EntityNPC
local function isTarget(target, angryNpc)
    local target2 = getTarget(angryNpc)

    return target2 and target2.Entity.Index == target.Index
end

---@param npc EntityNPC
local function clearTarget(npc)
    local data = npc:GetData()
    if data.Resouled_SiblingRivalryAngryTarget then
        data.Resouled_SiblingRivalryAngryTarget = nil
    end
end

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    local target = getTarget(npc)

    if not target and npc.FrameCount % SiblingRivalry.AngryChanceRate == 0 and npc:IsActiveEnemy() and math.random() < SiblingRivalry.ChanceToGetAngry and PlayerManager.AnyoneHasCollectible(SiblingRivalry.ID) then
        makeAngry(npc)
    end

    if target then
        local color = npc.Color
        npc:SetColor(Color(color.R, color.G, color.B, color.A, color.RO + 1, color.GO, color.BO), 2, 1, false, true)

        npc.Target = target.Entity

        local pathfinder = npc.Pathfinder
        local checkLine = Game():GetRoom():CheckLine(npc.Position, target.Position, LineCheckMode.ENTITY)

        if not checkLine then
            pathfinder:FindGridPath(target.Position, npc.Friction, 1, true)
        else
            npc.Velocity = npc.Velocity + (target.Position - npc.Position):Normalized() * npc.Friction * SiblingRivalry.TargetSpeed
        end

        checkTarget(npc)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate)

---@param npc EntityNPC
---@param collider Entity
local function postNpcCollision(_, npc, collider)
    local npc2 = collider:ToNPC()
    if npc2 then
        if isTarget(npc2, npc) then
            npc2:TakeDamage(SiblingRivalry.Damage, DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(npc), 0)

            npc2.Velocity = npc2.Velocity + (npc2.Position - npc.Position):Normalized() * SiblingRivalry.Knockback

            clearTarget(npc)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_COLLISION, postNpcCollision)