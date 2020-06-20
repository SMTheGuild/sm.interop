CreativeTerrainWorld = class( nil )

CreativeTerrainWorld.terrainScript = "$GAME_DATA/Scripts/game/terrain/terrain_creative.lua"
CreativeTerrainWorld.enableSurface = true
CreativeTerrainWorld.enableAssets = true
CreativeTerrainWorld.enableClutter = true
CreativeTerrainWorld.enableCreations = false
CreativeTerrainWorld.enableNodes = false
CreativeTerrainWorld.enableCellScripts = false

dofile '$CONTENT_e94ac99f-393e-4816-abe3-353435a1edf4/Scripts/Overrides/worlds/CreativeTerrainWorld.lua'
