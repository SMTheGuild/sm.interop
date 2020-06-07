StartupRunner = class(nil)

-- Execute outside of callback environment
if sm.interop then
    sm.interop.startup.runOldScripts()
end

function StartupRunner.server_onCreate(self)
    self.shape:destroyShape()
end
