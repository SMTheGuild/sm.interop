dofile( "$GAME_DATA/Scripts/game/managers/CreativePathNodeManager.lua")
dofile( "$GAME_DATA/Scripts/game/worlds/CreativeBaseWorld.lua")
dofile( "$SURVIVAL_DATA/Scripts/game/managers/WaterManager.lua" )

CreativeTerrainWorld = class( CreativeBaseWorld )

CreativeTerrainWorld.terrainScript = "$GAME_DATA/Scripts/terrain/terrain_creative.lua"
CreativeTerrainWorld.enableSurface = true
CreativeTerrainWorld.enableAssets = true
CreativeTerrainWorld.enableClutter = true
CreativeTerrainWorld.enableNodes = true
CreativeTerrainWorld.enableCreations = false
CreativeTerrainWorld.enableHarvestables = true
CreativeTerrainWorld.enableKinematics = false
CreativeTerrainWorld.cellMinX = -15
CreativeTerrainWorld.cellMaxX = 14
CreativeTerrainWorld.cellMinY = -15
CreativeTerrainWorld.cellMaxY = 14

function CreativeTerrainWorld.server_onCreate( self )
	CreativeBaseWorld.server_onCreate( self )

	self.waterManager = WaterManager()
	self.waterManager:sv_onCreate( self )

	self.sv = {}
	self.sv.pathNodeManager = CreativePathNodeManager()
	self.sv.pathNodeManager:sv_onCreate( self )
end

function CreativeTerrainWorld.client_onCreate( self )
	CreativeBaseWorld.client_onCreate( self )

	if self.waterManager == nil then
		assert( not sm.isHost )
		self.waterManager = WaterManager()
	end
	self.waterManager:cl_onCreate()
end

function CreativeTerrainWorld.server_onFixedUpdate( self )
	CreativeBaseWorld.server_onFixedUpdate( self )
	self.waterManager:sv_onFixedUpdate()
end

function CreativeTerrainWorld.client_onFixedUpdate( self )
	self.waterManager:cl_onFixedUpdate()
end

function CreativeTerrainWorld.client_onUpdate( self )
	g_effectManager:cl_onWorldUpdate( self )
end

function CreativeTerrainWorld.server_onCellCreated( self, x, y )
	self.waterManager:sv_onCellLoaded( x, y )
	self.sv.pathNodeManager:sv_loadPathNodesOnCell( x, y )
end

function CreativeTerrainWorld.client_onCellLoaded( self, x, y )
	self.waterManager:cl_onCellLoaded( x, y )
	g_effectManager:cl_onWorldCellLoaded( self, x, y )
end

function CreativeTerrainWorld.server_onCellLoaded( self, x, y )
	self.waterManager:sv_onCellReloaded( x, y )
end

function CreativeTerrainWorld.server_onCellUnloaded( self, x, y )
	self.waterManager:sv_onCellUnloaded( x, y )
end

function CreativeTerrainWorld.client_onCellUnloaded( self, x, y )
	self.waterManager:cl_onCellUnloaded( x, y )
	g_effectManager:cl_onWorldCellUnloaded( self, x, y )
end
dofile '$CONTENT_e94ac99f-393e-4816-abe3-353435a1edf4/Scripts/Overrides/worlds/CreativeTerrainWorld.lua'
