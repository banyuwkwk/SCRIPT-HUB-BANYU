
-- NYU HUB
-- Foundation v1.0.0

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Source = ReplicatedStorage:WaitForChild("NyuHub")
local Config = require(Source:WaitForChild("config"))
local UI = require(Source:WaitForChild("ui"))

local success, Rayfield = pcall(function()
    return loadstring(
        game:HttpGet("https://sirius.menu/gen2")
    )()
end)

if not success or not Rayfield then
    warn("[NYU HUB] Gagal memuat Rayfield Gen2.")
    return
end

local result = UI.Create(Rayfield, Config)

print("[NYU HUB] Berhasil dimuat:", Config.Version)

return result
