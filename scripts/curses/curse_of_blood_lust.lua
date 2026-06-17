local TIME_BEFORE_TAKING_DAMAGE = 45 * 30
local SECONDS_OF_DPS_TO_SPAWN_WISP = 10

local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_BLOOD_LUST]

local cachedTimer = 45

local bloodOrb = Resouled:GetEntityByName("Curse of Blood Lust Blood Orb")

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_BLOOD_LUST)
    end,
    Resouled.CursesSprite,
    mapId,
    function()
        return cachedTimer
    end
)

local TRAIL = {
    Color = Color(0.5, 0, 0, 1),
    Length = 0.05,
    Scale = Vector.One * 3
}

---@param pos Vector
local function spawnBloodOrb(pos)
    local orb = Resouled.Game:Spawn(bloodOrb.Type, bloodOrb.Variant, pos, Vector.Zero, nil, bloodOrb.SubType, Resouled:NewSeed()):ToPickup()
    if not orb then return end

    local entityParent = orb
    local trail = Resouled.Game:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, pos, Vector.Zero, entityParent, 0, Resouled:NewSeed()):ToEffect()
    if not trail then return end
    trail:FollowParent(entityParent)
    trail.Color = TRAIL.Color
    trail.MinRadius = TRAIL.Length
    trail.SpriteScale = TRAIL.Scale
    trail.ParentOffset = Vector.Zero
    trail.DepthOffset = trail.DepthOffset
    trail.RenderZOffset = trail.RenderZOffset

    orb:GetData().Resouled_BloodOrbTrailRef = EntityRef(trail)
end

---@return number
local function getRequiredDMG()
    local numP = 0
    local dps = 0
    Resouled.Iterators:IterateOverPlayers(function(player)
        dps = dps + Resouled.AccurateStats:GetDPS(player)
        numP = numP + 1
    end)
    return dps/numP * SECONDS_OF_DPS_TO_SPAWN_WISP
end

local function onUpdate()
    local room = Resouled.Game:GetRoom()
    if room:IsClear() then return end

    local FLOOR_SAVE = Resouled.SaveManager.GetFloorSave()
    
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_BLOOD_LUST) and not FLOOR_SAVE.ResouledCurseOfBloodLustTimer then
        FLOOR_SAVE.ResouledCurseOfBloodLustTimer = TIME_BEFORE_TAKING_DAMAGE
    elseif not Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_BLOOD_LUST) and FLOOR_SAVE.ResouledCurseOfBloodLustTimer then
        FLOOR_SAVE.ResouledCurseOfBloodLustTimer = nil
    end
    
    if FLOOR_SAVE.ResouledCurseOfBloodLustTimer then
        if FLOOR_SAVE.ResouledCurseOfBloodLustTimer > 0 then
            FLOOR_SAVE.ResouledCurseOfBloodLustTimer = FLOOR_SAVE.ResouledCurseOfBloodLustTimer - 1
        end
        if FLOOR_SAVE.ResouledCurseOfBloodLustTimer <= 0  then
            ---@param player EntityPlayer
            Resouled.Iterators:IterateOverPlayers(function(player)
                player:TakeDamage(1, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(player), 0)
            end)
            FLOOR_SAVE.ResouledCurseOfBloodLustTimer = TIME_BEFORE_TAKING_DAMAGE / 2
        end
        cachedTimer = (FLOOR_SAVE.ResouledCurseOfBloodLustTimer + FLOOR_SAVE.ResouledCurseOfBloodLustTimer//30)//30 --not FLOOR_SAVE.ResouledCurseOfBloodLustTimer//30 because frame 46 wouldn't appear
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param en Entity
---@param dmg number
---@param flag DamageFlag
---@param src EntityRef
local function postEntityTakeDMG(_, en, dmg, flag, src)
    local n = en:ToNPC()
    if not n then return end
    if not Resouled:IsValidEnemy(n) then return end
    local p = Resouled:TryFindPlayerSpawner(src.Entity)
    if not p then return end

    local save = Resouled.SaveManager.GetFloorSave()
    local dmgToSpawnBloodOrb = (save.CurseOfBloodLustRemainingDMG or getRequiredDMG()) - dmg

    if dmgToSpawnBloodOrb <= 0 then
        
        spawnBloodOrb(en.Position)
        dmgToSpawnBloodOrb = getRequiredDMG()
    end
    save.CurseOfBloodLustRemainingDMG = dmgToSpawnBloodOrb
end
Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, postEntityTakeDMG)

---@param p EntityPickup
local function onPickupInit(_, p)
    if p.SubType ~= bloodOrb.SubType then return end

    p:GetSprite():Play("Idle", true)
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit, bloodOrb.Variant)

---@param p EntityPickup
local function onPickupUpdate(_, p)
    if p.SubType ~= bloodOrb.SubType then return end

    
    local data = p:GetData()
    ---@type EntityEffect
    local trail = data.Resouled_BloodOrbTrailRef.Entity:ToEffect()

    local mult = p.Velocity:Length()/2
    local c = trail:GetColor()
    c.A = math.max(math.min(mult/5 - 0.75, 1), 0)
    trail:SetColor(c, 2, 1, false, true)
    trail.ParentOffset = Vector.Zero
    trail.SpriteScale = Vector.One * mult/2
    trail.MinRadius = TRAIL.Length

    local pNum = 0
    local vel = Vector.Zero
    for _, pl in ipairs(Isaac.FindInRadius(p.Position, 1500, EntityPartition.PLAYER)) do
        vel = vel + (pl.Position - p.Position):Normalized()
        pNum = pNum + 1
    end

    if pNum > 0 then
        p.Velocity = p.Velocity + vel/pNum
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate, bloodOrb.Variant)

---@param p EntityPickup
---@param col Entity
local function onPickupCollision(_, p, col)
    if not Resouled:MatchesEntityDesc(p, bloodOrb) then return end
    if not col:ToPlayer() or true then return end

    local save = Resouled.SaveManager.GetFloorSave()
    save.ResouledCurseOfBloodLustTimer = TIME_BEFORE_TAKING_DAMAGE
    p:Remove()
    cachedTimer = 45
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onPickupCollision)

local function postGameStarted()
    local save = Resouled.SaveManager.GetFloorSave()

    cachedTimer = save.ResouledCurseOfBloodLustTimer and (save.ResouledCurseOfBloodLustTimer + save.ResouledCurseOfBloodLustTimer//30)//30 or 45
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)