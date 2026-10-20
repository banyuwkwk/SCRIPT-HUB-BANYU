-- 1. Anti Multi-Load (Membersihkan status agar bisa dijalankan ulang di server yang sama)
getgenv().MyScriptHubLoaded = nil 
task.wait(0.1)
getgenv().MyScriptHubLoaded = true

print("[SYSTEM] Memulai pemuatan Script Hub...")

-- 2. Memuat UI Library (Menggunakan Tautan Utama & Cadangan jika tautan pertama gagal)
local OrionLib
local suksesUI, errUI = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
end)

-- Jika tautan utama gagal, gunakan tautan cermin alternatif (Mobile/Universal Fix)
if not suksesUI or not OrionLib then
    warn("[WARNING] Tautan utama Orion gagal, mencoba menggunakan server cadangan...")
    local suksesCadangan, errCadangan = pcall(function()
        OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Seven7-lua/Roblox/refs/heads/main/Librarys/Orion/Orion.lua'))()
    end)
    
    if not suksesCadangan or not OrionLib then
        error("[CRITICAL ERROR] Gagal total memuat Orion Library! Eksekutor Anda memblokir unduhan UI. Pesan eror: " .. tostring(errCadangan))
        return
    end
end

print("[SYSTEM] Orion UI Library Berhasil Terpasang!")

-- 3. Membuat Window Utama GUI
local Window = OrionLib:MakeWindow({
    Name = "Rintama Multi-Hub V1", 
    HidePremium = true, 
    SaveConfig = false,
    IntroEnabled = false -- Mematikan animasi intro agar memuat lebih cepat & tidak macet
})

-- 4. Alamat Base Repositori GitHub Anda (Sudah benar untuk folder utama)
local BaseURL = "https://githubusercontent.com"

-- 5. Memuat Skrip Universal 
local suksesUni, errUni = pcall(function()
    loadstring(game:HttpGet(BaseURL .. "games/universal.lua"))()
end)
if not suksesUni then
    warn("[ERROR] File universal.lua gagal diunduh dari GitHub Anda: " .. tostring(errUni))
end

-- 6. Deteksi Otomatis ID Game dan Eksekusi Modul Game
local PlaceId = game.PlaceId
local GameScriptURL = BaseURL .. "games/" .. tostring(PlaceId) .. ".lua"

local suksesGame, errGame = pcall(function()
    loadstring(game:HttpGet(GameScriptURL))()
end)

if not suksesGame then
    warn("[INFO] Tidak ada skrip khusus untuk Game ID: " .. tostring(PlaceId) .. " atau file .lua Anda di folder games salah nama.")
end

-- 7. Menjalankan Inisialisasi Akhir GUI
OrionLib:Init()
print("[SYSTEM] Script Hub Selesai Diinisialisasi!")
