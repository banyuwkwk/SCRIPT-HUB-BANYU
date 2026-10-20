
--[[
    NYU HUB
    Version: 1.0.0
    Module: Foundation
    UI Library: Rayfield Gen2 Stable
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
    warn("[NYU HUB] Gagal memuat Rayfield Gen2.")
    return
end

-- =========================================
-- 2. CONFIGURATION
-- =========================================

local Config = {
    Name = "NYU HUB",
    Subtitle = "Foundation v1.1.0",

    Tabs = {
        Home = "Home",
        Settings = "Settings",
    },
}

-- =========================================
-- 3. CREATE WINDOW
-- =========================================

local Window = Rayfield:CreateWindow({
    name = Config.Name,
    subtitle = Config.Subtitle,
    sidebarLayout = true,
})

-- =========================================
-- 4. HOME TAB
-- =========================================

local HomeTab = Window:CreateTab({
    name = Config.Tabs.Home,
})

-- Button: Notification Test
HomeTab:CreateButton({
    name = "Test Notification",
    description = "Menguji sistem notifikasi NYU HUB",

    callback = function()
        Window:Notify({
            title = "NYU HUB",
            content = "ANJENG KAU",
        })
    end,
})

-- Toggle: State Test
HomeTab:CreateToggle({
    name = "Example Toggle",
    flag = "NyuExampleToggle",
    callback = function(enabled)
        print("[NYU HUB] Toggle:", enabled)
    end,
})

-- Slider: Value Test
HomeTab:CreateSlider({
    name = "Example Slider",
    range = { 1, 100 },
    increment = 1,
    value = 50,

    callback = function(value)
        print("[NYU HUB] Slider Value:", value)
    end,
})

-- =========================================
-- 5. SETTINGS TAB
-- =========================================

local SettingsTab = Window:CreateTab({
    name = Config.Tabs.Settings,
})

SettingsTab:CreateButton({
    name = "Check Version",
    description = "Menampilkan versi NYU HUB",

    callback = function()
        Window:Notify({
            title = Config.Name,
            content = "Version " .. "1.1.0",
        })
    end,
})

-- =========================================
-- 6. INITIALIZATION
-- =========================================

print("[NYU HUB] Foundation loaded successfully.")
