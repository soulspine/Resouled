local THE_MONSTER = Isaac.GetItemIdByName("The Monster")

local Monster = {
    Sprite = Sprite(),
    HeadDirTranslation = {[0] = "Left", [1] = "Up", [2] = "Right", [3] = "Down"},
    OffsetPerMonster = 13,
    AlphaWhenItemPickup = 0.2,
    AlphaToSubtractPerMonster = 0, --Make dss option
}

Monster.Sprite:Load("gfx/the_monster.anm2", true)

---@param player EntityPlayer
local function onPlayerRender(_, player)
    if player:HasCollectible(THE_MONSTER) and player:IsVisible() then
        for i = 0, player:GetCollectibleNum(THE_MONSTER) - 1 do
            local headDir = player:GetHeadDirection()
            local playerSprite = player:GetSprite()

            Monster.Sprite.Offset = Vector(0, 0)

            Monster.Sprite.Color.A = 1

            local playerAnimation = playerSprite:GetAnimation()
            if playerAnimation:find("Item") or playerAnimation:find("Pickup") then
                local alpha = Monster.AlphaWhenItemPickup * i
                if alpha > 1 then
                    alpha = 1
                end
                Monster.Sprite.Color.A = 0 + alpha --Make picked up things visible through the monsters
            end

            Monster.Sprite.Color.A = Monster.Sprite.Color.A - Monster.AlphaToSubtractPerMonster * i --Make the stack less and less visible
            
            Monster.Sprite:Play(Monster.HeadDirTranslation[headDir], true) --Rotate correctly
            
            Monster.Sprite.Scale = player.SpriteScale * playerSprite:GetLayer("head"):GetSize() --Set correct size
            
            Monster.Sprite.Offset.Y = (Monster.Sprite.Offset.Y - Monster.OffsetPerMonster * i) * Monster.Sprite.Scale.Y --Make them stack

            local pos = player.Position + player.SpriteOffset
            
            if playerSprite:GetOverlayAnimation():find("Head") and playerSprite:GetOverlayFrame() > 0 then --Player is shooting
                pos = pos + Vector(0, 2)
            end
            local renderPos = Isaac.WorldToScreen(pos)
            
            Monster.Sprite:Render(renderPos)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, onPlayerRender)