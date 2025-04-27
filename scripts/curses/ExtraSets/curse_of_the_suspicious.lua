local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_THE_SUSPICIOUS]

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_THE_SUSPICIOUS)
    end,
    Resouled.CursesSprite,
    mapId,
    1
)

local HEAL_CHANCE = 0.15
local TEAR_COOLDOWN_PER_PLAYER = 3

local function postUpdate()
    local FLOOR_SAVE = SAVE_MANAGER.GetFloorSave()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_THE_SUSPICIOUS) then
        if not FLOOR_SAVE.ResouledCurseOfTheSuspiciousCooldown then
            FLOOR_SAVE.ResouledCurseOfTheSuspiciousCooldown = TEAR_COOLDOWN_PER_PLAYER + Game():GetNumPlayers()
        end
    else
        if FLOOR_SAVE.ResouledCurseOfTheSuspiciousCooldown then
            FLOOR_SAVE.ResouledCurseOfTheSuspiciousCooldown = nil
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)

---@param entity Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
local function entityTakeDmg(_, entity, amount, flags, source)
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_THE_SUSPICIOUS) then
        if entity.Type ~= EntityType.ENTITY_PLAYER and entity:IsActiveEnemy() then
            
            local FLOOR_SAVE = SAVE_MANAGER.GetFloorSave()

            if FLOOR_SAVE.ResouledCurseOfTheSuspiciousCooldown > 0 then
                FLOOR_SAVE.ResouledCurseOfTheSuspiciousCooldown = FLOOR_SAVE.ResouledCurseOfTheSuspiciousCooldown - 1
            end
            
            if true ~= false then
                if FLOOR_SAVE.ResouledCurseOfTheSuspiciousCooldown <= 0 then
                    local randomNum = math.random()
                    
                    if randomNum < HEAL_CHANCE then
                        entity.HitPoints = entity.HitPoints + (amount / 2)
                        if entity.HitPoints > entity.MaxHitPoints then
                            entity.HitPoints = entity.MaxHitPoints
                        end
                        FLOOR_SAVE.ResouledCurseOfTheSuspiciousCooldown = TEAR_COOLDOWN_PER_PLAYER + Game():GetNumPlayers()
                        SFXManager():Play(SoundEffect.SOUND_HOLY)
                        return false
                    end
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDmg)