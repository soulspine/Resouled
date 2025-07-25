local mod = Resouled
local TurtleLightning = {}

local ITEM = Isaac.GetItemIdByName("Turtle Lightningt")



function TurtleLightning:HUDOffset(x, y, anchor)
    local notches = math.floor(Options.HUDOffset * 10 + 0.5)
    local xoffset = (notches*2)
    local yoffset = ((1/8)*(10*notches+(-1)^notches+7))
    if anchor == 'topleft' then
      xoffset = x+xoffset
      yoffset = y+yoffset
    elseif anchor == 'topright' then
      xoffset = x-xoffset
      yoffset = y+yoffset
    elseif anchor == 'bottomleft' then
      xoffset = x+xoffset
      yoffset = y-yoffset
    elseif anchor == 'bottomright' then
      xoffset = x-xoffset * 0.8
      yoffset = y-notches * 0.6
    else
      error('invalid anchor provided. Must be one of: \'topleft\', \'topright\', \'bottomleft\', \'bottomright\'', 2)
    end
    return math.floor(xoffset + 0.5), math.floor(yoffset + 0.5)
end

local SelectedPickup = 1

local selector = Sprite()
selector:Load("gfx/ui/selector_box.anm2")
local selectorPos = Vector(TurtleLightning:HUDOffset(8, 38, 'topleft'))

local callbacksActive = false

---@param player EntityPlayer
function TurtleLightning:Update(player)
    if not player:HasCollectible(ITEM) then return end
    local pressed = Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex)
    if not pressed then return end
    selector:Play("Select", true)

    SelectedPickup = SelectedPickup + 1 or 1

    if SelectedPickup > 3 then
        SelectedPickup = 1
    end

    if SelectedPickup == 1 then
        selectorPos = Vector(TurtleLightning:HUDOffset(8, 38, 'topleft'))
    elseif SelectedPickup == 2 then
        selectorPos = Vector(TurtleLightning:HUDOffset(8, 50, 'topleft'))
    elseif SelectedPickup == 3 then
        selectorPos = Vector(TurtleLightning:HUDOffset(8, 62, 'topleft'))
    end
end

function TurtleLightning:RenderSelectionBox()
    selector:Render(selectorPos)
end

function TurtleLightning:SelectionBoxUpdate()
    selector:Update()
    if selector:IsFinished("Select") or selector:GetAnimation() == "" then
        selector:Play("Idle")
    end
end


function TurtleLightning:AddCallbacks()
    if PlayerManager.AnyoneHasCollectible(ITEM) and not callbacksActive then
        mod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, TurtleLightning.RenderSelectionBox)
        mod:AddCallback(ModCallbacks.MC_POST_UPDATE, TurtleLightning.SelectionBoxUpdate)
        mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, TurtleLightning.Update, PlayerVariant.PLAYER)
        callbacksActive = true
    end
end
TurtleLightning:AddCallbacks()

mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, TurtleLightning.AddCallbacks, ITEM)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, TurtleLightning.AddCallbacks)

function TurtleLightning:RemoveCallbacks(_, _, force)
    if (not PlayerManager.AnyoneHasCollectible(ITEM) or force) and callbacksActive then
        mod:RemoveCallback(ModCallbacks.MC_POST_HUD_RENDER, TurtleLightning.RenderSelectionBox)
        mod:RemoveCallback(ModCallbacks.MC_POST_UPDATE, TurtleLightning.SelectionBoxUpdate)
        mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, TurtleLightning.Update)
        callbacksActive = false
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, TurtleLightning.RemoveCallbacks, ITEM)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
    TurtleLightning:RemoveCallbacks(nil, nil, true)
end)

ThrowableItemLib:RegisterThrowableItem({
    ID = ITEM,
    Type = ThrowableItemLib.Type.ACTIVE,
    Identifier = "Turtle",
    ThrowFn = function (player, vect)
    

        if SelectedPickup == 1  and player:GetNumCoins() >= 3 then
            local tear = player:FireTear(player.Position, vect:Resized(player.ShotSpeed * 10) + player:GetTearMovementInheritance(vect))
            tear.TearFlags = TearFlags.TEAR_NORMAL
            player:AddCoins(-3)
            tear:ChangeVariant(TearVariant.COIN)
            tear:AddTearFlags(TearFlags.TEAR_MIDAS | TearFlags.TEAR_GREED_COIN)
            tear.CollisionDamage = tear.CollisionDamage * 3

            local tear2 = player:FireTear(player.Position, vect:Resized(player.ShotSpeed * 10) + player:GetTearMovementInheritance(vect))
            tear2.TearFlags = TearFlags.TEAR_NORMAL
            tear2:ChangeVariant(TearVariant.KEY)
            tear2:ChangeVariant(TearVariant.COIN)
            tear2:AddTearFlags(TearFlags.TEAR_MIDAS | TearFlags.TEAR_GREED_COIN)
            tear2.CollisionDamage = tear.CollisionDamage * 3
            tear2.Velocity = tear.Velocity:Rotated(10)

            local tear3 = player:FireTear(player.Position, vect:Resized(player.ShotSpeed * 10) + player:GetTearMovementInheritance(vect))
            tear3.TearFlags = TearFlags.TEAR_NORMAL
            tear3:ChangeVariant(TearVariant.KEY)
            tear3:ChangeVariant(TearVariant.COIN)
            tear3:AddTearFlags(TearFlags.TEAR_MIDAS | TearFlags.TEAR_GREED_COIN)
            tear3.CollisionDamage = tear.CollisionDamage * 3
            tear3.Velocity = tear.Velocity:Rotated(-10)


        elseif SelectedPickup == 2 then

        elseif SelectedPickup == 3 and player:GetNumKeys() >= 2 then
            player:AddKeys(-2)
            local tear = player:FireTear(player.Position, vect:Resized(player.ShotSpeed * 10) + player:GetTearMovementInheritance(vect))
            tear.TearFlags = TearFlags.TEAR_NORMAL
            tear:ChangeVariant(TearVariant.KEY)
            tear:AddTearFlags(TearFlags.TEAR_PIERCING)
            tear.CollisionDamage = tear.CollisionDamage * 3
            tear.Velocity = tear.Velocity:Rotated(-10)

            local tear2 = player:FireTear(player.Position, vect:Resized(player.ShotSpeed * 10) + player:GetTearMovementInheritance(vect))
            tear2.TearFlags = TearFlags.TEAR_NORMAL
            tear2:ChangeVariant(TearVariant.KEY)
            tear2:AddTearFlags(TearFlags.TEAR_PIERCING)
            tear2.CollisionDamage = tear.CollisionDamage * 3
            tear2.Velocity = tear2.Velocity:Rotated(10)
        else
            ThrowableItemLib.Utility:HideItem(player, false)
        end
    end,
    AnimateFn = function (player, state)
        local throwSprite = Sprite()
        if SelectedPickup == 1 then
            throwSprite:Load("gfx/002.020_coin tear.anm2", true)
            throwSprite:Play("Rotate3")
        elseif SelectedPickup == 2 then
        elseif SelectedPickup == 3 then
            throwSprite:Load("gfx/002.043_key tear.anm2", true)
            throwSprite:Play(throwSprite:GetDefaultAnimation())
        end

        if state == ThrowableItemLib.State.LIFT then
            player:AnimatePickup(throwSprite, true, "LiftItem")
            return true
        elseif state == ThrowableItemLib.State.HIDE or ThrowableItemLib.State.THROW then
            player:AnimatePickup(throwSprite, true, "HideItem")
            return true
        end
    end,
    LiftFn = function (player, continued, slot, mimic)
        if SelectedPickup == 2 and player:GetNumBombs() >= 1 then
            player:AddBombs(-1)
            local bomb = player:FireBomb(player.Position, Vector.Zero, player)
            bomb:SetExplosionCountdown(60)
            player:TryHoldEntity(bomb)
        end
    end,
    HoldCondition = function (player, state)
        if SelectedPickup == 1 and player:GetNumCoins() >= 3 then
            return ThrowableItemLib.HoldConditionReturnType.ALLOW_HOLD
        elseif SelectedPickup == 2 and player:GetNumBombs() >= 1 then
            return ThrowableItemLib.HoldConditionReturnType.ALLOW_HOLD
        elseif SelectedPickup == 3 and player:GetNumKeys() >= 2 then
            return ThrowableItemLib.HoldConditionReturnType.ALLOW_HOLD
        end
        return ThrowableItemLib.HoldConditionReturnType.DISABLE_USE
    end
})