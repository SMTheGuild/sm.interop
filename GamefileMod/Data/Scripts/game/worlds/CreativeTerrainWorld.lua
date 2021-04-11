dofile( "$GAME_DATA/Scripts/game/worlds/CreativeBaseWorld.lua")
dofile( "$SURVIVAL_DATA/Scripts/game/managers/WaterManager.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/managers/EffectManager.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/managers/UnitManager.lua" )
dofile( "$GAME_DATA/Scripts/game/managers/CreativePathNodeManager.lua")

CreativeTerrainWorld = class( CreativeBaseWorld )

CreativeTerrainWorld.terrainScript = "$GAME_DATA/Scripts/game/terrain/terrain_creative.lua"
CreativeTerrainWorld.enableSurface = true
CreativeTerrainWorld.enableAssets = true
CreativeTerrainWorld.enableClutter = true
CreativeTerrainWorld.enableCreations = false
CreativeTerrainWorld.enableNodes = true
CreativeTerrainWorld.enableHarvestables = true


function CreativeTerrainWorld.server_onCreate( self )
	CreativeBaseWorld.server_onCreate( self )

	self.waterManager = WaterManager()
	self.waterManager:sv_onCreate( self )

	self.pathNodeManager = CreativePathNodeManager()
	self.pathNodeManager:sv_onCreate( self )
end

function CreativeTerrainWorld.client_onCreate( self )
	CreativeBaseWorld.client_onCreate( self )

	if self.waterManager == nil then
		assert( not sm.isHost )
		self.waterManager = WaterManager()
	end
	self.waterManager:cl_onCreate()

	self.cl_effectManager = ClientEffectManager()
    self.cl_effectManager:onCreate()
end

function CreativeTerrainWorld.server_onFixedUpdate( self )
	CreativeBaseWorld.server_onFixedUpdate( self )
    self.waterManager:sv_onFixedUpdate()
end

function CreativeTerrainWorld.client_onFixedUpdate( self )
	self.waterManager:cl_onFixedUpdate()
	self.cl_effectManager:onFixedUpdate()
end

function CreativeTerrainWorld.server_onCellLoaded( self, x, y )
    self.waterManager:sv_onCellLoaded( x, y )
	self.pathNodeManager:sv_loadPathNodesOnCell( x, y )
end

function CreativeTerrainWorld.client_onCellLoaded( self, x, y )
	self.waterManager:cl_onCellLoaded( x, y )
	self.cl_effectManager:onCellLoaded( x, y )
end

function CreativeTerrainWorld.server_onCellReloaded( self, x, y )
	self.waterManager:sv_onCellReloaded( x, y )
end

function CreativeTerrainWorld.server_onCellUnloaded( self, x, y )
	self.waterManager:sv_onCellUnloaded( x, y )
end

function CreativeTerrainWorld.client_onCellUnloaded( self, x, y )
	self.waterManager:cl_onCellUnloaded( x, y )
	self.cl_effectManager:onCellUnloaded( x, y )
end

dofile '$CONTENT_e94ac99f-393e-4816-abe3-353435a1edf4/Scripts/Overrides/worlds/CreativeTerrainWorld.lua'
