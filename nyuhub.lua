
--[[
    NYU HUB
    Version: 1.0.0
    Feature: Initialization
]]

local HUB_NAME = "NYU HUB"
local HUB_VERSION = "1.0.0"

local success, Rayfield = pcall(function()
    local source = game:HttpGet("https://sirius.menu/gen2")
    local loader = loadstring(source)

    assert(loader, "Rayfield loader tidak valid")

    return loader()
end)

if not success or not Rayfield then
    warn(
        "[" .. HUB_NAME .. "] Gagal memuat library: "
        .. tostring(Rayfield)
    )
    return
end

print(
    "[" .. HUB_NAME .. "] Rayfield berhasil dimuat. Version "
    .. HUB_VERSION
)
