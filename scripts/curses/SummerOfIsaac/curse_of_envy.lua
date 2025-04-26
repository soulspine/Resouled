local SPLIT_CHANCE = 0.05
local SPRITE_SCALE_DIVIDER = 2
local HITBOX_SIZE_DIVIDER = 2
local HEALTH_DIVIDER = 3

local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_ENVY]

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_ENVY)
    end,
    Resouled.CursesSprite,
    mapId,
    1
)
--[[
---@param npc EntityNPC
local function postNpcDeath(_, npc)
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_ENVY) then
        local randomNum = math.random()
        if randomNum < SPLIT_CHANCE and npc:IsActiveEnemy(true) and npc:IsEnemy() and not npc:GetData().ResouledIsSplitEnemy then
            local type = npc.Type
            local variant = npc.Variant
            local subtype = npc.SubType
            
            local splitEnemy1 = Game():Spawn(type, variant, npc.Position, Vector.Zero, npc, subtype, npc.InitSeed)
            local splitEnemy2 = Game():Spawn(type, variant, npc.Position, Vector.Zero, npc, subtype, npc.InitSeed)
            
            splitEnemy1:GetData().ResouledIsSplitEnemy = true
            splitEnemy2:GetData().ResouledIsSplitEnemy = true
            
            splitEnemy1:ToNPC().Size = npc.Size / HITBOX_SIZE_DIVIDER
            splitEnemy2:ToNPC().Size = npc.Size / HITBOX_SIZE_DIVIDER
            
            splitEnemy1:ToNPC().HitPoints = math.floor(npc.HitPoints / HEALTH_DIVIDER)
            splitEnemy2:ToNPC().HitPoints = math.floor(npc.HitPoints / HEALTH_DIVIDER)
            
            if npc:IsChampion() then
                local championColor = npc:GetChampionColorIdx()
                
                splitEnemy1:ToNPC():MakeChampion(npc.InitSeed, championColor, false)
                splitEnemy2:ToNPC():MakeChampion(npc.InitSeed, championColor, false)
            end

            splitEnemy1:ToNPC().SpriteScale = npc.SpriteScale / SPRITE_SCALE_DIVIDER
            splitEnemy2:ToNPC().SpriteScale = npc.SpriteScale / SPRITE_SCALE_DIVIDER
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath)
]]

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_ENVY) then
        if npc.HitPoints <= 0 then
            
            local randomNum = math.random()

            if randomNum < SPLIT_CHANCE and npc:IsActiveEnemy(true) and npc:IsEnemy() and not npc:GetData().ResouledIsSplitEnemy then
                local type = npc.Type
                local variant = npc.Variant
                local subtype = npc.SubType

                if type == 281 and variant == 0 and subtype == 0 then --swarm flies (can multiply infinitely)
                    return
                end
                
                local splitEnemy1 = Game():Spawn(type, variant, npc.Position, Vector.Zero, npc, subtype, npc.InitSeed)
                local splitEnemy2 = Game():Spawn(type, variant, npc.Position, Vector.Zero, npc, subtype, npc.InitSeed)
                
                splitEnemy1:GetData().ResouledIsSplitEnemy = true
                splitEnemy2:GetData().ResouledIsSplitEnemy = true
                
                splitEnemy1:ToNPC().Size = npc.Size / HITBOX_SIZE_DIVIDER
                splitEnemy2:ToNPC().Size = npc.Size / HITBOX_SIZE_DIVIDER
                
                splitEnemy1:ToNPC().HitPoints = math.floor(splitEnemy1.HitPoints / HEALTH_DIVIDER)
                splitEnemy2:ToNPC().HitPoints = math.floor(splitEnemy2.HitPoints / HEALTH_DIVIDER)
                
                if npc:IsChampion() then
                    local championColor = npc:GetChampionColorIdx()
                    
                    splitEnemy1:ToNPC():MakeChampion(npc.InitSeed, championColor, false)
                    splitEnemy2:ToNPC():MakeChampion(npc.InitSeed, championColor, false)
                    
                end
            end
        end
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_NPC_UPDATE, CallbackPriority.IMPORTANT, npcUpdate)