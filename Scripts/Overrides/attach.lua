function attachFunctionToObject(object, functionName, fnc, where)
    if type(object[functionName]) ~= 'function' then
        object[functionName] = fnc
        return
    end

    local originalFunction = object[functionName]
    if where == 'before' then
        object[functionName] = function(...)
            fnc(unpack(...))
            originalFunction(unpack(...))
        end
    else
        object[functionName] = function(...)
            originalFunction(...)
            fnc(...)
        end
    end
end

function attachFunctionToAllObjects(objects, functionName, fnc, where)
    for _, object in ipairs(objects) do
        attachFunctionToObject(object, functionName, fnc, where)
    end
end
