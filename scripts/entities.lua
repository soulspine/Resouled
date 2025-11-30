local cursedEnemies = {}

---@param id integer
---@param var? integer
---@param sub? integer
---@param cId integer
---@param cVar integer
---@param cSub integer
---@return boolean -- Returns false if there's already a morph registered under this id
function Resouled:RegisterCursedEnemyMorph(id, var, sub, cId, cVar, cSub)
    local config = {Id = cId, Var = cVar, Sub = cSub}

    if not sub then
        if not var then
            local key = tostring(id)
            if not cursedEnemies[key] then
                cursedEnemies[key] = config
                return true
            else
                return false
            end
        else
            local key = tostring(id).."."..tostring(var)
            if not cursedEnemies[key] then
                cursedEnemies[key] = config
                return true
            else
                return false
            end
        end
    else
        local key = tostring(id).."."..tostring(var).."."..tostring(sub)
        if not cursedEnemies[key] then
            cursedEnemies[key] = config
            return true
        else
            return false
        end
    end
end

---@param npc EntityNPC
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
    local EverythingIsCursed = Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.EverythingIsCursed)
    if Game():GetLevel():GetCurses() > 0 or EverythingIsCursed then
        local key1 = tostring(npc.Type)
        local key2 = key1.."."..tostring(npc.Variant)
        local key3 = key2.."."..tostring(npc.SubType)
        
        if cursedEnemies[key1] or cursedEnemies[key2] or cursedEnemies[key3] then
            
            local config = cursedEnemies[key3] or cursedEnemies[key2] or cursedEnemies[key1]

            Resouled:TryEnemyMorph(npc, EverythingIsCursed and 1 or Resouled.Stats.CursedEnemyMorphChance(), config.Id, config.Var, config.Sub)
        end
    end
end)

include("scripts.entities.cursed_gaper")
include("scripts.entities.cursed_fatty")
include("scripts.entities.cursed_keeper_head")
include("scripts.entities.cursed_horf")
include("scripts.entities.cursed_psy_horf")
include("scripts.entities.cursed_moms_hand")
include("scripts.entities.cursed_mulligan")
include("scripts.entities.cursed_tumor")
include("scripts.entities.cursed_lil_haunt")
include("scripts.entities.cursed_mulliboom")
include("scripts.entities.cursed_dople")
include("scripts.entities.hunter")
include("scripts.entities.holy_portal")
include("scripts.entities.holy_brain")
include("scripts.entities.holy_dip")
include("scripts.entities.cursed_haunt")
include("scripts.entities.coil")
include("scripts.entities.weltling")
include("scripts.entities.blank_canvas_mulligan")
include("scripts.entities.blank_canvas_gaper")
include("scripts.entities.blank_canvas_fly")
include("scripts.entities.blank_canvas_pooter")
include("scripts.entities.blank_canvas_tear")
include("scripts.entities.blank_canvas_dip")
include("scripts.entities.holy_psy_horf")
include("scripts.entities.proglottid_egg")
include("scripts.entities.isaac_enemy")
include("scripts.entities.holy_squirt")

include("scripts.effects.stun_tentacle")

include("scripts.entities.resouled_dummy")
include("scripts.entities.resouled_hitbox")

include("scripts.entities.lightswitch")
