---@enum ResouledSpecialSeedEffects
Resouled.SpecialSeedEffects = {
    SoulsBeGone = "Souls Be Gone",
    NoSoulChallenge = "No Soul Challenge",
    EverythingIsCursed = "Everything is Cursed!"
}

local save = {}

---@param continued boolean
local function postGameStarted(_, continued)
    local RunSave = Resouled.SaveManager.GetRunSave()
    if continued == false then
        RunSave.Shenanigans = {}
        
        for _, shenanigan in pairs(Resouled.SpecialSeedEffects) do
            if Resouled:IsSpecialSeedEffectOptionActive(shenanigan) then
                RunSave.Shenanigans[shenanigan] = true
            end
        end
    end

    save = RunSave.Shenanigans
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)

---@param effect ResouledSpecialSeedEffects
function Resouled:IsSpecialSeedEffectActive(effect)
    return save[effect] and save[effect] == true
end