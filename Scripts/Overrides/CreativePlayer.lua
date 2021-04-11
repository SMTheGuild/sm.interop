dofile '$CONTENT_e94ac99f-393e-4816-abe3-353435a1edf4/Scripts/Overrides/attach.lua'

attachFunctionToObject(CreativePlayer, 'emitEvent', function(self, client, name, data)
    if sm.interop then
        sm.interop.events.emit('scrapmechanic:'..name, data, 'both', true)
    end
end)

attachFunctionToObject(CreativePlayer, 'client_onInteract', function( self, character, state )
    self:emitEvent(true, 'playerInteract', {
        player = self.player,
        character = character,
        state = state
    })
end)

attachFunctionToObject(CreativePlayer, 'server_onProjectile', function( self, hitPos, hitTime, hitVelocity, projectileName, attacker, damage )
    self:emitEvent(false, 'playerHitByProjectile', {
        player = self.player,
        hitPos = hitPos,
        hitTime = hitTime,
        hitVelocity = hitVelocity,
        projectileName = projectileName,
        attacker = attacker,
        damage = damage
    })
end)

attachFunctionToObject(CreativePlayer, 'server_onMelee', function( self, hitPos, attacker, damage, power )
    self:emitEvent(false, 'playerHitByMelee', {
        player = self.player,
        hitPos = hitPos,
        attacker = attacker,
        damage = damge,
        power = power
    })
end)

attachFunctionToObject(CreativePlayer, 'server_onExplosion', function( self, center, destructionLevel )
    self:emitEvent(false, 'playerHitByExplosion', {
        player = self.player,
        center = center,
        destructionLevel = destructionLevel
    })
end)

attachFunctionToObject(CreativePlayer, 'client_onCancel', function( self )
    self:emitEvent(true, 'playerCancel', { player = self.player })
end)

attachFunctionToObject(CreativePlayer, 'client_onReload', function( self )
    self:emitEvent(true, 'playerReload', { player = self.player })
end)

attachFunctionToObject(CreativePlayer, 'server_onShapeRemoved', function( self, removedShapes )
    self:emitEvent(false, 'shapeRemoved', { player = self.player, removedShapes = removedShapes })
end)
