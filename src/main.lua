
--[[
    NYU HUB
    Version: 1.0.0
    Repository: SCRIPT-HUB-BANYU
]]

local NyuHub = {
    Name = "Nyu Hub",
    Version = "1.0.0",
}

function NyuHub.getInfo()
    return {
        name = NyuHub.Name,
        version = NyuHub.Version,
        status = "Initialized",
    }
end

function NyuHub.start()
    print("================================")
    print("       NYU HUB INITIALIZED      ")
    print("================================")
    print("Version:", NyuHub.Version)
    print("Status: Ready")
end

NyuHub.start()

return NyuHub
