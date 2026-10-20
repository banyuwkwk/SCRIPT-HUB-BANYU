
--[[
    NYU HUB
    Version: 1.1.0
    Module: Foundation + Utility Tools
    UI Library: Rayfield Gen2 Stable

    Sections:
    1. Load Library
    2. Configuration
    3. Create Window
    4. Home Tab
    5. Utilities Tab
    6. Settings Tab
    7. Initialization
]]

-- =========================================
-- 1. LOAD LIBRARY
-- =========================================

local success, Rayfield = pcall(function()
    return loadstring(
        game:HttpGet("https://sirius.menu/gen2")
    )()
end)

if not success or not Rayfield then
    warn("[NYU HUB] Failed to load Rayfield Gen2:", Rayfield)
    return
end

-- =========================================
-- 2. CONFIGURATION
-- =========================================

local Config = {
    Name = "NYU HUB",
    Version = "1.1.0",
    Subtitle = "Utility Tools v1.1.0",

    WalkSpeed = {
        Default = 16,
        Minimum = 16,
        Maximum = 50,
        Increment = 1,
    },

    Tabs = {
        Home = "Home",
        Utilities = "Utilities",
        Settings = "Settings",
    },
}

-- =========================================
-- 3. SERVICES
-- =========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("[NYU HUB] LocalPlayer is unavailable.")
    return
end

-- =========================================
-- 4. CREATE WINDOW
-- =========================================

local Window = Rayfield:CreateWindow({
    name = Config.Name,
    subtitle = Config.Subtitle,
    sidebarLayout = true,
})

-- =========================================
-- 5. HOME TAB
-- =========================================

local HomeTab = Window:CreateTab({
    name = Config.Tabs.Home,
})

-- 5.1 Notification Test

HomeTab:CreateButton({
    name = "Test Notification",
    description = "Test the NYU HUB notification system",

    callback = function()
        Window:Notify({
            title = Config.Name,
            content = "Foundation berhasil merespons!",
        })
    end,
})

-- 5.2 Example Toggle

HomeTab:CreateToggle({
    name = "Example Toggle",
    flag = "NyuExampleToggle",

    callback = function(enabled)
        print("[NYU HUB] Example Toggle:", enabled)
    end,
})

-- 5.3 Example Slider

HomeTab:CreateSlider({
    name = "Example Slider",
    range = { 1, 100 },
    increment = 1,
    value = 50,

    callback = function(value)
        print("[NYU HUB] Example Slider:", value)
    end,
})

-- =========================================
-- 6. UTILITIES TAB
-- =========================================

local UtilitiesTab = Window:CreateTab({
    name = Config.Tabs.Utilities,
})

-- 6.1 Utility Test

UtilitiesTab:CreateButton({
    name = "Test Utilities",
    description = "Test the Utilities tab",

    callback = function()
        Window:Notify({
            title = Config.Name,
            content = "Utilities tab berfungsi!",
        })
    end,
})

-- 6.2 Walk Speed

UtilitiesTab:CreateSlider({
    name = "Walk Speed",
    range = {
        Config.WalkSpeed.Minimum,
        Config.WalkSpeed.Maximum,
    },
    increment = Config.WalkSpeed.Increment,
    value = Config.WalkSpeed.Default,

    callback = function(value)
        local character = LocalPlayer.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")

        if not humanoid then
            warn("[NYU HUB] Humanoid tidak ditemukan.")
            return
        end

        humanoid.WalkSpeed = value

        print("[NYU HUB] Walk Speed:", value)
    end,
})

-- 6.3 Reset Walk Speed

UtilitiesTab:CreateButton({
    name = "Reset Walk Speed",
    description = "Reset Walk Speed to the default value",

    callback = function()
        local character = LocalPlayer.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")

        if not humanoid then
            warn("[NYU HUB] Humanoid tidak ditemukan.")
            return
        end

        humanoid.WalkSpeed = Config.WalkSpeed.Default

        Window:Notify({
            title = Config.Name,
            content = "Walk Speed direset ke 16.",
        })

        print(
            "[NYU HUB] Walk Speed reset:",
            Config.WalkSpeed.Default
        )
    end,
})

-- =========================================
-- 7. SETTINGS TAB
-- =========================================

local SettingsTab = Window:CreateTab({
    name = Config.Tabs.Settings,
})

-- 7.1 Version Information

SettingsTab:CreateButton({
    name = "Check Version",
    description = "Display the current NYU HUB version",

    callback = function()
        Window:Notify({
            title = Config.Name,
            content = "Version " .. Config.Version,
        })
    end,
})

-- =========================================
-- 8. INITIALIZATION
-- =========================================

print(
    "[NYU HUB] Version "
    .. Config.Version
    .. " loaded successfully."
)
