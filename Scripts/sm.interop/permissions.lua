sm.interop.permissions = {}

local permissionMod = nil
local permissions = {}
local permissionManager = nil

local DefaultPermissionManager = {

    checkPlayerLevel = function(self, player, level)
        if level == 'all' then
            return true
        elseif level == 'host' then
            return player.id == 1
        -- Todo: make neater
        elseif level == 'survival' then
            return sm.event.sendToGame('sv_killPlayer', {})
        elseif level == 'creative' then
            return not sm.event.sendToGame('sv_killplayer', {})
        elseif level == 'none' then
            return false
        end
        return false
    end,

    hasPermission = function(self, player, permission)
        local level = sm.interop.permissions.getRegisteredPermissions()[permission].default
        return self:checkPlayerLevel(player, level)
    end,

    getPermissions = function(self, player)
        local allperms = sm.interop.permissions.getRegisteredPermissions()
        local perms = {}
        for perm,options in pairs(allperms) do
            if self:checkPlayerLevel(player, options.default) then
                perms.insert(perm)
            end
        end
        return perms
    end

}

local function getPermissionManager()
    if permissionManager == nil then
        return DefaultPermissionManager
    end
    return permissionManager
end

--- Registers a permission node.
-- A permission node is an 'option' that can be turned on or off for a specific player.
-- Depending on whether this player has this option on or off, they are able to do certain
-- things, like entering certain areas, executing a command, etc.
-- @param mod     The mod that registers the permission
-- @param name    The name of the permission
-- @param options Table with key "default", which specifies
--   what the default state of this permission should be, if it
--   has not been explicitly given or removed from a player.
--   Possible values are: "all", "none", "host", "creative", "survival"
function sm.interop.permissions.register(mod, name, options)
    sm.interop.mods.assertIsValid(mod)
    local mergedOptions = {
        default = (options or {}).default or 'host'
    }
    local fullName = mod:getNamespace() .. ':' .. name
    permissions[fullName] = options
    return fullName
end

--- Gets a list of all registered permission nodes
-- @return Returns a table { [permission] = { options } ... }
-- @todo Protect
function sm.interop.permissions.getRegisteredPermissions()
    return permissions
end

--- Checks whether a player is the host.
-- @return `boolean`
function sm.interop.permissions.isHost(player)
    return player.id == 1
end

--- Checks if the user has a certain permission
-- @return True if the player has the permission, false if not
function sm.interop.permissions.hasPermission(player, permission)
    return getPermissionManager():hasPermission(player, permission)
end

--- Gets all permissions a player has
-- @return table {string...}
function sm.interop.permissions.getPermissions(player)
    return getPermissionManager():getPermissions(player)
end

--- Sets a custom permission manager
-- @param mod     The mod
-- @param manager The permission checking interface
--   The manager object has two functions:
--   - hasPermission(self, player, permission): boolean
--   - getPermissions(self, player): table {string...}
function sm.interop.permissions.setPermissionManager(mod, manager)
    assert(permissionManager == nil, 'Another permission manager was already set by ' .. permissionMod:getName())
    permissionMod = mod
    permissionManager = manager
end
