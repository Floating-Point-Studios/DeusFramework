local function getModuleExtension(moduleName)
    return (moduleName:match("%.%w+$") or ""):sub(2):lower()
end

return function(deus, library, libraryName, extensionIgnoreList)
    
end