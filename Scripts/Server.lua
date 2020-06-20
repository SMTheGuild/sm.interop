dofile 'init.lua'

-- @import
local server = sm.interop.server
local startup = sm.interop.startup
local scheduler = sm.interop.scheduler

Server = class(nil)

function Server.server_onCreate(self)
    server.serverPartCreated(self)

    self.destroyTimer = -1
    self.startupScriptsRun = false
    local startupScripts = self.storage:load()
    if startupScripts ~= nil then
        startup.restoreStartupScripts(startupScripts)
    else
        self:interop_notifyOfStartupChange()
    end
end

function Server.server_onFixedUpdate(self)
    -- If the part is not about to be deleted because it is invalid
    if self.destroyTimer == -1 then
        if server.isValid(self.shape) then
            if self.startupChanged then
                self:server_saveStartupScripts()
            elseif not self.startupScriptsRun then
                self:server_saveStartupScripts()
                startup.startRunOldScripts()
                self.startupScriptsRun = true
            end
            scheduler.tick()
            self:server_transmitEvents()
        else
            -- Destroy this part if it doesn't belong here
            server.createNewShape()
            self.destroyTimer = 2
        end
    else
        if self.destroyTimer == 0 then
            self.shape:destroyShape()
        else
            self.destroyTimer = self.destroyTimer - 1
        end
    end
end

function Server.client_onUpdate(self, dt)
    self:client_transmitEvents()
end

--
-- Client-server event transmission
--
function Server.server_transmitEvents(self)
    local events = sm.interop.events.getSendToServerEvents()
    if #events > 0 then
        self.network:sendToClients('cl_sv_emitEvents', events)
        print('SentToClients')
    end
end
function Server.client_transmitEvents(self)
    local events = sm.interop.events.getSendToServerEvents()
    if #events > 0 then
        self.network:sendToClients('cl_sv_emitEvents', events)
        print('SentToServer')
    end
end
function Server.sv_cl_emitEvents(self, params)
    for i,v in ipairs(params) do
        sm.interop.events.emit(v.name, v.data, v.targetEnvironment, false)
    end
end

--
-- Startup scripts
--
function Server.server_saveStartupScripts(self)
    self.storage:save(startup.getStartupScripts())
    self.startupChanged = false
end

function Server.interop_notifyOfStartupChange(self)
    self.startupChanged = true
end
