local UniversalTab = _G.Window:MakeTab({
    Name = "Universal Mods",
    Icon = nil, -- Mengubah ikon menjadi nil agar tidak eror
    PremiumOnly = false
})

-- Slider Kecepatan Jalan
UniversalTab:AddSlider({
    Name = "WalkSpeed (Kecepatan)",
    Min = 16, Max = 150, Default = 16,
    Increment = 1, ValueName = "Speed",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end    
})

-- Slider Tinggi Lompatan
UniversalTab:AddSlider({
    Name = "JumpPower (Lompatan)",
    Min = 50, Max = 250, Default = 50,
    Increment = 1, ValueName = "Power",
    Callback = function(Value)
        local humanoid = game.Players.LocalPlayer.Character.Humanoid
        humanoid.UseJumpPower = true
        humanoid.JumpPower = Value
    end    
})

print("Skrip Universal Berhasil Dimuat!")
