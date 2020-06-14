CreativeCustomWorld = class( nil )

CreativeCustomWorld.terrainScript = "$GAME_DATA/Scripts/game/terrain/terrain_custom.lua"
CreativeCustomWorld.enableSurface = true
CreativeCustomWorld.enableAssets = true
CreativeCustomWorld.enableClutter = true
CreativeCustomWorld.enableCreations = false
CreativeCustomWorld.enableNodes = false
CreativeCustomWorld.enableCellScripts = false

function CreativeCustomWorld.server_onCreate(self)
    local uuid = sm.uuid.new('cf73bdd4-caab-440d-b631-2cac12c17904')
    local modPartsLoaded = pcall(sm.item.getShapeSize, uuid)
    if modPartsLoaded then
        sm.shape.createPart(uuid, sm.vec3.new(0, 0, -32), sm.quat.identity(), false, false)
    end
end

function CreativeCustomWorld.server_onProjectile(self, hitPos, hitTime, hitVelocity, projectileName, attacker, damage, userData)
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

function CreativeCustomWorld.server_onProjectileFire(self, firePos, fireVelocity, projectileName, attacker)
    if sm.interop then
        sm.interop.events.emit('scrapmechanic:projectileFired', {
            firePos = firePos,
            fireVelocity = fireVelocity,
            projectileName = projectileName,
            attacker = attacker
        })
    end
end
