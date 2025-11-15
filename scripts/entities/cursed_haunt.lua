local game = Game()

local ID = Isaac.GetEntityTypeByName("Cursed Haunt")
local VARIANT = Isaac.GetEntityVariantByName("Cursed Haunt")
local SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Haunt")

local CursedHauntPhasesConfig = {
    Phase1 = {
        MoveSpeed = 0.95,
    }
}

local lilHauntConfig = {
    ID = Isaac.GetEntityTypeByName("Cursed Lil Haunt"),
    VARIANT = Isaac.GetEntityVariantByName("Cursed Lil Haunt"),
    SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Lil Haunt"),
    InitSpawnCount = 3,
    DistanceFromParent = 50,
    PostSpawnChaseCooldown = 60,
    RotateSpeed = 2,
}

---@param npc EntityNPC
local function setTransparentColor(npc)
    npc:SetColor(Color(nil, nil, nil, 0.5), 2, 1000, false, true)
end

---@param parent EntityNPC
local function spawnLilHaunts(parent)
    local offset = Vector(0, -lilHauntConfig.DistanceFromParent)
    local parentData = parent:GetData()
    if not parentData.Resouled_CursedHauntLilHaunts then parentData.Resouled_CursedHauntLilHaunts = {} end

    for _ = 1, lilHauntConfig.InitSpawnCount do
        local haunt = game:Spawn(lilHauntConfig.ID, lilHauntConfig.VARIANT, parent.Position + offset, Vector.Zero, parent, lilHauntConfig.SUBTYPE, Random()):ToNPC()

        haunt:GetData().Resouled_CursedHauntMinion = {
            ChaseCooldown = lilHauntConfig.PostSpawnChaseCooldown,
            Offset = offset
        }
        offset = offset:Rotated(360/lilHauntConfig.InitSpawnCount)

        haunt.State = NpcState.STATE_IDLE
        haunt.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        haunt.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        
        table.insert(parentData.Resouled_CursedHauntLilHaunts, EntityRef(haunt))
    end
end

---@param wall integer
---@return number
local function getLockedToWallY(wall)
    local room = game:GetRoom()
    local y
    if wall == 0 then
        y = room:GetTopLeftPos().Y + 30
    else
        y = room:GetBottomRightPos().Y - 30
    end
    return y
end

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == VARIANT and npc.SubType == SUBTYPE then
        spawnLilHaunts(npc)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.I2 = 1
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, ID)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == VARIANT and npc.SubType == SUBTYPE then
        local data = npc:GetData()

        if data.Resouled_CursedHauntLilHaunts or data.Resouled_CursedHauntReleasedLilHaunts then --Phase 1

            npc.Pathfinder:MoveRandomlyBoss(false)

            setTransparentColor(npc)
            npc.Velocity = npc.Velocity * CursedHauntPhasesConfig.Phase1.MoveSpeed

            local lilHaunts = data.Resouled_CursedHauntLilHaunts
            local deadCount = 0

            if data.Resouled_CursedHauntReleasedLilHaunts then
                ---@param lilHauntRef EntityRef
                for _, lilHauntRef in ipairs(data.Resouled_CursedHauntReleasedLilHaunts) do
                    if lilHauntRef.Entity:IsDead() then
                        deadCount = deadCount + 1
                    end
                end
            end

            if lilHaunts then
                ---@param lilHauntRef EntityRef
                for i, lilHauntRef in ipairs(lilHaunts) do
                    local lilHaunt = lilHauntRef.Entity
                    if not lilHaunt:IsDead() then
                        local lilHauntData = lilHaunt:GetData()
                        lilHaunt.Position = npc.Position + lilHauntData.Resouled_CursedHauntMinion.Offset
                        lilHauntData.Resouled_CursedHauntMinion.Offset = lilHauntData.Resouled_CursedHauntMinion.Offset:Rotated(lilHauntConfig.RotateSpeed)
                        
                        lilHauntData.Resouled_CursedHauntMinion.ChaseCooldown = math.max(lilHauntData.Resouled_CursedHauntMinion.ChaseCooldown - 1, 0)


                        if lilHauntData.Resouled_CursedHauntMinion.ChaseCooldown <= 0 and not data.Resouled_CursedHauntReleasedLilHaunts then

                            data.Resouled_CursedHauntReleasedLilHaunts = {}

                            lilHauntData.Resouled_CursedHauntMinion = nil
                                
    
                            table.insert(data.Resouled_CursedHauntReleasedLilHaunts, EntityRef(lilHaunt))
                            table.remove(data.Resouled_CursedHauntLilHaunts, i)
                            break
                        elseif lilHauntData.Resouled_CursedHauntMinion.ChaseCooldown <= 0 and data.Resouled_CursedHauntReleasedLilHaunts
                        and deadCount == 1 then
                            lilHauntData.Resouled_CursedHauntMinion = nil
                                
    
                            table.insert(data.Resouled_CursedHauntReleasedLilHaunts, EntityRef(lilHaunt))
                            table.remove(data.Resouled_CursedHauntLilHaunts, 1)
                        end
                    end
                end
                
                if deadCount == 3 then
                    data.Resouled_CursedHauntLilHaunts = nil
                    data.Resouled_CursedHauntReleasedLilHaunts = nil
                end
            end
        else
            local pos = npc.Position
            local velocity = npc.Velocity

            if not data.Resouled_CursedHauntTargetY then
                npc.I1 = 0
                data.Resouled_CursedHauntTargetY = getLockedToWallY(npc.I1)
            end

            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

            local distance = data.Resouled_CursedHauntTargetY - pos.Y
            pos.Y = pos.Y + (distance)/5
            
            if math.abs(distance) > 4.5 then
                velocity.X = 0
            else
                if not game:GetRoom():IsPositionInRoom(pos + velocity * 2, 5) then
                    npc.I2 = -npc.I2
                end
                velocity.X = 7 * npc.I2
            end

            velocity.Y = 0

            npc.Velocity = velocity
            npc.Position = pos
        end


        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate, ID)

---@param npc EntityNPC
local function onLilHauntUpdate(_, npc)
    if npc.Variant == lilHauntConfig.VARIANT and npc.SubType == lilHauntConfig.SUBTYPE then
        local data = npc:GetData()
        if data.Resouled_CursedHauntMinion then
            local sprite = npc:GetSprite()
            sprite:SetFrame("Idle", (sprite:GetFrame() + 1)%sprite:GetAnimationData("Idle"):GetLength())

            npc.Velocity = Vector.Zero

            setTransparentColor(npc)

            return true
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onLilHauntUpdate, lilHauntConfig.ID)