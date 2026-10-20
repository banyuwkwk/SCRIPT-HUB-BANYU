
local UI = {}

function UI.Create(Rayfield, Config)
    local Window = Rayfield:CreateWindow({
        name = Config.Name,
        subtitle = Config.Subtitle .. " v" .. Config.Version,
        sidebarLayout = true,
    })

    local HomeTab = Window:CreateTab({
        name = Config.Tabs.Home,
    })

    local SettingsTab = Window:CreateTab({
        name = Config.Tabs.Settings,
    })

    local State = {
        ExampleToggle = false,
        ExampleSlider = 50,
    }

    HomeTab:CreateButton({
        name = "Test Notification",
        description = "Menguji notifikasi NYU HUB",

        callback = function()
            Window:Notify({
                title = Config.Name,
                content = "Foundation berhasil merespons!",
            })
        end,
    })

    HomeTab:CreateToggle({
        name = "Example Toggle",
        flag = "NyuExampleToggle",
        value = State.ExampleToggle,

        callback = function(enabled)
            State.ExampleToggle = enabled
            print("[NYU HUB] Toggle:", enabled)
        end,
    })

    HomeTab:CreateSlider({
        name = "Example Slider",
        range = { 1, 100 },
        increment = 1,
        value = State.ExampleSlider,

        callback = function(value)
            State.ExampleSlider = value
            print("[NYU HUB] Slider:", value)
        end,
    })

    SettingsTab:CreateButton({
        name = "Check Version",
        description = "Menampilkan versi hub",

        callback = function()
            Window:Notify({
                title = Config.Name,
                content = "Version " .. Config.Version,
            })
        end,
    })

    return {
        Window = Window,
        State = State,
    }
end

return UI
