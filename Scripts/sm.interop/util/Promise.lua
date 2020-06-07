local Promise = {}

function Promise.new(callback)
    local promise = {
        callbacks = {
            callback
        }
    }
    
end

function Promise.then(promise, callback)
    promise:then(callback)
end

sm.interop.util.Promise = {}
