local RintamaTab = _G.Window:MakeTab({
    Name = "Rintama Cheats",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ====================================================================
-- SEKSI 1: COMBAT & MOVEMENT MODS
-- ====================================================================

-- Fitur Anti-Ragdoll (Mencegah karakter jatuh pingsan/kaku saat dipukul musuh)
local AntiRagdollEnabled = false
RintamaTab:AddToggle({
    Name = "Anti-Ragdoll (Bisa Tetap Gerak)",
    Default = false,
    Callback = function(Value)
        AntiRagdollEnabled = Value
        task.spawn(function()
            while AntiRagdollEnabled do
                task.wait(0.1)
                local character = game.Players.LocalPlayer.Character
                if character then
                    -- Menghapus efek status ragdoll secara paksa dari karakter
                    local ragdoll = character:FindFirstChild("Ragdoll") or character:FindFirstChild("RagdollScript")
                    if ragdoll then
                        ragdoll:Destroy()
                    end
                end
            end
        end)
    end
})

-- Fitur Infinite Stamina (Berguna untuk sprint & combo tanpa lelah)
local InfStaminaEnabled = false
RintamaTab:AddToggle({
    Name = "Infinite Stamina",
    Default = false,
    Callback = function(Value)
        InfStaminaEnabled = Value
        task.spawn(function()
            while InfStaminaEnabled do
                task.wait(0.1)
                -- Mencari folder stats/stamina di dalam player atau karakter (tergantung arsitektur game)
                local myStamina = game.Players.LocalPlayer:FindFirstChild("Stamina") or (game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Stamina"))
                if myStamina and myStamina:IsA("NumberValue") then
                    myStamina.Value = 100 -- Mengunci stamina di angka penuh
                end
            end
        end)
    end
})

-- ====================================================================
-- SEKSI 2: UTILITIES & VISUALS
-- ====================================================================

-- Tombol Teleport Instant ke Area Penting (Sekolah & Konbini/7-Eleven)
RintamaTab:AddButton({
    Name = "Teleport ke Sekolah (Rintama High)",
    Callback = function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Koordinat perkiraan area depan sekolah Rintama
            character.HumanoidRootPart.CFrame = CFrame.new(120, 15, -340) 
            OrionLib:MakeNotification({
                Name = "Teleport Sukses",
                Content = "Kamu telah berpindah ke sekolah.",
                Time = 3
            })
        end
    end
})

RintamaTab:AddButton({
    Name = "Teleport ke 7-Eleven (Konbini)",
    Callback = function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Koordinat perkiraan area minimarket konbini
            character.HumanoidRootPart.CFrame = CFrame.new(-45, 12, 180)
            OrionLib:MakeNotification({
                Name = "Teleport Sukses",
                Content = "Kamu telah berpindah ke Toko Kelontong.",
                Time = 3
            })
        end
    end
})

-- Pemberitahuan sistem bahwa skrip khusus game ini berhasil ditarik dari GitHub
OrionLib:MakeNotification({
    Name = "Rintama High Loaded",
    Content = "Fitur khusus Rintama High berhasil dimuat!",
    Image = "rbxassetid://4483345998",
    Time = 5
})
