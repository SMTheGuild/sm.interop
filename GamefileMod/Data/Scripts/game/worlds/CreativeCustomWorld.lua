dofile( "$GAME_DATA/Scripts/game/managers/CreativePathNodeManager.lua")
dofile( "$GAME_DATA/Scripts/game/worlds/CreativeBaseWorld.lua")
dofile( "$SURVIVAL_DATA/Scripts/game/managers/WaterManager.lua" )

CreativeCustomWorld = class( CreativeBaseWorld )

CreativeCustomWorld.terrainScript = "$GAME_DATA/Scripts/terrain/terrain_custom.lua"
CreativeCustomWorld.enableSurface = true
CreativeCustomWorld.enableAssets = true
CreativeCustomWorld.enableClutter = true
CreativeCustomWorld.enableNodes = true
CreativeCustomWorld.enableCreations = true
CreativeCustomWorld.enableHarvestables = true
CreativeCustomWorld.enableKinematics = false
CreativeCustomWorld.cellMinX = -11
CreativeCustomWorld.cellMaxX = 10
CreativeCustomWorld.cellMinY = -11
CreativeCustomWorld.cellMaxY = 10

function CreativeCustomWorld.server_onCreate( self )
	CreativeBaseWorld.server_onCreate( self )

	self.waterManager = WaterManager()
	self.waterManager:sv_onCreate( self )

	self.sv = {}
	self.sv.pathNodeManager = CreativePathNodeManager()
	self.sv.pathNodeManager:sv_onCreate( self )
end

function CreativeCustomWorld.client_onCreate( self )
	CreativeBaseWorld.client_onCreate( self )

	if self.waterManager == nil then
		assert( not sm.isHost )
		self.waterManager = WaterManager()
	end
	self.waterManager:cl_onCreate()
end

function CreativeCustomWorld.server_onFixedUpdate( self )
	CreativeBaseWorld.server_onFixedUpdate( self )
	self.waterManager:sv_onFixedUpdate()
end

function CreativeCustomWorld.client_onFixedUpdate( self )
	self.waterManager:cl_onFixedUpdate()
end

function CreativeCustomWorld.client_onUpdate( self )
	g_effectManager:cl_onWorldUpdate( self )
end

function CreativeCustomWorld.server_onCellCreated( self, x, y )
	self.waterManager:sv_onCellLoaded( x, y )
	self.sv.pathNodeManager:sv_loadPathNodesOnCell( x, y )
end

function CreativeCustomWorld.client_onCellLoaded( self, x, y )
	self.waterManager:cl_onCellLoaded( x, y )
	g_effectManager:cl_onWorldCellLoaded( self, x, y )
end

function CreativeCustomWorld.server_onCellLoaded( self, x, y )
	self.waterManager:sv_onCellReloaded( x, y )
end

function CreativeCustomWorld.server_onCellUnloaded( self, x, y )
	self.waterManager:sv_onCellUnloaded( x, y )
end

function CreativeCustomWorld.client_onCellUnloaded( self, x, y )
	self.waterManager:cl_onCellUnloaded( x, y )
	g_effectManager:cl_onWorldCellUnloaded( self, x, y )
end

dofile '$CONTENT_e94ac99f-393e-4816-abe3-353435a1edf4/Scripts/Overrides/worlds/CreativeCustomWorld.lua'
