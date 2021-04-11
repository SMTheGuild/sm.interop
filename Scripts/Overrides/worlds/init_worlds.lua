dofile '$CONTENT_e94ac99f-393e-4816-abe3-353435a1edf4/Scripts/Overrides/attach.lua'

function attachEventsToWorlds(worldClass)
    attachFunctionToObject(worldClass, 'server_onCreate', function(self)
        local uuid = sm.uuid.new('cf73bdd4-caab-440d-b631-2cac12c17904')
        local modPartsLoaded = pcall(sm.item.getShapeSize, uuid)
        if modPartsLoaded then
            sm.shape.createPart(uuid, sm.vec3.new(0, 0, -32), sm.quat.identity(), false, false)
        end
    end)

    attachFunctionToObject(worldClass, 'server_onProjectile', function(self, hitPos, hitTime, hitVelocity, projectileName, attacker, damage, userData)
        if sm.interop then
            sm.interop.events.emit('scrapmechanic:worldHitByProjectile', {
                hitPos = hitPos,
                hitTime = hitTime,
                hitVelocity = hitVelocity,
                projectileName = projectileName,
                attacker = attacker,
                damage = damage,
                userData = userData
            }, 'both', true)
        end
    end)

    attachFunctionToObject(worldClass, 'server_onProjectileFire', function(self, firePos, fireVelocity, projectileName, attacker)
        if sm.interop then
            sm.interop.events.emit('scrapmechanic:projectileFired', {
                firePos = firePos,
                fireVelocity = fireVelocity,
                projectileName = projectileName,
                attacker = attacker
            }, 'both', true)
        end
    end)

    attachFunctionToObject(worldClass, 'sv_cl_interopCommandSubFunction', function(self, params)
        sm.interop.commands.callSubFunction(params.modName, params.commandName, params.functionName, params.params)
    end)

    attachFunctionToObject(worldClass, 'cl_interopCommandExecute', function(self, params)
        local success, err = pcall(sm.interop.commands.call, params.commandName, params.args, self.network)
        if not success then
            sm.gui.chatMessage('#ff0000Error: #ffffffAn error occurred while executing this command')
            print(err)
        end
    end)

    attachFunctionToObject(worldClass, 'sv_interopCommandExecute', function(self, params)
        self.network:sendToClient(params.player, 'cl_interopCommandExecute', {
            commandName = params.commandName,
            args = params.args
        })
    end)
end
