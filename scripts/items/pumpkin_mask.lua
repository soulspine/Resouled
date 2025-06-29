local PUMPKIN_MASK = Isaac.GetItemIdByName("Pumpkin Mask")

local FEAR_TIME = 180

local SOUND_ID = Isaac.GetSoundIdByName("Jumpscare")

---@param entity Entity
---@param amount number
---@param flags DamageFlag
local function playerTakeDamage(_, entity, amount, flags)
    local player = entity:ToPlayer()
    if player:HasCollectible(PUMPKIN_MASK) then
        ---@param npc EntityNPC
        Resouled.Iterators:IterateOverRoomNpcs(function(npc)
            if npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() then
                npc:AddFear(EntityRef(player), FEAR_TIME)
                ItemOverlay.Show(Isaac.GetGiantBookIdByName("Pumpkin Mask"), 0, player)
                SFXManager():Play(SOUND_ID)
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, playerTakeDamage, EntityType.ENTITY_PLAYER)