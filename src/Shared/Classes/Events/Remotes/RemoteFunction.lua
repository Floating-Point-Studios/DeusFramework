local Deus = shared.Deus

local RunService = game:GetService("RunService")

local Debug = Deus:Load("Deus/Debug")
local Symbol = Deus:Load("Deus/Symbol")

local SymbolNone = Symbol.new("None")

return Deus:Load("Deus/BaseObject"):Extend(
    {
        __index = function(self, i)
            return self.Internals.RemoteFunction[i]
        end;

        __newindex = function(self, i, v)
            self.Internals.RemoteFunction[i] = v
            return true
        end;

        ClassName = "Deus/RemoteFunction";

        Constructor = function(self, RemoteFunction)
            if RunService:IsClient() then
                Debug.assert(RemoteFunction, "Expected to be provided a RemoteFunction while on client")

                self.Internals.RemoteFunction = RemoteFunction

                function RemoteFunction.OnClientInvoke(...)
                    local args = {...}
                    local receiveFilter = self.ExternalReadOnly.ReceiveFilter
                    local returnFilter = self.ExternalReadAndWrite.ReturnFilter

                    if type(receiveFilter) == "function" then
                        args = {receiveFilter(...)}
                    end

                    local output = self.Internals.Callback(args)
                    if type(receiveFilter) == "function" then
                        output = {returnFilter(...)}
                    end

                    return output
                end
            else
                Debug.assert(RemoteFunction, "Unexpected RemoteFunction provided while on server")

                RemoteFunction = Instance.new("RemoteFunction")
                self.Internals.RemoteFunction = RemoteFunction

                function RemoteFunction.OnServerInvoke(...)
                    local args = {...}
                    local receiveFilter = self.ExternalReadOnly.ReceiveFilter
                    local returnFilter = self.ExternalReadAndWrite.ReturnFilter

                    if type(receiveFilter) == "function" then
                        args = {receiveFilter(...)}
                    end

                    local output = self.Internals.Callback(args)
                    if type(receiveFilter) == "function" then
                        output = {returnFilter(...)}
                    end

                    return output
                end
            end
        end;

        Internals = {
            Callback = nil
        };

        Methods = {
            Fire = function(self, ...)
                local args = {...}
                local sendFilter = self.ExternalReadAndWrite.SendFilter
                local receiveFilter = self.ExternalReadAndWrite.ReceiveFilter

                if type(sendFilter) == "function" then
                    args = {sendFilter(...)}
                end

                if RunService:IsClient() then
                    self.Internals.RemoteFunction:InvokeServer(unpack(args))
                else
                    self.Internals.RemoteFunction:InvokeClient(unpack(args))
                end
            end;

            Connect = function(self, func)
                self.Internals.Callback = func
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
            ReceiveFilter = SymbolNone;
            ReturnFilter = SymbolNone
        };
    }
)