
--[[
    NYU HUB
    Version: 1.0.0
    Module: Foundation + Utility Tools
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
    warn("[NYU HUB] Gagal memuat Rayfield Gen2:", Rayfield)
    return
end

-- =========================================
-- 2. CONFIGURATION
-- =========================================

local Config = {
    Name = "NYU HUB",
    Subtitle = "Foundation v1.0.0",

    Tabs = {
        Home = "Home",
        Settings = "Settings",
        Utilities = "Utilities",
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
-- 4. HOME TAB (FOUNDATION)
-- =========================================

local HomeTab = Window:CreateTab({
    name = Config.Tabs.Home,
})

HomeTab:CreateButton({
    name = "Test Notification",
    description = "Menguji sistem notifikasi NYU HUB",

    callback = function()
        Window:Notify({
            title = "NYU HUB",
            content = "Foundation berhasil merespons!",
        })
    end,
})

HomeTab:CreateToggle({
    name = "Example Toggle",
    flag = "NyuExampleToggle",

    callback = function(enabled)
        print("[NYU HUB] Toggle:", enabled)
    end,
})

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
-- 5. SETTINGS TAB (FOUNDATION)
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
            content = "Version 1.0.0",
        })
    end,
})

-- =========================================
-- 6. UTILITY TOOLS
-- =========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UtilitiesTab = Window:CreateTab({
    name = Config.Tabs.Utilities,
})

-- -----------------------------------------
-- 6.1 PLAYER INFORMATION
-- -----------------------------------------

local function GetPlayerInformation()
    return {
        Username = LocalPlayer.Name,
        DisplayName = LocalPlayer.DisplayName,
        UserId = tostring(LocalPlayer.UserId),
    }
end

local PlayerInfo = GetPlayerInformation()

UtilitiesTab:CreateParagraph({
    name = "Player Information",
    content =
        "Username: " .. PlayerInfo.Username
        .. "\nDisplay Name: " .. PlayerInfo.DisplayName
        .. "\nUser ID: " .. PlayerInfo.UserId,
})

-- -----------------------------------------
-- 6.2 REFRESH PLAYER INFORMATION
-- -----------------------------------------

UtilitiesTab:CreateButton({
    name = "Refresh Information",
    description = "Memperbarui informasi pemain",

    callback = function()
        local Info = GetPlayerInformation()

        Window:Notify({
            title = "Player Information",
            content =
                "Username: " .. Info.Username
                .. "\nUser ID: " .. Info.UserId,
        })

        print("[NYU HUB] Player information refreshed.")
        print("Username:", Info.Username)
        print("Display Name:", Info.DisplayName)
        print("User ID:", Info.UserId)
    end,
})

-- -----------------------------------------
-- 6.3 COPY USERNAME
-- -----------------------------------------

UtilitiesTab:CreateButton({
    name = "Copy Username",
    description = "Menyalin username ke clipboard",

    callback = function()
        local ClipboardFunction =
            (type(clipboard) == "function" and clipboard)
            or (type(setclipboard) == "function" and setclipboard)

        if not ClipboardFunction then
            Window:Notify({
                title = "Clipboard Unavailable",
                content = "Fitur clipboard tidak tersedia di lingkungan ini.",
            })

            warn("[NYU HUB] Clipboard API tidak tersedia.")
            return
        end

        local CopySuccess, CopyError = pcall(function()
            ClipboardFunction(LocalPlayer.Name)
        end)

        if CopySuccess then
            Window:Notify({
                title = "NYU HUB",
                content = "Username berhasil disalin.",
            })

            print("[NYU HUB] Username copied.")
        else
            warn("[NYU HUB] Gagal menyalin username:", CopyError)

            Window:Notify({
                title = "Copy Failed",
                content = "Clipboard gagal menyalin username.",
            })
        end
    end,
})

-- -----------------------------------------
-- 6.4 SESSION CLOCK
-- -----------------------------------------

UtilitiesTab:CreateButton({
    name = "Show Current Time",
    description = "Menampilkan waktu lokal perangkat",

    callback = function()
        local CurrentTime = os.date("%H:%M:%S")

        Window:Notify({
            title = "Current Time",
            content = CurrentTime,
        })

        print("[NYU HUB] Current time:", CurrentTime)
    end,
})

-- =========================================
-- 7. INITIALIZATION
-- =========================================

print("[NYU HUB] Foundation + Utility Tools loaded successfully.")
