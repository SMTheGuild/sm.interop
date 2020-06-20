sm.interopGamefileModVersion = 2

CreativeGame = class( nil )
CreativeGame.enableLimitedInventory = false
CreativeGame.enableRestrictions = false

g_godMode = true

function CreativeGame.client_onCreate( self )
	sm.game.setTimeOfDay( 0.5 )
	sm.render.setOutdoorLighting( 0.5 )
end

function CreativeGame.cl_onChatCommand( self, params )
end

dofile '$CONTENT_e94ac99f-393e-4816-abe3-353435a1edf4/Scripts/Overrides/CreativeGame.lua'
