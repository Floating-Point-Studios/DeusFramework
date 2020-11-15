local RbxHttpService = game:GetService("HttpService")

local HttpService = {}

function HttpService.get(url, headers, body)
    return RbxHttpService:RequestAsync({
        Url = url,
        Method = "GET",
        Headers = headers,
        Body = body
    })
end

function HttpService.head(url, headers, body)
    return RbxHttpService:RequestAsync({
        Url = url,
        Method = "HEAD",
        Headers = headers,
        Body = body
    })
end

function HttpService.post(url, headers, body)
    return RbxHttpService:RequestAsync({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
end

function HttpService.put(url, headers, body)
    return RbxHttpService:RequestAsync({
        Url = url,
        Method = "PUT",
        Headers = headers,
        Body = body
    })
end

function HttpService.delete(url, headers, body)
    return RbxHttpService:RequestAsync({
        Url = url,
        Method = "DELETE",
        Headers = headers,
        Body = body
    })
end

function HttpService.connect(url, headers, body)
    return RbxHttpService:RequestAsync({
        Url = url,
        Method = "CONNECT",
        Headers = headers,
        Body = body
    })
end

function HttpService.options(url, headers, body)
    return RbxHttpService:RequestAsync({
        Url = url,
        Method = "OPTIONS",
        Headers = headers,
        Body = body
    })
end

function HttpService.trace(url, headers, body)
    return RbxHttpService:RequestAsync({
        Url = url,
        Method = "TRACE",
        Headers = headers,
        Body = body
    })
end

function HttpService.patch(url, headers, body)
    return RbxHttpService:RequestAsync({
        Url = url,
        Method = "PATCH",
        Headers = headers,
        Body = body
    })
end

function HttpService.formatUrl(url, pathParams, queryStrings)
    
end

return HttpService