CreativeFlatWorld = class( nil )

CreativeFlatWorld.terrainScript = "$GAME_DATA/Scripts/game/terrain/terrain_flat.lua"
CreativeFlatWorld.enableSurface = true
CreativeFlatWorld.enableAssets = false
CreativeFlatWorld.enableClutter = false
CreativeFlatWorld.enableCreations = false
CreativeFlatWorld.enableNodes = false
CreativeFlatWorld.enableCellScripts = false

function CreativeFlatWorld.server_onProjectile(self, hitPos, hitTime, hitVelocity, projectileName, attacker, damage, userData)
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

function CreativeFlatWorld.server_onProjectileFire(self, firePos, fireVelocity, projectileName, attacker)
    if sm.interop then
        sm.interop.events.emit('scrapmechanic:projectileFired', {
            firePos = firePos,
            fireVelocity = fireVelocity,
            projectileName = projectileName,
            attacker = attacker
        })
    end
end
