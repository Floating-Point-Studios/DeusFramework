local DeusFramework = {
    Libraries = {};

    -- Import libraries
    Load = require(script.Load);

    -- Register libraries
    Register = require(script.Register);

    -- Setup frameworks
    Setup = require(script.Setup);
}

shared.DeusFramework = DeusFramework

return DeusFramework