local import = shared.DeusFramework:Import

local TableUtils = import("Deus/TableUtils")

local RemoteEvent = {}

return TableUtils.lock(RemoteEvent)