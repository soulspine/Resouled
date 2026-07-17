local TIME_BEFORE_TAKING_DAMAGE = 45 * 30
local SECONDS_OF_DPS_TO_SPAWN_WISP = 10

local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_BLOOD_LUST]

local bloodOrb = Resouled:GetEntityByName("Curse of Blood Lust Blood Orb")

local sprite = Sprite()
sprite:Load("gfx_resouled/ui/curse_of_blood_lust.anm2")
sprite:Play("ResouledCurseOfBloodLust")
local coverLeft = sprite:GetLayer("Cover1")
local coverRight = sprite:GetLayer("Cover2")
local coverDark = sprite:GetLayer("Cover3")
if not coverDark or not coverLeft or not coverRight then return end

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_BLOOD_LUST)
    end,
    sprite,
    mapId,
    function()
        return 1
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

    for _, pl in ipairs(Isaac.FindInRadius(p.Position, 1500, EntityPartition.PLAYER)) do

        if p.Position:Distance(pl.Position) > 75 then
            
            p.Velocity = (p.Velocity + (pl.Position - p.Position):Resized(3)) * 0.875
        else

            p.Velocity = (p.Velocity + (pl.Position - p.Position):Resized(9)) * 0.775
        end
    end

    p.SpriteRotation = p.Velocity:GetAngleDegrees()

    local scale = math.max((10 + p.Velocity:Length())/15, 1)
    p.SpriteScale = Vector.One * Vector(scale, math.min(2/scale, 1))
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate, bloodOrb.Variant)

---@param p EntityPickup
---@param col Entity
local function onPickupCollision(_, p, col)
    if not Resouled:MatchesEntityDesc(p, bloodOrb) then return end
    local pl = col:ToPlayer()
    if not pl then return end

    local save = Resouled.SaveManager.GetFloorSave()
    save.ResouledCurseOfBloodLustTimer = TIME_BEFORE_TAKING_DAMAGE
    p.Visible = false
    p:GetData().Resouled_BloodOrbTrailRef.Entity:Remove()
    p:Remove()

    local c = pl:GetColor()
    c.G = 0
    c.B = 0
    c.RO = 0.25
    pl:SetColor(c, 20, 1, true, true)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onPickupCollision)

local function postRender()
    if not Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_BLOOD_LUST) then return end

    local save = Resouled.SaveManager.GetFloorSave()
    if not save.ResouledCurseOfBloodLustTimer then return end

    local x = TIME_BEFORE_TAKING_DAMAGE/2
    local timer = TIME_BEFORE_TAKING_DAMAGE - save.ResouledCurseOfBloodLustTimer
    coverDark:SetVisible(not (save.ResouledCurseOfBloodLustTimer > x))

    if not coverDark:IsVisible() then
            
        if not coverRight:IsVisible() then coverRight:SetVisible(true) end

        coverRight:SetRotation(timer/x * 180)
        coverLeft:SetRotation(0)
    else

        if coverRight:IsVisible() then coverRight:SetVisible(false) end

        coverLeft:SetRotation((timer - x)/x * 180)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, postRender)