local Maid
local JSON
local Output
local TableUtils
local StringUtils

-- Symbols
local SymbolPrivateProps
local SymbolReadableProps
local SymbolWritableProps
local SymbolEvents
local SymbolMethods

local ObjectMetatables

local Object = {}

function Object:IsA(className)
    local object = self

    if className == "BaseObject" then
        return true
    end

    repeat
        if object.ClassName == className then
            return true
        end

        object = object.Superclass
    until object == "BaseObject"

    return false
end

--[[
-- Runs constructor again to reset the object, useful for re-using instead of destroying objects
function Object:Reconstruct(...)
    Output.assert(self:IsInternalAccess(), "Object can only be reconstructed with internal access", nil, 1)

    local constructor = self.Constructor
    if constructor then
        constructor(self, ...)
    else
        Output.error("Object class %s does not have any constructor parameters", self.ClassName, 1)
    end

    return self
end
]]

function Object:Destroy()
    -- Output.assert(self:IsInternalAccess(), "Object only be destroyed with internal access", nil, 1)
    if self.Alive then
        local metatable = ObjectMetatables[self] or self
        local destructor = self.Destructor

        rawset(metatable, "Alive", false)

        if destructor then
            -- Destructor is allowed to return list of objects it wants destroyed
            for _,v in pairs(destructor(metatable, self:IsInternalAccess()) or {}) do
                Maid:GiveTask(v)
            end
        end

        Maid:GiveTask(metatable)
        Maid:DoCleaning()

        -- Clean up anything the maid missed
        for i,v in pairs(metatable) do
            if i ~= "Alive" then
                if type(v) == "table" then
                    setmetatable(v, {__mode = "kv"})
                end

                metatable[i] = nil
            end
        end
    end
end

-- Fires an event of the object
function Object:FireEvent(eventName, ...)
    Output.assert(self:IsInternalAccess(), "Object events can only be fired with internal access", nil, 1)
    Output.assert(self[SymbolEvents][eventName], "Event %s is not a valid member of %s", {eventName, self.ClassName}, 1)
    self[SymbolEvents][eventName]:Fire(...)

    return self
end

-- Returns a ScriptSignalConnection for a specific property
function Object:GetPropertyChangedSignal(eventName, func)
    Output.assert(self[SymbolEvents][eventName], "Event %s is not a valid member of %s", {eventName, self.ClassName}, 1)
    local event = Instance.new("BindableEvent")
    local proxySignal = event.Event:Connect(func)
    local mainSignal

    mainSignal = self[SymbolEvents][eventName]:Connect(function(...)
        if proxySignal.Connected then
            event:Fire(...)
        else
            mainSignal:Disconnect()
            event:Destroy()
        end
    end)

    return proxySignal
end

function Object:GetMethods()
    return self[SymbolMethods]:GetKeys()
end

-- TODO: Check if this allows external access to fire events
function Object:GetEvents()
    return TableUtils.getKeys(self[SymbolEvents])
end

-- Returns all public properties
function Object:GetReadableProperties()
    return {TableUtils.unpack(TableUtils.getKeys(self[SymbolReadableProps]), TableUtils.getKeys(self[SymbolWritableProps]))}
end

-- Returns all public properties that can be edited without internal access
function Object:GetWritableProperties()
    return TableUtils.getKeys(self[SymbolWritableProps])
end

-- Attempts to serialize the object
function Object:SerializeProperties()
    return JSON.serialize(
        {
            ClassName = self.ClassName,
            Private = self[SymbolPrivateProps],
            ReadOnlyProperties = self[SymbolReadableProps],
            ReadAndWriteProperties = self[SymbolWritableProps]
        }
    )
end

function Object:Hash()
    return tostring(StringUtils.hash(self:SerializeProperties()))
end

function Object:IsInternalAccess()
    return typeof(self) ~= "userdata"
end

function Object:start()
    Maid                = self:Load("Deus.Maid").new()
    JSON                = self:Load("Deus.JSON")
    Output              = self:Load("Deus.Output")
    TableUtils          = self:Load("Deus.TableUtils")
    StringUtils         = self:Load("Deus.StringUtils")
end

function Object:init(state)
    SymbolPrivateProps  = state.SymbolPrivateProps
    SymbolReadableProps = state.SymbolReadableProps
    SymbolWritableProps = state.SymbolWritableProps
    SymbolEvents        = state.SymbolEvents
    SymbolMethods       = state.SymbolMethods

    ObjectMetatables    = state.ObjectMetatables
end

return Object