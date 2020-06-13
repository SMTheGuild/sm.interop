
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

function CreativePlayer.client_onInteract( self, character, state )
    self:emitEvent(true, 'playerInteract', {
        player = self.player,
        character = character,
        state = state
    })
end

function CreativePlayer.server_onFixedUpdate( self, dt ) end

function CreativePlayer.server_onProjectile( self, hitPos, hitTime, hitVelocity, projectileName, attacker, damage )
    self:emitEvent(false, 'playerHitByProjectile', {
        player = self.player,
        hitPos = hitPos,
        hitTime = hitTime,
        hitVelocity = hitVelocity,
        projectileName = projectileName,
        attacker = attacker,
        damage = damage
    })
end

function CreativePlayer.server_onMelee( self, hitPos, attacker, damage, power )
    self:emitEvent(false, 'playerHitByMelee', {
        player = self.player,
        hitPos = hitPos,
        attacker = attacker,
        damage = damge,
        power = power
    })
end

function CreativePlayer.server_onExplosion( self, center, destructionLevel )
    self:emitEvent(false, 'playerHitByExplosion', {
        player = self.player,
        center = center,
        destructionLevel = destructionLevel
    })
end

function CreativePlayer.server_onCollision( self, other, collisionPosition, selfPointVelocity, otherPointVelocity, collisionNormal  )
    self:emitEvent(false, 'playerCollision', {
        player = self.player,
        other = other,
        collisionPosition = collisionPosition,
        selfPointVelocity = selfPointVelocity,
        otherPointVelocity = otherPointVelocity,
        collisionNormal = collisionNormal
    })
end

function CreativePlayer.sv_e_staminaSpend( self, stamina ) end

function CreativePlayer.sv_e_receiveDamage( self, damageData ) end

function CreativePlayer.sv_e_respawn( self ) end

function CreativePlayer.sv_e_debug( self, params ) end

function CreativePlayer.sv_e_eat( self, edibleParams ) end

function CreativePlayer.sv_e_feed( self, params ) end

function CreativePlayer.sv_e_setRefiningState( self, params ) end

function CreativePlayer.sv_e_onLoot( self, params ) end

function CreativePlayer.sv_e_onStayPesticide( self ) end

function CreativePlayer.sv_e_onEnterFire( self ) end

function CreativePlayer.sv_e_onStayFire( self ) end

function CreativePlayer.sv_e_onEnterChemical( self ) end

function CreativePlayer.sv_e_onStayChemical( self ) end

function CreativePlayer.sv_e_startLocalCutscene( self, cutsceneInfoName ) end

function CreativePlayer.client_onCancel( self )
    self:emitEvent(true, 'playerCancel', { self.player })
end

function CreativePlayer.client_onReload( self )
    self:emitEvent(true, 'playerReload', { player = self.player })
end

function CreativePlayer.server_onShapeRemoved( self, removedShapes )
    self:emitEvent(false, 'shapeRemoved', { player = self.player, removedShapes = removedShapes })
end

function CreativePlayer.emitEvent(self, client, name, data)
    if sm.interop then
        sm.interop.events.emit('scrapmechanic:'..name, data)
        if client then
            self.network:sendToServer('svcl_emitEvent', {
                event = name,
                data = data
            })
        else
            self.network:sendToClients('svcl_emitEvent', {
                event = name,
                data = data
            })
        end
    end
end

function CreativePlayer.svcl_emitEvent( self, params )
    sm.interop.events.emit('scrapmechanic:' .. params.event, params.data )
end
