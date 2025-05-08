---@param npc EntityNPC
local function onNpcDeath(_, npc)
    if npc.Type == EntityType.ENTITY_MONSTRO and not npc:HasEntityFlags(EntityFlag.FLAG_CHARM) then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.MONSTRO, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_DUKE then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.DUKE, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_LITTLE_HORN then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.LITTLE_HORN, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_PEEP and npc.Variant == 1 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.BLOAT, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_WRATH then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.WRATH, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_WIDOW then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.WIDOW, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_THE_HAUNT and npc.Variant == Isaac.GetEntityVariantByName("Cursed Haunt") then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.CURSED_HAUNT, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_CHUB and npc.Variant == 2 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.CARRIOR_QUEEN, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_CHUB and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.CHUB, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_WAR and npc.Variant == 1 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.CONQUEST, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_DADDYLONGLEGS and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.DADDY_LONG_LEGS, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_DARK_ONE then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.DARK_ONE, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_DEATH and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.DEATH, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_ENVY then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.ENVY, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_FAMINE then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.FAMINE, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_GEMINI and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.GEMINI, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_GLUTTONY then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.GLUTTONY, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_GREED then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.GREED, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_GURDY then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.GURDY, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_GURDY_JR then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.GURDY_JR, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_LARRYJR and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.LARRY_JR, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_LUST then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.LUST, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_MASK_OF_INFAMY then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.MASK_OF_INFAMY, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_MEGA_FATTY then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.MEGA_FATTY, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_PEEP and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.PEEP, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_PESTILENCE then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.PESTILENCE, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_PIN and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.PIN, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_PRIDE then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.PRIDE, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_RAG_MAN and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.RAG_MAN, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_PIN and npc.Variant == 1 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.SCOLEX, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_SLOTH then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.SLOTH, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_THE_HAUNT and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.HAUNT, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_THE_LAMB then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.THE_LAMB, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_WAR and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.WAR, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_MOM and npc.Variant == 0 and not npc:HasEntityFlags(EntityFlag.FLAG_CHARM) then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.MOM, Isaac.GetFreeNearPosition(Game():GetRoom():GetCenterPos(), 0))
    end

    if npc.Type == EntityType.ENTITY_SATAN and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.SATAN, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_HEADLESS_HORSEMAN then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.HEADLESS_HORSEMAN, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_BLASTOCYST_BIG then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.BLASTOCYST, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_DINGLE then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.DINGLE, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_FALLEN and npc.Variant == 1 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.KRAMPUS, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_MONSTRO2 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.MONSTRO_II, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_FALLEN and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.THE_FALLEN, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_ISAAC and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.ISAAC, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_MOMS_HEART and npc.Variant == 0 and not npc:HasEntityFlags(EntityFlag.FLAG_CHARM) then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.MOMS_HEART, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_BABY_PLUM then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.BLOAT, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_BROWNIE then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.BROWNIE, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_MONSTRO and npc:HasEntityFlags(EntityFlag.FLAG_CHARM) then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.CHARMED_MONSTRO, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_CLOG then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.CLOG, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_HORNFEL and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.HORNFEL, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_MAMA_GURDY and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.MAMA_GURDY, Isaac.GetFreeNearPosition(Game():GetRoom():GetCenterPos(), 0))
    end

    if npc.Type == EntityType.ENTITY_RAG_MEGA and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.RAG_MEGA, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_SISTERS_VIS then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.SISTERS_VIS, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_RAINMAKER then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.THE_RAINMAKER, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_SCOURGE and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.THE_SCOURGE, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_SIREN and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.THE_SIREN, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_GURGLING and npc.Variant == 2 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.TURDLINGS, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_ULTRA_GREED and npc.Variant == 0 or npc.Variant == 1 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.ULTRA_GREED, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_MEGA_SATAN_2 and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.MEGA_SATAN, Isaac.GetFreeNearPosition(Game():GetRoom():GetCenterPos(), 0))
    end

    if npc.Type == EntityType.ENTITY_MOTHER and npc.Variant == 10 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.MOTHER, Isaac.GetFreeNearPosition(Game():GetRoom():GetCenterPos(), 0))
    end

    if npc.Type == EntityType.ENTITY_ROTGUT and npc.Variant == 1 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.GUS, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_HUSH then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.HUSH, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_FISTULA_BIG and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.FISTULA, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_GURGLING and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.GURGLINGS, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_POLYCEPHALUS and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.POLYCEPHALUS, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_GEMINI and npc.Variant == 1 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.STEVEN, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_CAGE then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.THE_CAGE, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_BIG_HORN and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.BIG_HORN, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_LOKI and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.LOKI, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_ADVERSARY then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.THE_ADVERSARY, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_FISTULA_BIG and npc.Variant == 1 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.TERATOMA, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_MOMS_HEART and npc.Variant == 1 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.IT_LIVES, npc.Position)
    end

    if npc.Type == EntityType.ENTITY_MOM and npc.Variant == 0 and npc:HasEntityFlags(EntityFlag.FLAG_CHARM) then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.MOM, Isaac.GetFreeNearPosition(Game():GetRoom():GetCenterPos(), 0))
    end

    if npc.Type == EntityType.ENTITY_BEAST and npc.Variant == 0 then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.THE_BEAST, npc.Position)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNpcDeath)