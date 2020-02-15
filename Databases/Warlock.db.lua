if (AWWarlockDB ~= nil) then
    return;
end

-- https://wow.tools/dbc/?dbc=spellname&build=1.13.3.32836#search=&page=1
AWWarlockDB = {};

AWWarlockDB.SoulShardId = tonumber(6265);
AWWarlockDB.TeleportationSpell = tonumber(698);

AWWarlockDB.BanishSpell = {
    -- Banish
    tonumber(710),
    tonumber(7664),
    tonumber(8994),
    tonumber(18647),
    tonumber(18648),
    tonumber(24466),
    tonumber(27565),
};

AWWarlockDB.BanishDurationSpell = {
    -- Banish Rank 1 -> 20 s
    [710] = 20,

    -- Banish Rank 2 -> 30 s
    [18647] = 30
};

AWWarlockDB.SoulFragmentSpell = {

    --TPSpellId
    tonumber(698),
    
    --Create Healthstone
    tonumber(1049),	
    tonumber(5699),
    tonumber(5700),
    tonumber(5702),
    tonumber(6042),
    tonumber(6201),
    tonumber(6202),
    tonumber(6203),
    tonumber(6204),
    tonumber(11729),
    tonumber(11730),
    tonumber(11731),
    tonumber(20018),
    tonumber(23517),
    tonumber(23518),
    tonumber(23519),
    tonumber(23520),
    tonumber(23521),
    tonumber(23522),
    tonumber(23813),
    tonumber(23814),
    tonumber(23815),
    tonumber(23816),
    tonumber(23817),
    tonumber(23818),
    tonumber(23819),
    tonumber(23820),
    tonumber(23821),
    tonumber(28023),
    
    --Create Soulstone
    tonumber(693),
    tonumber(719),	
    tonumber(1377),
    tonumber(20022),
    tonumber(20752),
    tonumber(20755),
    tonumber(20756),
    tonumber(20757),
    tonumber(20766),
    tonumber(20767),
    tonumber(20768),
    tonumber(20769),

    --Use Soulstone
    tonumber(20758),	
    tonumber(20759),
    tonumber(20760),
    tonumber(20761),

    --Soulstone Resurrection
    tonumber(20707),
    tonumber(20762),
    tonumber(20763),
    tonumber(20764),
    tonumber(20765),
    
    --Shadowburn
    tonumber(17877),
    tonumber(18867),
    tonumber(18868),
    tonumber(18869),
    tonumber(18870),
    tonumber(18871),
    tonumber(18872),
    tonumber(18875),
    tonumber(18876),
    tonumber(18877),
    tonumber(18878),
    
    --Summon Imp
    tonumber(688),
    tonumber(1366),
    tonumber(11939),
    tonumber(23503),
    
    --Summon Voidwalker
    tonumber(697),
    tonumber(1385),
    tonumber(7728),
    tonumber(9221),
    tonumber(9222),
    tonumber(12746),
    tonumber(23501),
    tonumber(25112),
    
    --Summon Succubus
    tonumber(712),
    tonumber(1403),
    tonumber(7729),
    tonumber(8674),
    tonumber(8722),
    tonumber(9223),
    tonumber(9224),
    tonumber(23502),
    
    --Summon Felhunter
    tonumber(691),
    tonumber(8176),
    tonumber(8712),	
    tonumber(8717),
    tonumber(23500),
    
    --Inferno
    tonumber(1122),
    tonumber(1413),	
    tonumber(19695),
    tonumber(19698),	
    tonumber(20799),
    tonumber(22699),	
    tonumber(24670),
};