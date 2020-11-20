local DeusFramework = {
    Libraries = {};

    -- Import libraries
    import = require(script.Import);

    -- Register libraries
    register = require(script.Register);

    -- Setup frameworks
    setup = require(script.Setup);
}

shared.DeusFramework = DeusFramework

return DeusFramework