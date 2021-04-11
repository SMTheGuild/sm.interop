dofile( "$GAME_DATA/Scripts/game/worlds/CreativeBaseWorld.lua")
dofile( "$SURVIVAL_DATA/Scripts/game/managers/WaterManager.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/managers/EffectManager.lua" )
dofile( "$GAME_DATA/Scripts/game/managers/CreativePathNodeManager.lua")

CreativeCustomWorld = class( CreativeBaseWorld )

CreativeCustomWorld.terrainScript = "$GAME_DATA/Scripts/game/terrain/terrain_custom.lua"
CreativeCustomWorld.enableSurface = true
CreativeCustomWorld.enableAssets = true
CreativeCustomWorld.enableClutter = true
CreativeCustomWorld.enableCreations = false
CreativeCustomWorld.enableNodes = true
CreativeCustomWorld.enableHarvestables = true

function CreativeCustomWorld.server_onCreate( self )
	CreativeBaseWorld.server_onCreate( self )

	self.waterManager = WaterManager()
	self.waterManager:sv_onCreate( self )

	self.pathNodeManager = CreativePathNodeManager()
	self.pathNodeManager:sv_onCreate( self )
end

function CreativeCustomWorld.client_onCreate( self )
	CreativeBaseWorld.client_onCreate( self )

	if self.waterManager == nil then
		assert( not sm.isHost )
		self.waterManager = WaterManager()
	end
	self.waterManager:cl_onCreate()

	self.cl_effectManager = ClientEffectManager()
    self.cl_effectManager:onCreate()
end

function CreativeCustomWorld.server_onFixedUpdate( self )
	CreativeBaseWorld.server_onFixedUpdate( self )
    self.waterManager:sv_onFixedUpdate()
end

function CreativeCustomWorld.client_onFixedUpdate( self )
	self.waterManager:cl_onFixedUpdate()
	self.cl_effectManager:onFixedUpdate()
end

function CreativeCustomWorld.server_onCellLoaded( self, x, y )
    self.waterManager:sv_onCellLoaded( x, y )
	self.pathNodeManager:sv_loadPathNodesOnCell( x, y )
end

function CreativeCustomWorld.client_onCellLoaded( self, x, y )
	self.waterManager:cl_onCellLoaded( x, y )
	self.cl_effectManager:onCellLoaded( x, y )
end

function CreativeCustomWorld.server_onCellReloaded( self, x, y )
	self.waterManager:sv_onCellReloaded( x, y )
end

function CreativeCustomWorld.server_onCellUnloaded( self, x, y )
	self.waterManager:sv_onCellUnloaded( x, y )
end

function CreativeCustomWorld.client_onCellUnloaded( self, x, y )
	self.waterManager:cl_onCellUnloaded( x, y )
	self.cl_effectManager:onCellUnloaded( x, y )
end

dofile '$CONTENT_e94ac99f-393e-4816-abe3-353435a1edf4/Scripts/Overrides/worlds/CreativeCustomWorld.lua'
