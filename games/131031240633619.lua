local RintamaTab = _G.Window:MakeTab({
    Name = "Rintama Cheats",
    Icon = nil, -- Diubah ke nil agar aman dari blokir asset
    PremiumOnly = false
})

-- ====================================================================
-- SEKSI 1: COMBAT & MOVEMENT
-- ====================================================================

-- Fitur Anti-Ragdoll
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
                    local ragdoll = character:FindFirstChild("Ragdoll") or character:FindFirstChild("RagdollScript")
                    if ragdoll then
                        ragdoll:Destroy()
                    end
                end
            end
        end)
    end
})

-- Fitur Stamina Tidak Terbatas
local InfStaminaEnabled = false
RintamaTab:AddToggle({
    Name = "Infinite Stamina",
    Default = false,
    Callback = function(Value)
        InfStaminaEnabled = Value
        task.spawn(function()
            while InfStaminaEnabled do
                task.wait(0.1)
                local myStamina = game.Players.LocalPlayer:FindFirstChild("Stamina") or (game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Stamina"))
                if myStamina and myStamina:IsA("NumberValue") then
                    myStamina.Value = 100
                end
            end
        end)
    end
})

-- ====================================================================
-- SEKSI 2: TELEPORTATION (UTILITIES)
-- ====================================================================

RintamaTab:AddButton({
    Name = "Teleport ke Sekolah (Rintama High)",
    Callback = function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(120, 15, -340) 
            OrionLib:MakeNotification({
                Name = "Teleport Sukses", Content = "Kamu telah sampai di sekolah.", Time = 3
            })
        end
    end
})

RintamaTab:AddButton({
    Name = "Teleport ke 7-Eleven (Konbini)",
    Callback = function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(-45, 12, 180)
            OrionLib:MakeNotification({
                Name = "Teleport Sukses", Content = "Kamu telah sampai di Toko Kelontong.", Time = 3
            })
        end
    end
})

-- Tombol membersihkan GUI secara aman
RintamaTab:AddButton({
    Name = "Hancurkan / Tutup Script Hub",
    Callback = function()
        getgenv().MyScriptHubLoaded = false
        OrionLib:Destroy()
    end
})
