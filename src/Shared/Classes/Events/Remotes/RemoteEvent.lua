local Deus = shared.Deus

local RunService = game:GetService("RunService")

local Debug = Deus:Load("Deus/Debug")
local Connection = Deus:Load("Deus/SignalConnection")
local Symbol = Deus:Load("Deus/Symbol")

local SymbolNone = Symbol.new("None")

return Deus:Load("Deus/BaseObject"):Extend(
    {
        __index = function(self, i)
            return self.Internals.RemoteEvent[i]
        end;

        __newindex = function(self, i, v)
            self.Internals.RemoteEvent[i] = v
            return true
        end;

        ClassName = "Deus/RemoteEvent";

        Constructor = function(self, remoteEvent)
            if RunService:IsClient() then
                self.Internals.RemoteEvent = remoteEvent

                self.Internals.RemoteConnection = remoteEvent.OnClientEvent:Connect(function(...)
                    local args = {...}
                    local sendFilter = self.ExternalReadOnly.SendFilter

                    if type(sendFilter) == "function" then
                        args = sendFilter(...)
                    end

                    if RunService:IsClient() then
                        self.Internals.RemoteEvent:FireServer(unpack(args))
                    else
                        self.Internals.RemoteEvent:FireClient(unpack(args))
                    end
                end)
            else
                remoteEvent = Instance.new("RemoteEvent")
                self.Internals.RemoteEvent = remoteEvent

                self.Internals.RemoteConnection = remoteEvent.OnServerEvent:Connect(function(...)
                    local args = {...}
                    local receiveFilter = self.ExternalReadOnly.ReceiveFilter

                    if type(receiveFilter) == "function" then
                        args = {receiveFilter(...)}
                    end

                    for _,connection in pairs(self.Internals.Connections) do
                        -- [TO-DO] Run functions on new thread once parallel Luau is released
                        if connection.Connected then
                            connection.Func(unpack(args))
                        end
                    end
                end)
            end
        end;

        Internals = {
            Connections = setmetatable({}, {__mode = "kv"})
        };

        Methods = {
            Fire = function(self, ...)
                local args = {...}
                local sendFilter = self.ExternalReadOnly.SendFilter

                if type(sendFilter) == "function" then
                    args = {sendFilter(...)}
                end

                if RunService:IsClient() then
                    self.Internals.RemoteEvent:FireServer(unpack(args))
                else
                    self.Internals.RemoteEvent:FireClient(unpack(args))
                end
            end;

            Connect = function(self, func)
                local connectionProxy, connectionMetatable = Connection.new(func)
                table.insert(self.Internals.Connections, connectionMetatable)

                return connectionProxy
            end;

            Wait = function(self, timeout)
                timeout = timeout or 30

                local waitStart = tick()
                repeat
                    RunService.Heartbeat:Wait()
                    if tick() - waitStart > timeout then
                        Debug.warn("Event wait timed out after %s seconds", timeout)
                        break
                    end
                until self.LastFired > waitStart

                return
            end
        };

        ExternalReadOnly = {
            LastFired = 0
        };

        ExternalReadAndWrite = {
            SendFilter = SymbolNone;
            ReceiveFilter = SymbolNone
        };
    }
)