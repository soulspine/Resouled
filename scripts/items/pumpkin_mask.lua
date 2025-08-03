---@diagnostic disable: need-check-nil
local PUMPKIN_MASK = Isaac.GetItemIdByName("Pumpkin Mask")

local e = Resouled.EID

if EID then
    EID:addCollectible(PUMPKIN_MASK,
    "When taking damage "..e:FadeBlue("fears all enemies").." in the room")
end

local FEAR_TIME = 180

local COSTUME_ID = Isaac.GetCostumeIdByPath("gfx/characters/pumpkin_mask.anm2")
local SOUND_ID = Isaac.GetSoundIdByName("Jumpscare")

---@param entity Entity
---@param amount number
---@param flags DamageFlag
local function playerTakeDamage(_, entity, amount, flags)
    local player = entity:ToPlayer()
    if player:HasCollectible(PUMPKIN_MASK) then
        ItemOverlay.Show(Isaac.GetGiantBookIdByName("Pumpkin Mask"), 0, player)
        SFXManager():Play(SOUND_ID)
        player:AddNullCostume(COSTUME_ID)
        Resouled.Iterators:IterateOverRoomNpcs(function(npc)
            if npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() then
                npc:AddFear(EntityRef(player), FEAR_TIME)
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, playerTakeDamage, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
---@param newLevel boolean
local function preRoomExit(_, player, newLevel)
    player:TryRemoveNullCostume(COSTUME_ID)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, preRoomExit)