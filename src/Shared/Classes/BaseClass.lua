local HttpService = game:GetService("HttpService")

local Deus = shared.Deus

local TableUtils = Deus:Load("Deus.TableUtils")

function __tostring(self)
    return ("[DeusObject] {%s} {%s}"):format(self.ClassName, self.ObjectId)
end

local BaseObject = {}

function BaseObject.new(objData)
    return {
        Constructor = objData.Constructor,

        Methods = objData.Methods,
        Events = objData.Events,
        Properties = objData.Properties,

        new = function(properties)
            local proxy = newproxy(true)
            local metatable = getmetatable(proxy)

            metatable.Methods = objData.Methods
            metatable.Events = {}
            metatable.Properties = TableUtils.shallowCopy(objData.Properties)

            for _,eventName in pairs(objData.Events) do
                --metatable.Events[eventName] =
            end

            return setmetatable(metatable, BaseObject)
        end
    }
end

function BaseObject:Extend(obj, extendedMethods, extendedEvents, extendedProperties)
    if extendedMethods ~= false then
        if extendedMethods == true or extendedMethods == nil then
            self.Methods = TableUtils.merge(self.Methods, obj.Methods)
        elseif type(extendedMethods) == "table" then
            for name, method in pairs(obj.Methods) do
                self.Methods[name] = method
            end
        end
    end

    if extendedEvents ~= false then
        if extendedEvents == true or extendedEvents == nil then
            self.Methods = TableUtils.merge(self.Methods, obj.Methods)
        elseif type(extendedEvents) == "table" then
            for name, method in pairs(obj.Methods) do
                self.Methods[name] = method
            end
        end
    end

    if extendedProperties ~= false then
        if extendedProperties == true or extendedProperties == nil then
            self.Methods = TableUtils.merge(self.Methods, obj.Methods)
        elseif type(extendedProperties) == "table" then
            for name, method in pairs(obj.Methods) do
                self.Methods[name] = method
            end
        end
    end
end

function BaseObject:SetInstance(obj)
    
end

function BaseObject:Serialize()
    
end

return BaseObject