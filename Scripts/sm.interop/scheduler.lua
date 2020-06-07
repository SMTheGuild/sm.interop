-- @private
local scheduler = {}

-- Tasks scheduled to run in the future (scheduledTasks[tickToRun][taskId] = task)
local scheduledTasks = {}

-- Table that maps task IDs to the tick that they should run
local idToTick = {}

--- The next task ID. Starts at 1
local nextTaskId = 1

--- Last tick the scheduler was called for
local lastRunTick = nil

--- Schedules a task to run after a number of ticks.
-- @param task  The task function to schedule
-- @param delay The number of ticks after which the task should be run
scheduler.scheduleAfter = function(task, delay)
   scheduler.scheduleAt(task, sm.game.getServerTick() + delay)
end

--- Schedule at certain tick.
-- @param task  The task function to schedule
-- @param tick
scheduler.scheduleAt = function(task, tick)
   -- Determine tick. If given tick is in the past, schedule for next tick
   local currentTick = sm.game.getServerTick()
   if tick <= currentTick then
       tick = currentTick + 1
   end

   -- Schedule task
   if scheduledTasks[tick] == nil then
       scheduledTasks[tick] = {}
   end
   local taskId = nextTaskId
   scheduledTasks[tick][taskId] = task;
   idToTick[taskId] = tick;

   -- Increase task Id
   nextTaskId = taskId + 1
   return taskId
end

--- Remove a scheduled task from the schedule.
-- @param taskId The task ID
scheduler.unschedule = function(taskId)
   local tick = idToTick[taskId]
   if tick == nil then
       return
   end

   -- Unschedule task
   scheduledTasks[tick][taskId] = nil
   idToTick[taskId] = nil
end

local runTick = function(tick)
    local tasks = scheduledTasks[tick]
    if tasks == nil then
        return
    end

    -- Run the tasks and keep track of errors
    for id,task in pairs(tasks) do
        pcall(task)
        idToTick[id] = nil
    end

    -- Remove run tasks
    scheduledTasks[tick] = nil
    return errors
end

scheduler.tick = function()
   -- Determine which tasks to run
   local currentTick = sm.game.getServerTick()
   if lastRunTick == nil then
       runTick(currentTick)
    else
        for tick = lastRunTick + 1, currentTick do
            runTick(tick)
        end
    end
    lastRunTick = currentTick
end

-- @export
sm.interop.scheduler = scheduler
