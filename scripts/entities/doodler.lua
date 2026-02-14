local CONST = {
    Ent = Resouled:GetEntityByName("Resouled Doodler"),
    Anim = {
        Base = {
            Idle = {
                Name = "Idle",
                Len = 1,
            },
            WalkForward = {
                Name = "WalkForward",
                Len = 26,
            },
            WalkRight = {
                Name = "WalkRight",
                Len = 26,
            },
            WalkLeft = {
                Name = "WalkLeft",
                Len = 26,
            },
            RunForward = {
                Name = "RunForward",
                Len = 20,
            },
            RunRight = {
                Name = "RunRight",
                Len = 20,
            },
            RunLeft = {
                Name = "RunLeft",
                Len = 20,
            },
        },
        Overlay = {
            HeadDownOpen = {
                Name = "HeadDownOpen",
                Len = 1,
            },
            HeadDown = {
                Name = "HeadDown",
                Len = 1,
            },
            HeadDownLifted = {
                Name = "HeadDownLifted",
                Len = 1,
            },
        }
    }
}

---@param doodler EntityNPC
local function onDooderInit(_, doodler)
    if not Resouled:MatchesEntityDesc(doodler, CONST.Ent) then return end

    local sprite = doodler:GetSprite()
    sprite:Play(CONST.Anim.Base.WalkForward.Name, true)
    sprite:PlayOverlay(CONST.Anim.Overlay.HeadDown.Name, true)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onDooderInit, CONST.Ent.Type)

---@param doodler EntityNPC
local function onDoodlerUpdate(_, doodler)
    if not Resouled:MatchesEntityDesc(doodler, CONST.Ent) then return end

    local sprite = doodler:GetSprite()
    print(sprite:IsOverlayPlaying())
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onDoodlerUpdate, CONST.Ent.Type)
