local CURSED_FATTY_VARIANT = Isaac.GetEntityVariantByName("Cursed Fatty")
local CURSED_FATTY_TYPE = Isaac.GetEntityTypeByName("Cursed Fatty")
local removedEffect = false

local HALO_SUBTYPE = 3

local HALO_OFFSET = Vector(0, -15)
local HALO_SCALE = Vector(1.5, 1.5)

---@param npc EntityNPC
local function onNPCDeath(_, npc)
    if npc.Variant == CURSED_FATTY_VARIANT then
        local DEATH_PROJECTILE_PARAMS = ProjectileParams()
        DEATH_PROJECTILE_PARAMS.BulletFlags = (ProjectileFlags.SMART | ProjectileFlags.ACCELERATE | ProjectileFlags.SINE_VELOCITY)
        DEATH_PROJECTILE_PARAMS.Spread = 1.5
        DEATH_PROJECTILE_PARAMS.Acceleration = 1.05
        DEATH_PROJECTILE_PARAMS.HomingStrength = 0
        npc:FireProjectiles(npc.Position, Vector(2, 0), 4, DEATH_PROJECTILE_PARAMS)
        npc:FireProjectiles(npc.Position, Vector(0, 2), 4, DEATH_PROJECTILE_PARAMS)
        npc:FireProjectiles(npc.Position, Vector(-2, 0), 4, DEATH_PROJECTILE_PARAMS)
        npc:FireProjectiles(npc.Position, Vector(0, -2), 4, DEATH_PROJECTILE_PARAMS)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNPCDeath, CURSED_FATTY_TYPE)
    
---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == CURSED_FATTY_VARIANT then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        local entity = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, npc.Position, Vector(0, 0), npc, HALO_SUBTYPE, 0)
        local halo = entity:ToEffect()
        halo.Parent = npc
        halo.SpriteScale = HALO_SCALE
        halo.ParentOffset = HALO_OFFSET
        npc:GetData().Halo = halo
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_FATTY_TYPE)

---@param npc EntityNPC
local function preNpcUpdate(_, npc)
    if npc.Variant == CURSED_FATTY_VARIANT then
        ---@type EntityEffect
        local halo = npc:GetData().Halo
        if halo then
            local player = Isaac.GetPlayer()
            local itemConfig = Isaac.GetItemConfig()
            --halo.Position = npc.Position + HALO_OFFSET
            halo.Position = npc.Position + HALO_OFFSET
            if halo.Position:Distance(player.Position) < 110 and removedEffect == false then
                local items = {}
                for i = 1, #itemConfig:GetCollectibles() do
                    if player:HasCollectible(i) then
                        table.insert(items, i)
                    end
                end
                if #items > 0 then 
                    local randomItem = math.random(#items)
                    if items[randomItem] ~= player:GetActiveItem(ActiveSlot.SLOT_POCKET) then
                        player:RemoveCollectible(items[randomItem])
                        Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 10), Vector.Zero, nil, items[randomItem], Game():GetRoom():GetSpawnSeed())
                    end
                end
                    
                removedEffect = true
            elseif halo.Position:Distance(player.Position) > 110 then
                removedEffect = false
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, preNpcUpdate, CURSED_FATTY_TYPE)