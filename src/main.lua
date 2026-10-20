
--[[
    NYU HUB
    Version: 1.0.0
    Repository: SCRIPT-HUB-BANYU
]]

local Players = game:GetService("Players")

local Config = require(script.Parent.config)
local UI = require(script.Parent.ui)

local NyuHub = {}

function NyuHub.init()
    local player = Players.LocalPlayer

    if not player then
        warn("[Nyu Hub] LocalPlayer tidak tersedia.")
        return
    end

    local success, result = pcall(function()
        return UI.create(player, Config)
    end)

    if not success then
        warn("[Nyu Hub] UI gagal dimuat:", result)
        return
    end

    print(
        string.format(
            "[%s] v%s berhasil diinisialisasi.",
            Config.Name,
            Config.Version
        )
    )

    return result
end

return NyuHub
