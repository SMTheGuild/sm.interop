dofile( "$GAME_DATA/Scripts/game/worlds/CreativeBaseWorld.lua")

CreativeFlatWorld = class( CreativeBaseWorld )

CreativeFlatWorld.terrainScript = "$GAME_DATA/Scripts/terrain/terrain_flat.lua"
CreativeFlatWorld.enableSurface = true
CreativeFlatWorld.enableAssets = true
CreativeFlatWorld.enableClutter = true
CreativeFlatWorld.enableNodes = false
CreativeFlatWorld.enableCreations = false
CreativeFlatWorld.enableHarvestables = false
CreativeFlatWorld.enableKinematics = false
CreativeFlatWorld.groundMaterialSet = "$GAME_DATA/Terrain/Materials/gnd_flat_materialset.json"
CreativeFlatWorld.cellMinX = -16
CreativeFlatWorld.cellMaxX = 15
CreativeFlatWorld.cellMinY = -16
CreativeFlatWorld.cellMaxY = 15
dofile '$CONTENT_e94ac99f-393e-4816-abe3-353435a1edf4/Scripts/Overrides/worlds/CreativeFlatWorld.lua'
