local DEATH_STATUE_VARIANT = Isaac.GetEntityVariantByName("Death Statue")
local DEATH_STATUE_SUBTYPE = Isaac.GetEntitySubTypeByName("Death Statue")

local function preRoomExit()
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    if ROOM_SAVE.Resouled_DeathStatue then
        return
    end
    ---@param entity Entity
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local effect = entity:ToEffect()
        if effect then
            if effect.Variant == DEATH_STATUE_VARIANT and effect.SubType == DEATH_STATUE_SUBTYPE then
                if not ROOM_SAVE.Resouled_DeathStatue then
                    ROOM_SAVE.Resouled_DeathStatue = {}
                end
                table.insert(ROOM_SAVE.Resouled_DeathStatue, effect.Position)
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, preRoomExit)

local function postNewRoom()
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    if ROOM_SAVE.Resouled_DeathStatue then
        for i = 1, #ROOM_SAVE.Resouled_DeathStatue do
            Game():Spawn(EntityType.ENTITY_EFFECT, DEATH_STATUE_VARIANT, ROOM_SAVE.Resouled_DeathStatue[i], Vector.Zero, nil, DEATH_STATUE_SUBTYPE, Game():GetRoom():GetSpawnSeed())
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)