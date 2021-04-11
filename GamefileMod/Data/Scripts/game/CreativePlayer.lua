
CreativePlayer = class( nil )

function CreativePlayer.server_onCreate( self )
	self.sv = {}
	self:sv_init()
end

function CreativePlayer.server_onRefresh( self )
	self:sv_init()
end

function CreativePlayer.sv_init( self ) end

function CreativePlayer.server_onDestroy( self ) end

function CreativePlayer.client_onCreate( self )
	self.cl = {}
	self:cl_init()
end

function CreativePlayer.client_onRefresh( self )
	self:cl_init()
end

function CreativePlayer.cl_init(self) end

function CreativePlayer.client_onUpdate( self, dt ) end

function CreativePlayer.client_onInteract( self, character, state ) end

function CreativePlayer.server_onFixedUpdate( self, dt ) end

function CreativePlayer.server_onProjectile( self, hitPos, hitTime, hitVelocity, projectileName, attacker, damage ) end

function CreativePlayer.server_onMelee( self, hitPos, attacker, damage, power )
	if not sm.exists( attacker ) then
		return
	end

	if self.player.character and attacker.character then
		local attackDirection = ( hitPos - attacker.character.worldPosition ):normalize()
		-- Melee impulse
		if attacker then
			ApplyKnockback( self.player.character, attackDirection, power )
		end
	end
end

function CreativePlayer.server_onExplosion( self, center, destructionLevel ) end

function CreativePlayer.server_onCollision( self, other, collisionPosition, selfPointVelocity, otherPointVelocity, collisionNormal  ) end

function CreativePlayer.sv_e_staminaSpend( self, stamina ) end

function CreativePlayer.sv_e_receiveDamage( self, damageData ) end

function CreativePlayer.sv_e_respawn( self ) end

function CreativePlayer.sv_e_debug( self, params ) end

function CreativePlayer.sv_e_eat( self, edibleParams ) end

function CreativePlayer.sv_e_feed( self, params ) end

function CreativePlayer.sv_e_setRefiningState( self, params )
	local userPlayer = params.user:getPlayer()
	if userPlayer then
		if params.state == true then
			userPlayer:sendCharacterEvent( "refine" )
		else
			userPlayer:sendCharacterEvent( "refineEnd" )
		end
	end
end

function CreativePlayer.sv_e_onLoot( self, params ) end

function CreativePlayer.sv_e_onStayPesticide( self ) end

function CreativePlayer.sv_e_onEnterFire( self ) end

function CreativePlayer.sv_e_onStayFire( self ) end

function CreativePlayer.sv_e_onEnterChemical( self ) end

function CreativePlayer.sv_e_onStayChemical( self ) end

function CreativePlayer.sv_e_startLocalCutscene( self, cutsceneInfoName ) end

function CreativePlayer.client_onCancel( self ) end

function CreativePlayer.client_onReload( self ) end

function CreativePlayer.server_onShapeRemoved( self, removedShapes ) end
dofile '$CONTENT_e94ac99f-393e-4816-abe3-353435a1edf4/Scripts/Overrides/CreativePlayer.lua'
