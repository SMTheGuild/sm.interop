function CreativePlayer.emitEvent(self, client, name, data)
    if sm.interop then
        sm.interop.events.emit('scrapmechanic:'..name, data, 'both', true)
    end
end

function CreativePlayer.client_onInteract( self, character, state )
    self:emitEvent(true, 'playerInteract', {
        player = self.player,
        character = character,
        state = state
    })
end

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

-- Disabled for performance reasons
-- function CreativePlayer.server_onCollision( self, other, collisionPosition, selfPointVelocity, otherPointVelocity, collisionNormal  )
--     self:emitEvent(false, 'playerCollision', {
--         player = self.player,
--         other = other,
--         collisionPosition = collisionPosition,
--         selfPointVelocity = selfPointVelocity,
--         otherPointVelocity = otherPointVelocity,
--         collisionNormal = collisionNormal
--     })
-- end

function CreativePlayer.client_onCancel( self )
    self:emitEvent(true, 'playerCancel', { player = self.player })
end

function CreativePlayer.client_onReload( self )
    self:emitEvent(true, 'playerReload', { player = self.player })
end

function CreativePlayer.server_onShapeRemoved( self, removedShapes )
    self:emitEvent(false, 'shapeRemoved', { player = self.player, removedShapes = removedShapes })
end
