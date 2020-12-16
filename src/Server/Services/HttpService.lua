local Deus = shared.DeusFramework

local ServiceWrapper = Deus:Load("Deus/ServiceWrapper")

local RBXHttpService = game:GetService("HttpService")

local function requestAsync(url, method, headers, body)
    RBXHttpService:RequestAsync(
        {
            Url = url,
            Method = method:upper(),
            Headers = headers or {},
            Body = body or {}
        }
    )
end

local HttpService = ServiceWrapper.new("HttpService")

function HttpService.get(url, headers, body)
    return requestAsync(url, "GET", headers, body)
end

function HttpService.head(url, headers, body)
    return requestAsync(url, "HEAD", headers, body)
end

function HttpService.post(url, headers, body)
    return requestAsync(url, "POST", headers, body)
end

function HttpService.put(url, headers, body)
    return requestAsync(url, "PUT", headers, body)
end

function HttpService.delete(url, headers, body)
    return requestAsync(url, "DELETE", headers, body)
end

function HttpService.connect(url, headers, body)
    return requestAsync(url, "CONNECT", headers, body)
end

function HttpService.options(url, headers, body)
    return requestAsync(url, "OPTIONS", headers, body)
end

function HttpService.trace(url, headers, body)
    return requestAsync(url, "TRACE", headers, body)
end

function HttpService.patch(url, headers, body)
    return requestAsync(url, "PATCH", headers, body)
end

function HttpService.insertPathParams(path, params)
    
end

return HttpService