local mushroomChapters = {
    [2] = true
}

local mushroomItems = WeightedOutcomePicker()
Resouled:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function()
    local itemConfig = Resouled.ItemConf
    for i = 1, #itemConfig:GetCollectibles() - 1 do
        local item = itemConfig:GetCollectible(i)
        if item and item:HasTags(ItemConfig.TAG_MUSHROOM) then
            mushroomItems:AddOutcomeFloat(i, 1)
        end
    end
end)

---@param en GridEntityRock
---@param type GridEntityType
local function postGridRockDestroy(_, en, type)
    if type ~= GridEntityType.GRID_ROCK_ALT or not mushroomChapters[Resouled.AccurateStats:GetCurrentChapter()] then return end

    local rng = RNG(en.Desc.SpawnSeed)

    local itemId = mushroomItems:PickOutcome(rng)
    if itemId then
        Resouled.Game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, en.Position, Vector.Zero, nil, itemId, Random())
        Resouled:RemoveActiveBuff(Resouled.Buffs.MEDIUM_CAP)
    end
end

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.MEDIUM_CAP, true)

Resouled:AddBuffCallbackConfig(Resouled.Buffs.MEDIUM_CAP, {
    {
        CallbackID = ModCallbacks.MC_POST_GRID_ROCK_DESTROY,
        Function = postGridRockDestroy
    }
})