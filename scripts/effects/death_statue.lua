local DeathStatue = Resouled.Stats.DeathStatue

local function preRoomExit()
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    if ROOM_SAVE.Resouled_DeathStatue then
        return
    end
    ---@param entity Entity
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local effect = entity:ToEffect()
        if effect then
            if effect.Variant == DeathStatue.Variant and effect.SubType == DeathStatue.SubType then
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
            Game():Spawn(EntityType.ENTITY_EFFECT, DeathStatue.Variant, ROOM_SAVE.Resouled_DeathStatue[i], Vector.Zero, nil, DeathStatue.SubType, Game():GetRoom():GetSpawnSeed())
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

---@param effect EntityEffect
local function onEffectUpdate(_, effect)
    if effect.SubType == DeathStatue.SubType then
        local players = Isaac.FindInRadius(effect.Position, DeathStatue.Size, EntityPartition.PLAYER)

        for _, player in ipairs(players) do
            player.Velocity = player.Velocity + (player.Position - effect.Position):Normalized() * player.Velocity:Length()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, onEffectUpdate, DeathStatue.Variant)