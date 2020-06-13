CreativeTerrainWorld = class( nil )

CreativeTerrainWorld.terrainScript = "$GAME_DATA/Scripts/game/terrain/terrain_creative.lua"
CreativeTerrainWorld.enableSurface = true
CreativeTerrainWorld.enableAssets = true
CreativeTerrainWorld.enableClutter = true
CreativeTerrainWorld.enableCreations = false
CreativeTerrainWorld.enableNodes = false
CreativeTerrainWorld.enableCellScripts = false

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
