-- Similar to BaseObject but used to store data

local HttpService = game:GetService("HttpService")

local Proxy
local Output
local TableUtils

local None
local NewDataTypeEvent

-- Symbols
local SymbolPublicValues
local SymbolReadOnlyValues
local SymbolMethods
local SymbolIndex
local SymbolNewIndex
local SymbolChange
local SymbolType

local function __index(self, i)
    local publicValues      = self[SymbolPublicValues]
    local readOnlyValues    = self[SymbolReadOnlyValues]
    local methods           = self[SymbolMethods]
    local index             = self[SymbolIndex]
    local datatype          = self[SymbolType]

    local v = publicValues[i]
    if v == None then
        return nil
    elseif v ~= nil then
        return v
    end

    -- Doing this instead of an 'or' in case publicValues[i] is false
    v = readOnlyValues[i]
    if v == None then
        return nil
    elseif v ~= nil then
        return v
    end

    -- TODO: Remove this once methods are stored as a metatable
    v = methods[i]
    if v then
        return v
    end

    local userindex = index
    if userindex and type(userindex) == "function" then
        v = userindex(self, i)
        if v then
            return v
        end
    end

    -- Don't error when we try to index these values that might not exist
    if not (i == SymbolIndex or i == SymbolNewIndex or i == SymbolChange) then
        Output.error("%s is not a valid member of %s", {i, datatype}, 1)
    end
end

local function __newindex(self, i, newValue)
    local publicValues      = self[SymbolPublicValues]
    local readOnlyValues    = self[SymbolReadOnlyValues]
    local methods           = self[SymbolMethods]
    local newindex          = self[SymbolNewIndex]
    local change            = self[SymbolChange]
    local datatype          = self[SymbolType]

    local curValue = publicValues[i]

    if newValue == nil then
        newValue = None
    end

    if curValue ~= nil then
        if curValue ~= newValue then
            publicValues[i] = newValue

            if change then
                change(publicValues, i, newValue, curValue)
            end

            return true
        else
            return false
        end
    end

    curValue = readOnlyValues[i]
    if curValue ~= nil then
        if curValue ~= newValue then
            readOnlyValues[i] = newValue

            if change then
                change(readOnlyValues, i, newValue, curValue)
            end

            return true
        else
            return false
        end
    end

    local usernewindex = newindex
    if usernewindex and type(usernewindex) == "function" and usernewindex(self, i, newValue) then
        return true
    end

    Output.assert(readOnlyValues[i] == nil, "%s cannot be assigned to", i, 1)
    Output.assert(methods[i] == nil, "%s cannot be assigned to", i, 1)
    Output.error("%s is not a valid member of %s", {i, datatype}, 1)
end

local function __tostring(self)
    return "[DataType] ".. self[SymbolType]
end

local DataType = {}

function DataType.new(typeData)
    -- Custom indexing and newindexing
    local index
    local newindex

    -- If no name is given generate one
    typeData.Name                       = typeData.Name or ("[DataType] ".. HttpService:GenerateGUID(false))
    --typeData.Methods                    = typeData.Methods or {}
    typeData.Metamethods                = typeData.Metamethods or {}

    if not typeData.Methods then
        local methods = {}
        for i,v in pairs(typeData) do
            if type(v) == "function" and i ~= "Constructor" then
                methods[i] = v
            end
            typeData.Methods = methods
        end
    end

    if typeData.Metamethods.__index then
        index = typeData.Metamethods.__index
    end
    if typeData.Metamethods.__newindex then
        newindex = typeData.Metamethods.__newindex
    end

    typeData.Metamethods.__index        = __index
    typeData.Metamethods.__newindex     = __newindex
    typeData.Metamethods.__tostring     = typeData.Metamethods.__tostring or __tostring

    local dataTypeData = {
        new = function(...)
            -- TODO: Find better way of storing properties of DataTypes to reduce memory footprint
            local dataType = Proxy.new(
                {
                    [SymbolType]            = typeData.Name,

                    [SymbolIndex]           = index or None,
                    [SymbolNewIndex]        = newindex or None,
                    [SymbolChange]          = typeData.Metamethods.__change,

                    [SymbolMethods]         = typeData.Methods,
                    [SymbolPublicValues]    = TableUtils.shallowCopy(typeData.PublicValues),
                    [SymbolReadOnlyValues]  = TableUtils.shallowCopy(typeData.ReadOnlyValues)
                },
                typeData.Metamethods
            )

            -- If the DataType has a constructor call it
            if typeData.Constructor then
                typeData.Constructor(dataType, ...)
            end

            return dataType.Proxy
        end
    }

    setmetatable(dataTypeData, {__index = typeData.Methods})

    -- In case any module cares there's been a new DataType added fire the event with the locked dataTypeData
    NewDataTypeEvent:Fire(TableUtils.lock(dataTypeData))

    return dataTypeData
end

function DataType:start()
    Proxy                   = self:Load("Deus.Proxy")
    Output                  = self:Load("Deus.Output")
    TableUtils              = self:Load("Deus.TableUtils")

    local Symbol            = self:Load("Deus.Symbol")
    None                    = Symbol.get("None")
    SymbolPublicValues      = Symbol.new("SymbolPublicValues")
    SymbolReadOnlyValues    = Symbol.new("SymbolReadOnlyValues")
    SymbolMethods           = Symbol.new("SymbolMethods")
    SymbolIndex             = Symbol.new("SymbolIndex")
    SymbolNewIndex          = Symbol.new("SymbolNewIndex")
    SymbolChange            = Symbol.new("SymbolChange")
    SymbolType              = Symbol.new("SymbolType")

    local BindableEvent     = self:Load("Deus.BindableEvent")

    NewDataTypeEvent        = BindableEvent.new()

    self.NewDataType        = NewDataTypeEvent.Proxy
end

return DataType