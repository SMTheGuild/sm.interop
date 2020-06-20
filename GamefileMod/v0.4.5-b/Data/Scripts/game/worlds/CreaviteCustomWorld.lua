CreativeCustomWorld = class( nil )

CreativeCustomWorld.terrainScript = "$GAME_DATA/Scripts/game/terrain/terrain_custom.lua"
CreativeCustomWorld.enableSurface = true
CreativeCustomWorld.enableAssets = true
CreativeCustomWorld.enableClutter = true
CreativeCustomWorld.enableCreations = false
CreativeCustomWorld.enableNodes = false
CreativeCustomWorld.enableCellScripts = false

dofile '$CONTENT_e94ac99f-393e-4816-abe3-353435a1edf4/Scripts/Overrides/worlds/CreativeCustomWorld.lua'
