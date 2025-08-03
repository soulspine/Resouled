local CURSED_SOUL = Isaac.GetItemIdByName("Cursed Soul")

local e = Resouled.EID

if EID then
    EID:addCollectible(CURSED_SOUL,
    "When taking damage you have a chance to gain a soul"..e:FadeWarningNextLine("When entering an uncleared room you take damage (can't kill you)")..e:FadePositiveStatNextLine("If you don't get a soul on hit, your chance to gain a soul goes up")..e:FadeWarningNextLine("Spawns up to 6 souls"))
end

local SOULS_PER_ITEM = 6
local SOUL_OBTAIN_CHANCE = 0.25

---@param type CollectibleType
---@param firstTime boolean
---@param player EntityPlayer
local function postAddCollectible(_, type, charge, firstTime, slot, varData, player)
    if type == CURSED_SOUL and firstTime then
        local RUN_SAVE = SAVE_MANAGER.GetRunSave(player)
        if not RUN_SAVE.Resouled_CursedSoul then
            RUN_SAVE.Resouled_CursedSoul = {
                SOULS = SOULS_PER_ITEM,
                CHANCE = SOUL_OBTAIN_CHANCE,
            }
        else
            RUN_SAVE.Resouled_CursedSoul.SOULS = RUN_SAVE.Resouled_CursedSoul.SOULS + SOULS_PER_ITEM
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddCollectible)

---@param entity Entity
---@param amount number
---@param flags DamageFlag
local function playerTakeDamage(_, entity, amount, flags)
    local player = entity:ToPlayer()
    local RUN_SAVE = SAVE_MANAGER.GetRunSave(player)
    if RUN_SAVE.Resouled_CursedSoul and RUN_SAVE.Resouled_CursedSoul.SOULS > 0 then
        if DamageFlag ~= DamageFlag.DAMAGE_FAKE and player:HasCollectible(CURSED_SOUL) then
            local randomNum = math.random()
            if randomNum < RUN_SAVE.Resouled_CursedSoul.CHANCE then
                RUN_SAVE.Resouled_CursedSoul.SOULS = RUN_SAVE.Resouled_CursedSoul.SOULS - 1
                Resouled:SetPossessedSoulsNum(Resouled:GetPossessedSoulsNum() + 1)
            else
                RUN_SAVE.Resouled_CursedSoul.CHANCE = RUN_SAVE.Resouled_CursedSoul.CHANCE + SOUL_OBTAIN_CHANCE
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, playerTakeDamage, EntityType.ENTITY_PLAYER)

local function postNewRoom()
    if not Game():GetRoom():IsClear() then
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            local RUN_SAVE = SAVE_MANAGER.GetRunSave(player)
            if RUN_SAVE.Resouled_CursedSoul and RUN_SAVE.Resouled_CursedSoul.SOULS > 0 and Resouled.AccurateStats:GetEffectiveHP(player) > 1 then
                player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)