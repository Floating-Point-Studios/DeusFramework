local DeusFramework = {
    Libraries = {};

    -- Import libraries
    Import = require(script.Import);

    -- Register libraries
    Register = require(script.Register);

    -- Setup frameworks
    Setup = require(script.Setup);
}

shared.DeusFramework = DeusFramework

return DeusFramework