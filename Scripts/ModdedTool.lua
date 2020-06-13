-- @private
local function wrapNetwork(network, uuid)
    return {
        setClientData = function(self, data)
            error('setClientData is not implemented for modded tools')
        end,
        sendToClients = function(self, name, params)
            network:sendToClients('client_network', {
                uuid = uuid,
                name = name,
                params = params
            })
        end,
        sendToClient = function(self, player, name, params)
            network:sendToClient(player, 'client_network', {
                uuid = uuid,
                name = name,
                params = params
            })
        end,
        sendToServer = function(self, name, params)
            network:sendToServer('server_network', {
                uuid = uuid,
                name = name,
                params = params
            })
        end
    }
end

local function logpcall(fnc, ...)
    local result, error = pcall(fnc, ...)
    if not result then
        sm.log.error(error)
    end
end

-- @public
ModdedTool = class(nil)

function ModdedTool.client_onCreate(self)
    self.equipped = nil
    self.instances = {}
    self.updatingInstances = {}
end

function ModdedTool.getInstanceFor(self, uuid)
    local uuidString = tostring(uuid)
    if self.instances[uuidString] == nil then
        -- If we can find a class for this tool, get an instance and copy functions into self
        local instance = sm.interop.tools.getToolClass(uuid)
        if instance then
            -- Add self.tool and self.network
            -- Make sure network calls are routed to the appropriate instance
            instance.tool = self.tool
            instance.network = wrapNetwork(self.network, uuid)

            self.instances[uuidString] = instance

            if sm.isServerMode() then
                self.server_initializeTool(uuid)
                self.network:sendToClients('client_initializeTool', uuid)
            else
                self:client_initializeTool(uuid)
                self.network:sendToServer('server_initializeTool', uuid)
            end
        end
    end
    return self.instances[uuidString]
end

function ModdedTool.client_initializeTool(self, uuid)
    sm.gui.chatMessage('client_initializeTool')
    local instance = self:getInstanceFor(uuid)

    -- client_onUpdate
    if type(instance.client_onUpdate) == 'function' then
        self.updatingInstances[#self.updatingInstances + 1] = instance
    end

    -- Call client_onCreate if it exists
    if type(instance.client_onCreate) == 'function' then
        logpcall(instance.client_onCreate, instance)
    end
end

function ModdedTool.server_initializeTool(self, uuid)
    print('server_initializeTool')
    local instance = self:getInstanceFor(uuid)
    if type(instance.server_onCreate) == 'function' then
        logpcall(instance.server_onCreate, instance)
    end
end

function ModdedTool.client_onEquip(self)
    if self.tool:isLocal() then
        if not sm.interop then
            sm.gui.chatMessage('#ff0000Error: #ffffffCannot load modded tool, because mod "sm.interop" is not installed, or no scripted part that uses sm.interop has been placed in this world yet.')
            return
        end
        local item = sm.localPlayer.getActiveItem()
        if tostring(item) == 'e74ff990-adac-434f-9967-bf9833d0bd69' then
            sm.gui.chatMessage('#88e653[sm.interop] #ffffffYou have selected the Modded Tool. You need to keep this in your inventory for Modded Tools by other mods to work. You can put it in another hotbar as well.')
            return
        end
        if item ~= nil then
            self.equipped = self:getInstanceFor(item)
            if self.equipped ~= nil then
                -- Call client_onEquip if it exists
                if type(self.equipped.client_onEquip) == 'function' then
                    logpcall(self.equipped.client_onEquip, self.equipped)
                end
            else
                sm.gui.chatMessage('#ff0000Error: #ffffffThe tool class for "'..sm.shape.getShapeTitle(item)..'" could not be loaded. Place a scripted part from this mod to load it.')
            end
        end
    end
end

function ModdedTool.client_onUnequip(self)
    local instance = self.equipped
    if instance and type(instance.client_onUnequip) == 'function' then
        logpcall(instance.client_onUnequip, instance)
    end
    self.equipped = nil
end

function ModdedTool.client_onToggle(self)
    local instance = self.equipped
    if instance and type(instance.client_onToggle) == 'function' then
        logpcall(instance.client_onToggle, instance)
    end
end

function ModdedTool.client_onReload(self)
    local instance = self.equipped
    if instance and type(instance.client_onReload) == 'function' then
        logpcall(instance.client_onReload, instance)
    end
end

function ModdedTool.client_onUpdate(self, dt)
    for _,instance in ipairs(self.updatingInstances) do
        logpcall(instance.client_onUpdate, instance, dt)
    end
end

function ModdedTool.client_onDestroy(self)
    for i,instance in pairs(self.instances) do
        if type(instance.client_onDestroy) == 'function' then
            logpcall(instance.client_onDestroy, instance)
        end
    end
end

function ModdedTool.client_onEquippedUpdate(self, ...)
    local instance = self.equipped
    if instance ~= nil and type(instance.client_onEquippedUpdate) == 'function' then
        local success, value1, value2 = pcall(instance.client_onEquippedUpdate, instance, ...)
        if success then
            return value1, value2
        else
            sm.log.error(value1)
        end
    end
    return false, false
end

function ModdedTool.client_network(self, data)
    local uuid = data.uuid
    local instance = self:getInstanceFor(uuid)
    local mtd = instance[data.name]
    assert(type(mtd) == 'function', 'Callback ' .. data.name ..  ' does not exist in ' .. sm.shape.getShapeTitle(uuid) ..'\'s tool class')
    logpcall(mtd, instance)
end

-- Same thing
ModdedTool.server_network = ModdedTool.client_network
