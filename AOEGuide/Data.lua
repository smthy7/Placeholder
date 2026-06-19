local addonName, addonTable = ...

addonTable.AOEData = {
    -- Format: [mapID] = { {minLevel, maxLevel, points = {{x, y}, ...}, description, arrows = {{from, to}, ...} } }
    -- Map IDs: Westfall = 1436 (Retail/Classic), but for Era/SoD/TBC they differ.
    -- I'll use common names and attempt to map them or use the C_Map.GetBestMapForUnit("player")

    -- Eastern Kingdoms
    [1436] = { -- Westfall
        {
            minLevel = 12,
            maxLevel = 18,
            name = "Westfall Shore Crabs",
            points = {
                {x = 30.5, y = 40.2}, -- Start
                {x = 28.1, y = 55.4}, -- Mid
                {x = 32.4, y = 70.1}  -- End
            },
            arrows = { {1, 2}, {2, 3} },
            description = "Kill Shore Crawlers along the coast. High density, low damage."
        }
    },
    [1424] = { -- Hillsbrad Foothills
        {
            minLevel = 30,
            maxLevel = 36,
            name = "Hillsbrad Fields Humans",
            points = {
                {x = 33.4, y = 42.1},
                {x = 35.2, y = 45.6},
                {x = 32.1, y = 48.2}
            },
            arrows = { {1, 2}, {2, 3}, {3, 1} },
            description = "Farm the fields for Humanoid mobs. Good gold and wool cloth."
        }
    },
    [1413] = { -- Arathi Highlands
        {
            minLevel = 36,
            maxLevel = 42,
            name = "Go'Shek Farm",
            points = {
                {x = 60.1, y = 62.2},
                {x = 62.5, y = 58.4},
                {x = 58.2, y = 56.1}
            },
            arrows = { {1, 2}, {2, 3}, {3, 1} },
            description = "Dense humanoids. Careful with casters."
        }
    },
    -- TBC Spots (Example: Zangarmarsh)
    [1946] = { -- Zangarmarsh
        {
            minLevel = 60,
            maxLevel = 64,
            name = "Ango'rosh Grounds",
            points = {
                {x = 18.5, y = 12.4},
                {x = 20.1, y = 15.2}
            },
            arrows = { {1, 2} },
            description = "Ogres. High HP but good drops."
        }
    }
}
