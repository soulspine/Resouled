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

---@param entity Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
local function entityTakeDmg(_, entity, amount, flags, source)
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_THE_SUSPICIOUS) then
        if entity.Type ~= EntityType.ENTITY_PLAYER and entity:IsActiveEnemy() then
            
            local data = entity:GetData()

            if not data.ResouledCurseOfTheSuspiciousCooldown then
                data.ResouledCurseOfTheSuspiciousCooldown = TEAR_COOLDOWN_PER_PLAYER + Game():GetNumPlayers()
            end

            if data.ResouledCurseOfTheSuspiciousCooldown > 0 then
                data.ResouledCurseOfTheSuspiciousCooldown = data.ResouledCurseOfTheSuspiciousCooldown - 1
            end

            if data.ResouledCurseOfTheSuspiciousCooldown <= 0 then
                local randomNum = math.random()
                
                if randomNum < HEAL_CHANCE then
                    entity.HitPoints = entity.HitPoints + (amount / 2)
                    if entity.HitPoints > entity.MaxHitPoints then
                        entity.HitPoints = entity.MaxHitPoints
                    end
                    data.ResouledCurseOfTheSuspiciousCooldown = TEAR_COOLDOWN_PER_PLAYER + Game():GetNumPlayers()
                    SFXManager():Play(SoundEffect.SOUND_HOLY)
                    return false
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDmg)