local FORGOTTEN_BODY_TYPE = 3
local FORGOTTEN_BODY_VARIANT = 900
local FORGOTTEN_BODY_SUBTYPE = 0

---@param player EntityPlayer
local function onActiveUse(_, type, rng, player)
    local RUN_SAVE = SAVE_MANAGER.GetRunSave()
    if not RUN_SAVE.ResouledForgottenSacrificed then
        if Isaac.GetPersistentGameData():Unlocked(Achievement.FORGOTTEN) then
            if player:GetPlayerType() == PlayerType.PLAYER_THESOUL then
                local room = Game():GetRoom()
                if room:GetType() == RoomType.ROOM_BOSSRUSH then
                    if player:GetSubPlayer():GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
                        ---@param entity Entity
                        Resouled:IterateOverRoomEntities(function(entity)
                            if entity.Type == FORGOTTEN_BODY_TYPE and entity.Variant == FORGOTTEN_BODY_VARIANT and entity.SubType == FORGOTTEN_BODY_SUBTYPE then
                                entity:Remove()
                                player:AddBoneHearts(-12)
                                RUN_SAVE.ResouledForgottenSacrificed = {}
                                RUN_SAVE.ResouledForgottenSacrificed[tostring(player:GetPlayerIndex())] = 1
                                Resouled:TrySpawnSoulPickup(Resouled.Souls.THE_BONE, entity.Position)
                                SFXManager():Play(SoundEffect.SOUND_BONE_SNAP)
                            end
                        end)
                    end
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse)

local function postNewRoom()
    local RUN_SAVE = SAVE_MANAGER.GetRunSave()
    local removedForgottens = 0
    if RUN_SAVE.ResouledForgottenSacrificed then
        ---@param player EntityPlayer
        Resouled:IterateOverPlayers(function(player)
            if RUN_SAVE.ResouledForgottenSacrificed then
                if RUN_SAVE.ResouledForgottenSacrificed[tostring(player:GetPlayerIndex())] then
                    ---@param entity Entity
                    Resouled:IterateOverRoomEntities(function(entity)
                        if entity.Type == FORGOTTEN_BODY_TYPE and entity.Variant == FORGOTTEN_BODY_VARIANT and entity.SubType == FORGOTTEN_BODY_SUBTYPE then
                            if removedForgottens < RUN_SAVE.ResouledForgottenSacrificed[tostring(player:GetPlayerIndex())] then
                                removedForgottens = removedForgottens + 1
                                entity:Remove()
                            end
                        end
                    end)
                    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

---@param pickup EntityPickup
---@param collider Entity
local function prePickupCollision(_, pickup, collider)
    if pickup.Variant == PickupVariant.PICKUP_HEART then
        if pickup.SubType == HeartSubType.HEART_BONE then
            if collider.Type == EntityType.ENTITY_PLAYER then
                local RUN_SAVE = SAVE_MANAGER.GetRunSave()
                if RUN_SAVE.ResouledForgottenSacrificed then 
                    if RUN_SAVE.ResouledForgottenSacrificed[tostring(collider:ToPlayer():GetPlayerIndex())] then
                        return false
                    end
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, prePickupCollision)

---@param player EntityPlayer
local function prePlayerUpdate(_, player)
    local RUN_SAVE = SAVE_MANAGER.GetRunSave()
    if RUN_SAVE.ResouledForgottenSacrificed then 
        if RUN_SAVE.ResouledForgottenSacrificed[tostring(player:GetPlayerIndex())] then
            player:AddBoneHearts(-12)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_UPDATE, prePlayerUpdate)