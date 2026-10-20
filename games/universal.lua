local UniversalTab = _G.Window:MakeTab({
    Name = "Universal Mods",
    Icon = "rbxassetid://4483345998"
})

UniversalTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16, Max = 150, Default = 16,
    Increment = 1, ValueName = "Speed",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end    
})

print("Skrip Universal Berhasil Dimuat!")
