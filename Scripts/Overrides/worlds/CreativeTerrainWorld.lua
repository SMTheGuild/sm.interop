function CreativeTerrainWorld.server_onCreate(self)
    local uuid = sm.uuid.new('cf73bdd4-caab-440d-b631-2cac12c17904')
    local modPartsLoaded = pcall(sm.item.getShapeSize, uuid)
    if modPartsLoaded then
        sm.shape.createPart(uuid, sm.vec3.new(0, 0, -32), sm.quat.identity(), false, false)
    end
end

function CreativeTerrainWorld.server_onProjectile(self, hitPos, hitTime, hitVelocity, projectileName, attacker, damage, userData)
    if sm.interop then
        sm.interop.events.emit('scrapmechanic:worldHitByProjectile', {
            hitPos = hitPos,
            hitTime = hitTime,
            hitVelocity = hitVelocity,
            projectileName = projectileName,
            attacker = attacker,
            damage = damage,
            userData = userData
        })
    end
end

function CreativeTerrainWorld.server_onProjectileFire(self, firePos, fireVelocity, projectileName, attacker)
    if sm.interop then
        sm.interop.events.emit('scrapmechanic:projectileFired', {
            firePos = firePos,
            fireVelocity = fireVelocity,
            projectileName = projectileName,
            attacker = attacker
        })
    end
end
