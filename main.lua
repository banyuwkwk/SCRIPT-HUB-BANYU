-- 1. Anti Multi-Load (Mencegah menu menumpuk jika dijalankan berulang kali)
if getgenv().MyScriptHubLoaded then 
    print("Script Hub sudah aktif!")
    return 
end
getgenv().MyScriptHubLoaded = true

-- 2. Memuat UI Library (Orion Library Resmi via tautan repositori terbaru Anda)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/OrionLibrary/Orion/refs/heads/main/source.lua')))()

-- 3. Membuat Window Utama GUI
_G.Window = OrionLib:MakeWindow({
    Name = "Rintama Multi-Hub V1", 
    HidePremium = true, 
    SaveConfig = false
})

-- 4. Alamat Base Repositori GitHub Anda (SUDAH DIPERBAIKI: Mengarah ke folder utama, bukan file lua)
local BaseURL = "https://raw.githubusercontent.com/banyuwkwk/SCRIPT-HUB-BANYU/refs/heads/main/"

-- 5. Memuat Skrip Universal (Fitur umum yang selalu muncul di semua game)
pcall(function()
    loadstring(game:HttpGet(BaseURL .. "games/universal.lua"))()
end)

-- 6. Deteksi Otomatis ID Game (Place ID)
local PlaceId = game.PlaceId
local GameScriptURL = BaseURL .. "games/" .. tostring(PlaceId) .. ".lua"

-- 7. Eksekusi Skrip Khusus Game Jika Tersedia
local sukses, err = pcall(function()
    loadstring(game:HttpGet(GameScriptURL))()
end)

if not sukses then
    print("Tidak ada skrip khusus untuk Game ID: " .. tostring(PlaceId) .. ". Berjalan dalam mode universal.")
end

-- 8. Menjalankan Inisialisasi Akhir GUI
OrionLib:Init()
