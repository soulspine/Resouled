local CHUNK_OF_AMBER = Isaac.GetCardIdByName("Chunk of Amber")

if EID then
    EID:addCard(CHUNK_OF_AMBER, "Doubles amounts of the following:#{{Coin}} Coins#{{Bomb}} Bombs#{{Key}} Keys#{{PoopPickup}} Poop Mana (Tainted ???)#{{SoulHeart}} Soul Charge (Bethany)#{{Heart}} Blood Charge (Tainted Bethany)", "Chunk of Amber")
    -- TODO EID.addIcon
end

local function onRuneUse()
    local player = Isaac.GetPlayer()
    player:AddCoins(player:GetNumCoins())
    print(player:GetNumCoins())
    player:AddBombs(player:GetNumBombs())
    player:AddKeys(player:GetNumKeys())
    player:AddPoopMana(player:GetPoopMana())
    player:AddSoulCharge(player:GetSoulCharge())
    player:AddBloodCharge(player:GetBloodCharge())
end
MOD:AddCallback(ModCallbacks.MC_USE_CARD, onRuneUse, CHUNK_OF_AMBER)