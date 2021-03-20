-- Similar to BaseObject but used to store data

local HttpService = game:GetService("HttpService")

local Proxy
local Output
local TableUtils

local None
local NewDataTypeEvent

local function __index(self, i)
    local v = self.__publicValues[i]
    if v == None then
        return nil
    elseif v ~= nil then
        return v
    end

    -- Doing this instead of an 'or' in case publicValues[i] is false
    v = self.__readOnlyValues[i]
    if v == None then
        return nil
    elseif v ~= nil then
        return v
    end

    -- TODO: Remove this once methods are stored as a metatable
    v = self.__methods[i]
    if v then
        return v
    end

    if self.__userindex then
        v = self.__userindex(self, i)
        if v then
            return v
        end
    end

    -- Don't error when we try to index these values that might not exist
    if not (i == "__userindex" or i == "__usernewindex" or i == "__change") then
        Output.error("%s is not a valid member of %s", {i, self.__type}, 1)
    end
end

local function __newindex(self, i, newValue)
    local curValue = self.__publicValues[i]

    if newValue == nil then
        newValue = None
    end

    if curValue ~= nil then
        if curValue ~= newValue then
            self.__publicValues[i] = newValue

            if self.__change then
                self.__change(self.__publicValues, i, newValue, curValue)
            end

            return true
        end
    end

    curValue = self.__readOnlyValues[i]
    if curValue ~= nil then
        if curValue ~= newValue then
            self.__readOnlyValues[i] = newValue

            if self.__change then
                self.__change(self.__readOnlyValues, i, newValue, curValue)
            end

            return true
        end
    end

    if self.__usernewindex and self.__usernewindex(self, i, newValue) then
        return true
    end

    Output.assert(self.__readOnlyValues[i] == nil, "%s cannot be assigned to", i, 1)
    Output.assert(self.__methods[i] == nil, "%s cannot be assigned to", i, 1)
    Output.error("%s is not a valid member of %s", {i, self.__type}, 1)
end

local function __tostring(self)
    return "[DataType] ".. self.__type
end

local DataType = {}

function DataType.new(typeData)
    -- Custom indexing and newindexing
    local index
    local newindex

    -- If no name is given generate one
    typeData.Name                       = typeData.Name or ("[DataType] ".. HttpService:GenerateGUID(false))
    typeData.Methods                    = typeData.Methods or {}
    typeData.Metamethods                = typeData.Metamethods or {}

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
                    __type              = typeData.Name,

                    __userindex         = index,
                    __usernewindex      = newindex,
                    __change            = typeData.Metamethods.__change,

                    __methods           = typeData.Methods,
                    __publicValues      = TableUtils.shallowCopy(typeData.PublicValues),
                    __readOnlyValues    = TableUtils.shallowCopy(typeData.ReadOnlyValues)
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
    Proxy = self:Load("Deus.Proxy")
    Output = self:Load("Deus.Output")
    TableUtils = self:Load("Deus.TableUtils")

    None = self:Load("Deus.Symbol").new("None")

    local BindableEvent = self:Load("Deus.BindableEvent")

    NewDataTypeEvent = BindableEvent.new()

    self.NewDataType = NewDataTypeEvent.Proxy
end

return DataType