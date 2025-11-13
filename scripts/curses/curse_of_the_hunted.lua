local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_THE_HUNTED]

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_THE_HUNTED)
    end,
    Resouled.CursesSprite,
    mapId,
    1
)

local HUNTER_TYPE = Isaac.GetEntityTypeByName("Hunter")
local HUNTER_VARIANT = Isaac.GetEntityVariantByName("Hunter")
local HUNTER_SUBTYPE = Isaac.GetEntityTypeByName("Hunter")

local MIN_COOLDOWN = 13
local MAX_COOLDOWN = 22

local function postUpdate()
    local FLOOR_SAVE = Resouled.SaveManager.GetFloorSave()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_THE_HUNTED) then
        local room = Game():GetRoom()
        if not FLOOR_SAVE.ResouledCurseOfTheHuntedCooldown then
            FLOOR_SAVE.ResouledCurseOfTheHuntedCooldown = math.random(MIN_COOLDOWN, MAX_COOLDOWN) * 30
        end
        if FLOOR_SAVE.ResouledCurseOfTheHuntedCooldown then
            if FLOOR_SAVE.ResouledCurseOfTheHuntedCooldown > 0 then
                FLOOR_SAVE.ResouledCurseOfTheHuntedCooldown = FLOOR_SAVE.ResouledCurseOfTheHuntedCooldown - 1
            end

            if FLOOR_SAVE.ResouledCurseOfTheHuntedCooldown == 0 and not room:IsClear() then
                local randomPlayerID = math.random(0, Game():GetNumPlayers()-1)
                local player = Isaac.GetPlayer(randomPlayerID)
                local playerPos = player.Position
                local randomAngle = math.random(0, 360)
                local distanceFromPlayer = math.random(75, 150)
                local spawnPos = playerPos + Vector(1, 0):Normalized():Rotated(randomAngle) * distanceFromPlayer
                Game():Spawn(HUNTER_TYPE, HUNTER_VARIANT, spawnPos, Vector.Zero, nil, HUNTER_SUBTYPE, room:GetSpawnSeed())
                FLOOR_SAVE.ResouledCurseOfTheHuntedCooldown = math.random(MIN_COOLDOWN, MAX_COOLDOWN) * 30
            end
        end
    else
        if FLOOR_SAVE.ResouledCurseOfTheHuntedCooldown then
            FLOOR_SAVE.ResouledCurseOfTheHuntedCooldown = nil
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)