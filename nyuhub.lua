--[[
    NYU HUB
    Version: 1.1.1
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
    Version = "1.1.1",
    Subtitle = "Utility Tools v1.1.1",

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
    range = {1, 100},
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

-- =========================================
-- 6.2 AUTO FARM TOFU (Fujiwara Bunta) & DIAGNOSTICS
-- =========================================

local AutoFarmEnabled = false
local CurrentFarmState = "IDLE"
local FarmThread = nil
local LastDeliveredTarget = nil  -- BUG2: lacak NPC terakhir yang dideliver

local BUNTA_POSITION = Vector3.new(-144.784, -11.521, 665.749)
local BUNTA_NAME = "Fujiwara Bunta"

-- Status Display pada UI (Didukung penuh oleh Rayfield Gen2 Stable)
local StatusComponent = nil

pcall(function()
    if UtilitiesTab.CreateText then
        StatusComponent = UtilitiesTab:CreateText({
            name = "Auto Farm Status",
            text = "IDLE - Siap digunakan",
})
    elseif UtilitiesTab.CreateDivider then
        StatusComponent = UtilitiesTab:CreateDivider({
            text = "Status: IDLE",
})
    end
end)

local function UpdateStatus(state, detail, target)
    CurrentFarmState = state
    local targetText = target or "-"
    local detailText = detail or ""
    local summary = string.format("[%s] %s | Target: %s", state, detailText, targetText)

    if StatusComponent then
        pcall(function()
            if StatusComponent.SetTitle and StatusComponent.Set then
                StatusComponent:SetTitle("Status: " .. state)
                StatusComponent:Set(string.format("Target: %s | Detail: %s", targetText, detailText))
            elseif StatusComponent.Set then
                StatusComponent:Set(summary)
            end
        end)
    end
    print(string.format("[NYU HUB] [%s] %s (Target: %s)", state, detailText, targetText))
end

-- ====================================================
-- KARAKTER & VERIFIKASI KEBERADAAN ROOT PART
-- ====================================================

local function WaitForCharacterReady(timeout)
    timeout = timeout or 6
    local start = tick()
    while tick() - start < timeout do
        if not AutoFarmEnabled then return nil, nil, nil end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                return char, root, hum
            end
        end
        task.wait(0.2)
    end
    return nil, nil, nil
end

local function GetRootPart()
    local char, root = WaitForCharacterReady(3)
    return root
end

-- ====================================================
-- TELEPORT & VERIFIKASI KEDATANGAN TERPISAH (BUG 2)
-- ====================================================

local function TeleportTo(targetPos)
    local char, root, hum = WaitForCharacterReady(5)
    if not char or not root or not hum or hum.Health <= 0 then
        warn("[NYU HUB TELEPORT] Karakter tidak tersedia atau sedang respawn.")
        return false, "CharacterNotReady"
    end

    local targetV3 = typeof(targetPos) == "CFrame" and targetPos.Position or targetPos
    local targetCF = typeof(targetPos) == "CFrame" and targetPos or CFrame.new(targetPos)
    local initDist = (root.Position - targetV3).Magnitude

    print(string.format("[NYU HUB TELEPORT] Memulai navigasi ke target (%.1f, %.1f, %.1f) | Jarak awal: %.2f studs",
        targetV3.X, targetV3.Y, targetV3.Z, initDist))

    -- Nolkan kecepatan physics sebelum pivot agar karakter tidak meluncur
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)

    char:PivotTo(targetCF)
    return true, targetV3
end

local function VerifyArrival(targetPos, maxWaitSeconds, toleranceStuds)
    maxWaitSeconds = maxWaitSeconds or 6
    toleranceStuds = toleranceStuds or 8

    local targetV3 = typeof(targetPos) == "CFrame" and targetPos.Position or targetPos
    local targetCF = typeof(targetPos) == "CFrame" and targetPos or CFrame.new(targetPos)

    local elapsed = 0
    local consecutiveStable = 0
    local requiredStable = 3
    local lastDist = 999

    while elapsed < maxWaitSeconds and AutoFarmEnabled do
        task.wait(0.2)
        elapsed = elapsed + 0.2

        local char, root, hum = WaitForCharacterReady(1)
        if char and root and hum and hum.Health > 0 then
            local dist = (root.Position - targetV3).Magnitude
            local vel = root.AssemblyLinearVelocity.Magnitude
            lastDist = dist

            print(string.format("[NYU HUB TELEPORT] Verifikasi kedatangan: Jarak = %.2f studs (toleransi %.1f), Kecepatan = %.2f studs/s [Stabil: %d/%d]",
                dist, toleranceStuds, vel, consecutiveStable, requiredStable))

            -- Syarat kedatangan: jarak dalam batas toleransi dan kecepatan fisik berhenti/sangat rendah
            if dist <= toleranceStuds and vel < 3.0 then
                consecutiveStable = consecutiveStable + 1
                if consecutiveStable >= requiredStable then
                    pcall(function()
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero
                    end)
                    print(string.format("[NYU HUB TELEPORT] KEDATANGAN TERVERIFIKASI: Posisi stabil pada jarak %.2f studs dari target (%d checks stabil).", dist, consecutiveStable))
                    return true, "Arrived", dist
                end
            else
                consecutiveStable = 0
                -- Re-pivot jika terjadi rubberband setelah jeda awal
                if elapsed > 1.2 and dist > toleranceStuds then
                    pcall(function()
                        root.AssemblyLinearVelocity = Vector3.zero
                    end)
                    char:PivotTo(targetCF)
                end
            end
        else
            warn("[NYU HUB TELEPORT] Karakter tidak valid selama verifikasi posisi.")
            consecutiveStable = 0
        end
    end

    warn(string.format("[NYU HUB TELEPORT] Timeout verifikasi kedatangan dalam %.1fs (Jarak akhir: %.1f studs, toleransi: %.1f).", maxWaitSeconds, lastDist, toleranceStuds))
    return false, "Timeout", lastDist
end

local function TeleportAndVerifyArrival(targetPos, maxWaitSeconds, toleranceStuds)
    local ok, reason = TeleportTo(targetPos)
    if not ok then
        return false, reason, 999
    end
    return VerifyArrival(targetPos, maxWaitSeconds, toleranceStuds)
end

local function FindNPCModel(npcName)
    if not npcName or #npcName == 0 then return nil end
    local workspace = game:GetService("Workspace")
    local npcFolder = workspace:FindFirstChild("NPCs")
    if npcFolder then
        local direct = npcFolder:FindFirstChild(npcName)
        if direct then return direct end
        for _, child in ipairs(npcFolder:GetChildren()) do
            if child.Name:lower() == npcName:lower() or child.Name:lower():find(npcName:lower(), 1, true) then
                return child
            end
        end
    end
    local directWs = workspace:FindFirstChild(npcName)
    if directWs then return directWs end
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and (child.Name:lower() == npcName:lower() or child.Name:lower():find(npcName:lower(), 1, true)) then
            return child
        end
    end
    return nil
end

local function ClickGuiButton(btn)
    if not btn or not btn:IsA("GuiButton") then return false end

    local clicked = false

    -- Metode 1: firesignal
    if firesignal then
        pcall(function()
            firesignal(btn.MouseButton1Click)
            clicked = true
        end)
        pcall(function()
            firesignal(btn.Activated)
            clicked = true
        end)
    end

    -- Metode 2: getconnections
    if getconnections then
        pcall(function()
            for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                conn:Fire()
                clicked = true
            end
            for _, conn in ipairs(getconnections(btn.Activated)) do
                conn:Fire()
                clicked = true
            end
        end)
    end

    -- Metode 3: VirtualInputManager (simulasi klik mouse langsung pada koordinat tombol)
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        local absPos = btn.AbsolutePosition
        local absSize = btn.AbsoluteSize
        local centerX = absPos.X + absSize.X / 2
        local centerY = absPos.Y + absSize.Y / 2
        vim:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
        task.wait(0.05)
        vim:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
        clicked = true
    end)

    return clicked
end

-- ====================================================
-- INTERAKSI NPC FUJIWARA BUNTA (TERISOLASI & TERUKUR)
-- ====================================================

local function TriggerBuntaInteraction(buntaModel)
    if not buntaModel then return false, "NoModel" end

    local char, root, hum = WaitForCharacterReady(2)
    if not root then return false, "NoRoot" end

    local buntaPart = buntaModel:FindFirstChild("HumanoidRootPart")
        or buntaModel.PrimaryPart
        or buntaModel:FindFirstChild("Head")
        or buntaModel:FindFirstChildWhichIsA("BasePart")

    if not buntaPart then return false, "NoBuntaPart" end

    -- Pastikan karakter benar-benar dekat (< 20 studs) sebelum interaksi dijalankan
    local dist = (root.Position - buntaPart.Position).Magnitude
    if dist > 20 then
        warn(string.format("[NYU HUB INTERACT] Jarak karakter ke Bunta terlalu jauh (%.1f studs, toleransi 20 studs). Interaksi ditolak.", dist))
        return false, "TooFar"
    end

    print(string.format("[NYU HUB INTERACT] Menjalankan mekanisme interaksi ke '%s' (Jarak aktual: %.2f studs)...", buntaModel.Name, dist))

    local triggeredPrompt = false
    local triggeredClick = false
    local triggeredMouseSim = false
    local triggeredKey = false

    -- 1. ProximityPrompt di dalam model Bunta
    local prompt = buntaModel:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and fireproximityprompt then
        pcall(function()
            local origHold = prompt.HoldDuration
            local origDist = prompt.MaxActivationDistance
            local origLos = prompt.RequiresLineOfSight
            prompt.HoldDuration = 0
            prompt.MaxActivationDistance = 50
            prompt.RequiresLineOfSight = false
            fireproximityprompt(prompt)
            prompt.HoldDuration = origHold
            prompt.MaxActivationDistance = origDist
            prompt.RequiresLineOfSight = origLos
            triggeredPrompt = true
        end)
    end

    -- 2. ClickDetector di dalam model Bunta
    for _, desc in ipairs(buntaModel:GetDescendants()) do
        if desc:IsA("ClickDetector") and fireclickdetector then
            pcall(function()
                local origDist = desc.MaxActivationDistance
                desc.MaxActivationDistance = 50
                fireclickdetector(desc, 1)
                desc.MaxActivationDistance = origDist
                triggeredClick = true
            end)
        end
    end

    -- 3. Hadapkan kamera langsung ke Bunta dan lakukan simulasi klik mouse
    pcall(function()
        local camera = workspace.CurrentCamera
        if camera and buntaPart then
            camera.CFrame = CFrame.new(camera.CFrame.Position, buntaPart.Position)
            local screenPos, onScreen = camera:WorldToViewportPoint(buntaPart.Position)
            if onScreen then
                local vim = game:GetService("VirtualInputManager")
                vim:SendMouseMoveEvent(screenPos.X, screenPos.Y, game)
                task.wait(0.04)
                vim:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 1)
                task.wait(0.06)
                vim:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 1)
                triggeredMouseSim = true
            end
        end
    end)

    -- 4. KeyCode E interaksi keyboard
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        triggeredKey = true
    end)

    print(string.format("[NYU HUB INTERACT] Sinyal interaksi dikirim (Prompt: %s, ClickDetector: %s, MouseSim: %s, KeyE: %s).",
        tostring(triggeredPrompt), tostring(triggeredClick), tostring(triggeredMouseSim), tostring(triggeredKey)))
    return true, "Success"
end

-- ====================================================
-- DIALOGUE INSPECTOR & GENUINE VISIBILITY CHECK
-- ====================================================

-- Memeriksa apakah elemen GUI benar-benar terlihat di layar (bukan frame tersembunyi/dormant)
local function IsGuiObjectTrulyVisible(guiObj)
    if not guiObj or not guiObj:IsA("GuiObject") then return false end
    if not guiObj.Visible then return false end
    if guiObj.AbsoluteSize.X <= 10 or guiObj.AbsoluteSize.Y <= 10 then return false end

    -- Cek TextTransparency untuk elemen teks
    if guiObj:IsA("TextLabel") or guiObj:IsA("TextButton") then
        if guiObj.TextTransparency >= 0.9 then return false end
        if #guiObj.Text == 0 then return false end
    end

    -- Cek CanvasGroup GroupTransparency jika elemen sendiri adalah CanvasGroup
    if guiObj:IsA("CanvasGroup") and guiObj.GroupTransparency >= 0.9 then
        return false
    end

    -- Cek posisi di layar (viewport) agar frame yang di-tween ke luar layar tidak terdeteksi aktif
    local camera = workspace.CurrentCamera
    if camera then
        local vpSize = camera.ViewportSize
        local pos = guiObj.AbsolutePosition
        local size = guiObj.AbsoluteSize
        if pos.X + size.X <= 0 or pos.Y + size.Y <= 0 or pos.X >= vpSize.X or pos.Y >= vpSize.Y then
            return false
        end
    end

    -- Periksa seluruh ancestor hingga ScreenGui
    local current = guiObj.Parent
    while current and not current:IsA("ScreenGui") and not current:IsA("Workspace") do
        if current:IsA("GuiObject") then
            if not current.Visible then return false end
            if current.AbsoluteSize.X <= 0 or current.AbsoluteSize.Y <= 0 then return false end
            if current:IsA("CanvasGroup") and current.GroupTransparency >= 0.9 then return false end
        end
        current = current.Parent
    end

    if current and current:IsA("ScreenGui") then
        return current.Enabled
    end

    return true
end

-- ====================================================
-- BUG1 FIX: AUTO-SKIP DIALOG NARATIF
-- Mencari semua clickable element dalam dialog container
-- yang bukan pilihan job/konfirmasi, lalu menekannya
-- untuk melanjutkan narasi secara otomatis.
-- ====================================================

-- Cek apakah sebuah tombol adalah pilihan penting yang TIDAK boleh di-skip
local function IsImportantDialogChoice(btnText)
    if not btnText then return false end
    local lower = btnText:lower()
    return lower:find("job for me", 1, true)
        or lower:find("for sale", 1, true)
        or lower:find("take it", 1, true)
        or lower:find("nevermind", 1, true)
end

-- Kalimat signature percakapan spesifik Bunta (tidak menggunakan kata tunggal umum)
local BUNTA_CONVERSATION_SIGNATURES = {
    "do you have a job for me",
    "what do you got for sale",
    "sure, i'll take it",
    "actually nevermind",
    "welcome to fujiwara tofu shop",
    "are you sure you want to",
    "good to know, now go out there",
    "break the tofu",
}

-- Mencari container ScreenGui/Frame spesifik dialog Fujiwara Bunta
local function FindBuntaDialogueContainer()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil, nil end

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local gName = gui.Name:lower()
            -- Abaikan GUI Rayfield dan NYU HUB
            if not gName:find("rayfield") and not gName:find("nyu") then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and IsGuiObjectTrulyVisible(desc) then
                        local text = desc.Text:lower()
                        for _, sig in ipairs(BUNTA_CONVERSATION_SIGNATURES) do
                            if text:find(sig, 1, true) then
                                -- Container ditemukan! Cari Frame pembungkus teratas di bawah ScreenGui
                                local topFrame = desc
                                while topFrame.Parent and topFrame.Parent ~= gui and topFrame.Parent:IsA("GuiObject") do
                                    topFrame = topFrame.Parent
                                end
                                return topFrame, gui
                            end
                        end
                    end
                end
            end
        end
    end

    return nil, nil
end

-- Inspeksi state dialog Bunta secara akurat dan terisolasi
local function InspectBuntaDialogue()
    local container, screenGui = FindBuntaDialogueContainer()
    if not container then
        return {
            isOpen = false,
            container = nil,
            gui = nil,
            narration = "",
            optionJob = nil,
            optionSale = nil,
            optionTakeIt = nil,
            optionNevermind = nil,
            advanceBtn = nil,
            isJobAcceptedNarration = false,
        }
    end

    local narrationList = {
}
    local buttons = {
}
    local optJob = nil
    local optSale = nil
    local optTakeIt = nil
    local optNevermind = nil
    local advanceBtn = nil

    for _, desc in ipairs(container:GetDescendants()) do
        if desc:IsA("TextLabel") and IsGuiObjectTrulyVisible(desc) and #desc.Text > 0 then
            local clean = desc.Text:gsub("%s+", " "):match("^%s*(.-)%s*$")
            if clean and #clean > 0 then
                table.insert(narrationList, clean)
            end
        elseif desc:IsA("GuiButton") and IsGuiObjectTrulyVisible(desc) then
            local btnText = ""
            if desc:IsA("TextButton") and #desc.Text > 0 then
                btnText = desc.Text
            else
                for _, sub in ipairs(desc:GetDescendants()) do
                    if sub:IsA("TextLabel") and IsGuiObjectTrulyVisible(sub) and #sub.Text > 0 then
                        btnText = sub.Text
                        break
                    end
                end
            end
            local clean = btnText:gsub("%s+", " "):match("^%s*(.-)%s*$") or ""
            local lower = clean:lower()
            local lowerName = desc.Name:lower()

            local btnInfo = {
                instance = desc,
                name = desc.Name,
                text = clean,
}
            table.insert(buttons, btnInfo)

            -- Klasifikasi tombol secara eksplisit
            if lower:find("job for me", 1, true) then
                optJob = btnInfo
            elseif lower:find("for sale", 1, true) then
                optSale = btnInfo
            elseif lower:find("take it", 1, true) then
                optTakeIt = btnInfo
            elseif lower:find("nevermind", 1, true) then
                optNevermind = btnInfo
            elseif lower:find("skip", 1, true)
                or lower:find("continue", 1, true)
                or lower:find("next", 1, true)
                or lower:find("lanjut", 1, true)
                or lower:find("lewati", 1, true)
                or lower:find("ok", 1, true)
                or lower:find("close", 1, true)
                or lowerName:find("skip", 1, true)
                or lowerName:find("continue", 1, true)
                or lowerName:find("next", 1, true)
                or lowerName:find("close", 1, true) then
                advanceBtn = btnInfo
            end
        end
    end

    local fullNarration = table.concat(narrationList, " | ")
    local lowerNarration = fullNarration:lower()

    local isAcceptedNarration = lowerNarration:find("good to know", 1, true)
        or lowerNarration:find("break the tofu", 1, true)

    -- Dialog dianggap terbuka hanya jika ada tombol interaktif atau narasi yang benar-benar aktif di layar
    local genuinelyOpen = (#buttons > 0 or #narrationList > 0) and (
        optJob ~= nil or optTakeIt ~= nil or optSale ~= nil or optNevermind ~= nil or advanceBtn ~= nil or isAcceptedNarration or #narrationList > 0
    )

    return {
        isOpen = genuinelyOpen,
        container = container,
        gui = screenGui,
        narration = fullNarration,
        buttons = buttons,
        optionJob = optJob,
        optionSale = optSale,
        optionTakeIt = optTakeIt,
        optionNevermind = optNevermind,
        advanceBtn = advanceBtn,
        isJobAcceptedNarration = isAcceptedNarration,
}
end

-- Cari elemen clickable generik di dalam dialog container untuk auto-advance
-- Ini mencari: GuiButton tanpa teks penting, Frame/ImageLabel besar,
-- atau TextButton dengan teks naratif
local function FindDialogAdvanceTarget(container)
    if not container then return nil end

    local candidates = {}

    for _, desc in ipairs(container:GetDescendants()) do
        if desc:IsA("GuiButton") and IsGuiObjectTrulyVisible(desc) then
            local btnText = ""
            if desc:IsA("TextButton") and #desc.Text > 0 then
                btnText = desc.Text
            else
                for _, sub in ipairs(desc:GetDescendants()) do
                    if sub:IsA("TextLabel") and IsGuiObjectTrulyVisible(sub) and #sub.Text > 0 then
                        btnText = sub.Text
                        break
                    end
                end
            end

            if not IsImportantDialogChoice(btnText) then
                local priority = 0
                local lowerText = btnText:lower()
                local lowerName = desc.Name:lower()

                if lowerText:find("skip", 1, true)
                    or lowerText:find("continue", 1, true)
                    or lowerText:find("next", 1, true)
                    or lowerText:find("lanjut", 1, true)
                    or lowerText:find("lewati", 1, true)
                    or lowerText:find("ok", 1, true)
                    or lowerText:find("close", 1, true)
                    or lowerName:find("skip", 1, true)
                    or lowerName:find("continue", 1, true)
                    or lowerName:find("next", 1, true)
                    or lowerName:find("advance", 1, true)
                    or lowerName:find("close", 1, true) then
                    priority = 10
                elseif #btnText <= 2 then
                    priority = 5
                elseif desc:IsA("ImageButton") then
                    local size = desc.AbsoluteSize
                    if size.X > 100 and size.Y > 40 then
                        priority = 7
                    else
                        priority = 3
                    end
                else
                    priority = 2
                end

                table.insert(candidates, {instance = desc, text = btnText, priority = priority})
            end
        end
    end

    table.sort(candidates, function(a, b) return a.priority > b.priority end)

    if #candidates > 0 then
        return candidates[1]
    end
    return nil
end

-- Auto-skip dialog naratif: tekan elemen advance secara berurutan
-- sampai dialog selesai atau pilihan penting muncul
local function AutoSkipNarrativeDialog()
    local maxSkipAttempts = 15
    local skipCount = 0

    while skipCount < maxSkipAttempts and AutoFarmEnabled do
        local dInfo = InspectBuntaDialogue()

        -- Dialog sudah tertutup
        if not dInfo.isOpen then
            print("[NYU HUB DIALOG-SKIP] Dialog sudah tertutup setelah " .. skipCount .. " skip.")
            return true, "DialogClosed"
        end

        -- Pilihan penting muncul - berhenti skip, serahkan ke alur utama
        if dInfo.optionJob or dInfo.optionTakeIt or dInfo.optionSale then
            print("[NYU HUB DIALOG-SKIP] Pilihan penting terdeteksi, menghentikan auto-skip.")
            return true, "ImportantChoiceFound"
        end

        -- Narasi job accepted - berhenti skip, serahkan ke alur utama
        if dInfo.isJobAcceptedNarration then
            print("[NYU HUB DIALOG-SKIP] Narasi job accepted terdeteksi, menghentikan auto-skip.")
            return true, "JobAcceptedNarration"
        end

        -- Cari elemen advance menggunakan finder yang lebih luas
        local advTarget = FindDialogAdvanceTarget(dInfo.container)

        if advTarget then
            print(string.format("[NYU HUB DIALOG-SKIP] Skip #%d: menekan '%s' (Name: %s, Priority: %d)",
                skipCount + 1, advTarget.text, advTarget.instance.Name, advTarget.priority))
            ClickGuiButton(advTarget.instance)
            skipCount = skipCount + 1
            task.wait(0.4)
        else
            -- Tidak ada tombol yang bisa ditekan, coba klik container itu sendiri
            if dInfo.container and dInfo.container:IsA("GuiButton") then
                print("[NYU HUB DIALOG-SKIP] Skip #" .. (skipCount + 1) .. ": menekan container langsung.")
                ClickGuiButton(dInfo.container)
                skipCount = skipCount + 1
                task.wait(0.4)
            else
                -- Tidak ada yang bisa diklik, tunggu sebentar dan cek ulang
                print("[NYU HUB DIALOG-SKIP] Tidak ada elemen advance. Menunggu perubahan dialog...")
                task.wait(0.6)
                local dInfo2 = InspectBuntaDialogue()
                if not dInfo2.isOpen then
                    return true, "DialogClosedAfterWait"
                end
                if dInfo2.narration == dInfo.narration and not dInfo2.optionJob and not dInfo2.optionTakeIt then
                    print("[NYU HUB DIALOG-SKIP] Dialog tampak stuck, keluar dari auto-skip.")
                    return false, "Stuck"
                end
            end
        end
    end

    warn("[NYU HUB DIALOG-SKIP] Mencapai batas maksimum skip (" .. maxSkipAttempts .. ").")
    return false, "MaxSkipReached"
end

local function GetRedNetwork()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local dependencies = ReplicatedStorage:FindFirstChild("Dependencies")
    if dependencies then
        local redModule = dependencies:FindFirstChild("Red")
        if redModule then
            local ok, Red = pcall(require, redModule)
            if ok and Red and Red.Client then
                local netOk, net = pcall(function()
                    return Red.Client("Network")
                end)
                if netOk and net then
                    return net
                end
            end
        end
    end
    return nil
end

local function DetectActiveDeliveryTarget()
    -- 1. Deteksi melalui attribute LocalPlayer
    local checkAttrs = {
        "DeliveryTarget",
        "DeliveryNPC",
        "QuestTarget",
        "TargetNPC",
        "DeliveryDestination",
        "ActiveDelivery",
        "Target",
}
    for _, attrName in ipairs(checkAttrs) do
        local val = LocalPlayer:GetAttribute(attrName)
        if val and typeof(val) == "string" and #val > 0 then
            return val, "PlayerAttribute:" .. attrName
        end
    end

    -- 2. Deteksi melalui Value object di folder player (Quests, Job, dsb)
    local checkFolders = {"Quests", "Quest", "Job", "CurrentJob", "Delivery", "PlayerData"
}
    for _, folderName in ipairs(checkFolders) do
        local folder = LocalPlayer:FindFirstChild(folderName)
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("StringValue") and #child.Value > 0 then
                    return child.Value, "PlayerValue:" .. folderName .. "." .. child.Name
                end
            end
        end
    end

    -- 3. Deteksi melalui PlayerGui text label yang aktif
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Visible then
                        local text = desc.Text
                        local target = text:match("[Dd]eliver to%s+([%w%s]+)")
                            or text:match("[Aa]ntar ke%s+([%w%s]+)")
                            or text:match("[Tt]arget:%s*([%w%s]+)")
                            or text:match("[Tt]o:%s*([%w%s]+)")
                        if target then
                            local cleaned = target:match("^%s*(.-)%s*$")
                            if #cleaned > 1 and cleaned ~= BUNTA_NAME then
                                return cleaned, "PlayerGui:" .. desc.Name
                            end
                        end
                    end
                end
            end
        end
    end

    -- 4. Deteksi melalui marker Workspace aktif (BillboardGui/Highlight selain pada Bunta)
    local workspace = game:GetService("Workspace")
    local npcFolder = workspace:FindFirstChild("NPCs")
    if npcFolder then
        for _, npc in ipairs(npcFolder:GetChildren()) do
            if npc.Name ~= BUNTA_NAME then
                local marker = npc:FindFirstChildWhichIsA("BillboardGui", true)
                    or npc:FindFirstChildWhichIsA("Highlight", true)
                if marker and marker.Enabled then
                    return npc.Name, "WorkspaceMarker:" .. npc.Name
                end
            end
        end
    end

    return nil, nil
end

local function TryCompleteDelivery(targetNPCName)
    local network = GetRedNetwork()
    if network then
        local success, err = pcall(function()
            network:Fire("CompleteDeliveryQuest", targetNPCName)
        end)
        if success then
            print("[NYU HUB] Mengirim CompleteDeliveryQuest untuk:", targetNPCName)
            return true
        else
            warn("[NYU HUB] Error saat memanggil CompleteDeliveryQuest:", err)
        end
    else
        warn("[NYU HUB] Red Network tidak ditemukan di ReplicatedStorage.")
    end
    return false
end

local function RunQuestDiagnostics()
    local lines = {
}
    local function logLine(txt)
        table.insert(lines, txt)
        print(txt)
    end

    logLine("========== [NYU HUB] QUEST & CLIENT DIAGNOSTICS ==========")

    -- 1. Attributes
    local attrs = LocalPlayer:GetAttributes()
    local attrCount = 0
    for k, v in pairs(attrs) do
        attrCount = attrCount + 1
        logLine(string.format("  [Player Attribute] %s = %s (%s)", tostring(k), tostring(v), typeof(v)))
    end
    if attrCount == 0 then
        logLine("  [Player Attribute] Tidak ada attribute pada LocalPlayer.")
    end

    -- 2. Children / Folders
    logLine("  [Player Children]:")
    for _, child in ipairs(LocalPlayer:GetChildren()) do
        if child:IsA("ValueBase") or child:IsA("Folder") or child:IsA("Configuration") then
            logLine(string.format("    - %s (%s)", child.Name, child.ClassName))
            for _, subChild in ipairs(child:GetChildren()) do
                if subChild:IsA("ValueBase") then
                    logLine(string.format("        * %s = %s", subChild.Name, tostring(subChild.Value)))
                end
            end
        end
    end

    -- 3. Bunta Dialogue Container Analysis
    local dInfo = InspectBuntaDialogue()
    logLine(string.format("  [Bunta Dialogue Status] Terbuka: %s | Narasi: '%s'", tostring(dInfo.isOpen), dInfo.narration))
    if dInfo.isOpen then
        logLine(string.format("    - Container Name: %s (Parent: %s)", dInfo.container.Name, dInfo.gui.Name))
        for i, btn in ipairs(dInfo.buttons) do
            logLine(string.format("        [Button %d] '%s' (Name: %s)", i, btn.text, btn.name))
        end
    end

    -- 4. Status Bunta
    local buntaModel = FindNPCModel(BUNTA_NAME)
    if buntaModel then
        local prompt = buntaModel:FindFirstChildWhichIsA("ProximityPrompt", true)
        local cd = buntaModel:FindFirstChildWhichIsA("ClickDetector", true)
        logLine(string.format("  [NPC %s] Ada. Prompt: %s | ClickDetector: %s", BUNTA_NAME, prompt and "YA" or "TIDAK", cd and "YA" or "TIDAK"))
    else
        logLine(string.format("  [NPC %s] Belum ditemukan di Workspace.", BUNTA_NAME))
    end

    logLine("==========================================================")

    local fullReport = table.concat(lines, "\n")

    -- Cetak ke warn agar selalu terlihat di console F9
    warn("[NYU HUB DIAGNOSTICS] Ringkasan tercatat (" .. #lines .. " baris).")

    -- Salin ke clipboard jika executor mendukung
    if setclipboard then
        pcall(function()
            setclipboard(fullReport)
            print("[NYU HUB] Laporan diagnostik disalin ke clipboard!")
        end)
    end

    if StatusComponent then
        pcall(function()
            if StatusComponent.SetTitle and StatusComponent.Set then
                StatusComponent:SetTitle("Status: DIAGNOSTICS DONE")
                StatusComponent:Set(string.format("Laporan dibuat (%d baris). Cek F9 / clipboard.", #lines))
            elseif StatusComponent.Set then
                StatusComponent:Set(string.format("[DIAGNOSTICS DONE] %d baris dicatat", #lines))
            end
        end)
    end

    Window:Notify({
        title = Config.Name,
        content = "Diagnostik selesai (" .. #lines .. " baris). Disalin ke clipboard!",
})
end

-- ====================================================
-- STATE MACHINE AUTO FARM TERSTRUKTUR & TERTIB
-- TELEPORT → VERIFY_ARRIVAL → INTERACT_WITH_NPC →
-- VERIFY_DIALOG_OPEN → SELECT_DIALOG_OPTION →
-- VERIFY_JOB → TELEPORT_TO_RECIPIENT
-- ====================================================

local function RunAutoFarmCycle()
    while AutoFarmEnabled do
        -- ----------------------------------------------------
        -- TAHAP 1: TELEPORT MENUJU FUJIWARA BUNTA
        -- ----------------------------------------------------
        UpdateStatus("TELEPORT_TO_BUNTA", "Memulai teleport menuju Fujiwara Bunta...")

        -- ----------------------------------------------------
        -- TAHAP 2: VERIFY_ARRIVAL (Verifikasi Jarak & Kestabilan Posisi)
        -- ----------------------------------------------------
        UpdateStatus("VERIFY_ARRIVAL", "Memverifikasi kedatangan dan kestabilan posisi...")
        local arrived, arriveReason = TeleportAndVerifyArrival(BUNTA_POSITION, 6, 8)
        if not arrived then
            warn("[NYU HUB] Kedatangan di lokasi Bunta belum stabil (" .. arriveReason .. "). Mengulang navigasi...")
            task.wait(1.0)
            continue
        end
        if not AutoFarmEnabled then break end

        -- ----------------------------------------------------
        -- TAHAP 3: PERIKSA JOB AKTIF (Jika sudah ada, lewati interaksi)
        -- BUG2 FIX: Jika activeTarget sama dengan LastDeliveredTarget,
        -- anggap itu data quest lama yang belum bersih - jangan skip interaksi Bunta
        -- ----------------------------------------------------
        local activeTarget = DetectActiveDeliveryTarget()
        if activeTarget and activeTarget ~= LastDeliveredTarget then
            print(string.format("[NYU HUB] Job delivery '%s' sudah aktif. Langsung menuju tahap pengiriman.", activeTarget))
        else
            if activeTarget and activeTarget == LastDeliveredTarget then
                print(string.format("[NYU HUB] Target '%s' sama dengan delivery terakhir - kemungkinan data quest lama, paksa interaksi Bunta.", activeTarget))
            end
            -- ----------------------------------------------------
            -- TAHAP 4: INTERACT_WITH_NPC & VERIFY_DIALOG_OPEN
            -- ----------------------------------------------------
            local buntaModel = FindNPCModel(BUNTA_NAME)
            if not buntaModel then
                warn("[NYU HUB] Model NPC Bunta belum dimuat di Workspace. Menunggu...")
                task.wait(1.5)
                continue
            end

            local dInfo = InspectBuntaDialogue()
            local dialogOpened = dInfo.isOpen

            if not dialogOpened then
                local interactAttempts = 0
                local maxInteract = 4

                while interactAttempts < maxInteract and AutoFarmEnabled do
                    interactAttempts = interactAttempts + 1
                    UpdateStatus("INTERACT_WITH_NPC", string.format("Memicu interaksi NPC Bunta (percobaan #%d)...", interactAttempts))

                    local ok, reason = TriggerBuntaInteraction(buntaModel)
                    if not ok then
                        warn("[NYU HUB] Gagal memicu interaksi: " .. reason)
                    end

                    -- VERIFY_DIALOG_OPEN: Menunggu dialog benar-benar muncul di layar
                    UpdateStatus("VERIFY_DIALOG_OPEN", string.format("Menunggu dialog terbuka (percobaan #%d)...", interactAttempts))
                    local waitElapsed = 0
                    while waitElapsed < 2.5 and AutoFarmEnabled do
                        task.wait(0.3)
                        waitElapsed = waitElapsed + 0.3
                        dInfo = InspectBuntaDialogue()
                        if dInfo.isOpen then
                            dialogOpened = true
                            print(string.format("[NYU HUB] DIALOG TERBUKA TERVERIFIKASI! (Container: '%s', Narasi: '%s')", dInfo.container.Name, dInfo.narration))
                            break
                        end
                    end

                    if dialogOpened then break end
                    warn(string.format("[NYU HUB] Dialog belum terbuka pada percobaan #%d. Jeda sebelum retry...", interactAttempts))
                    task.wait(0.8)
                end
            else
                print(string.format("[NYU HUB] Dialog Bunta sudah dalam keadaan terbuka. (Container: '%s')", dInfo.container.Name))
            end

            if not AutoFarmEnabled then break end

            if not dialogOpened then
                warn("[NYU HUB] Gagal membuka dialog NPC Bunta setelah 4 percobaan. Mengulang dari navigasi...")
                task.wait(1.5)
                continue
            end

            -- ----------------------------------------------------
            -- TAHAP 4.5: AUTO-SKIP DIALOG NARATIF AWAL (BUG1 FIX)
            -- Skip semua narasi sebelum pilihan job muncul
            -- ----------------------------------------------------
            UpdateStatus("AUTO_SKIP_DIALOG", "Melewati dialog naratif awal...")
            AutoSkipNarrativeDialog()
            task.wait(0.3)
            if not AutoFarmEnabled then break end

            -- ----------------------------------------------------
            -- TAHAP 5: SELECT_DIALOG_OPTION (Tahap 1 & Tahap 2)
            -- ----------------------------------------------------
            dInfo = InspectBuntaDialogue()

            -- Tahap 1: Pilih "Do you have a job for me?" jika tersedia
            if dInfo.optionJob and not dInfo.optionTakeIt and not dInfo.isJobAcceptedNarration then
                UpdateStatus("SELECT_OPTION_S1", "Memilih opsi: 'Do you have a job for me?'...")
                print(string.format("[NYU HUB DIALOG] Menekan tombol opsi Tahap 1: '%s'", dInfo.optionJob.text))
                ClickGuiButton(dInfo.optionJob.instance)
                task.wait(0.8)

                -- BUG1 FIX: Auto-skip narasi setelah memilih job
                UpdateStatus("AUTO_SKIP_DIALOG", "Melewati dialog setelah memilih job...")
                AutoSkipNarrativeDialog()
                task.wait(0.3)
            end

            if not AutoFarmEnabled then break end

            -- Tahap 2: Konfirmasi "Sure, I'll take it."
            dInfo = InspectBuntaDialogue()
            if not dInfo.isJobAcceptedNarration then
                UpdateStatus("CONFIRM_JOB_S2", "Menunggu konfirmasi: 'Sure, I\\'ll take it.'...")
                local s2Timeout = 6
                local s2Elapsed = 0
                local confirmed = false

                while s2Elapsed < s2Timeout and AutoFarmEnabled do
                    dInfo = InspectBuntaDialogue()
                    if dInfo.isJobAcceptedNarration then
                        confirmed = true
                        break
                    end

                    if dInfo.optionTakeIt then
                        print(string.format("[NYU HUB DIALOG] Menekan tombol opsi Tahap 2: '%s'", dInfo.optionTakeIt.text))
                        ClickGuiButton(dInfo.optionTakeIt.instance)
                        confirmed = true
                        task.wait(0.8)
                        break
                    elseif dInfo.advanceBtn then
                        print(string.format("[NYU HUB DIALOG] Menekan tombol lanjutan/skip: '%s'", dInfo.advanceBtn.text))
                        ClickGuiButton(dInfo.advanceBtn.instance)
                        task.wait(0.5)
                    end

                    task.wait(0.3)
                    s2Elapsed = s2Elapsed + 0.3
                end

                if not AutoFarmEnabled then break end

                if not confirmed then
                    warn("[NYU HUB] Konfirmasi job gagal dipilih. Mengulang siklus...")
                    task.wait(1.5)
                    continue
                end
            end

            -- ----------------------------------------------------
            -- TAHAP 6: VERIFY_JOB (Tutup dialog & pastikan target terdeteksi)
            -- ----------------------------------------------------
            -- BUG1 FIX: Auto-skip narasi setelah konfirmasi job (menutup dialog)
            UpdateStatus("VERIFY_JOB", "Memverifikasi job aktif & melewati narasi sisa...")
            AutoSkipNarrativeDialog()
            task.wait(0.3)
        end

        -- Polling verifikasi data quest aktif
        local detectedTarget = nil
        local detectSource = nil
        local verifyTimeout = 10
        local elapsed = 0

        while elapsed < verifyTimeout and AutoFarmEnabled do
            detectedTarget, detectSource = DetectActiveDeliveryTarget()
            if detectedTarget then
                break
            end
            task.wait(0.5)
            elapsed = elapsed + 0.5
        end

        if not AutoFarmEnabled then break end

        if not detectedTarget then
            warn("[NYU HUB] Target job belum terverifikasi dari game data. Mengulang siklus...")
            task.wait(2)
            continue
        end

        print(string.format("[NYU HUB] VERIFIKASI JOB BERHASIL: Target = '%s' (via %s)", detectedTarget, detectSource))
        UpdateStatus("JOB_ACCEPTED", string.format("Target: %s (via %s)", detectedTarget, detectSource), detectedTarget)
        Window:Notify({
            title = Config.Name,
            content = "Job Aktif: Antar ke " .. detectedTarget,
})
        task.wait(0.5)
        if not AutoFarmEnabled then break end

        -- ----------------------------------------------------
        -- TAHAP 7: TELEPORT_TO_RECIPIENT & DELIVER
        -- ----------------------------------------------------
        UpdateStatus("DELIVER_TO_RECIPIENT", "Navigasi menuju penerima: " .. detectedTarget, detectedTarget)
        local targetModel = FindNPCModel(detectedTarget)
        if targetModel then
            local targetPart = targetModel:FindFirstChild("HumanoidRootPart")
                or targetModel.PrimaryPart
                or targetModel:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                TeleportAndVerifyArrival(targetPart.Position + Vector3.new(0, 0, 3), 6, 10)
            end
        else
            print(string.format("[NYU HUB] Model target '%s' belum ditemukan di Workspace. Mengirim sinyal network.", detectedTarget))
        end

        task.wait(0.6)
        if not AutoFarmEnabled then break end

        if targetModel then
            local prompt = targetModel:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and fireproximityprompt then
                pcall(function() fireproximityprompt(prompt) end)
            end
        end
        TryCompleteDelivery(detectedTarget)

        -- BUG2 FIX: Simpan target terakhir yang dideliver, bersihkan referensi lama
        LastDeliveredTarget = detectedTarget
        targetModel = nil  -- Bersihkan referensi model NPC penerima

        UpdateStatus("DELIVERY_COMPLETE", "Paket diserahkan ke " .. detectedTarget, detectedTarget)
        task.wait(1.5)
        if not AutoFarmEnabled then break end

        -- ----------------------------------------------------
        -- TAHAP 8: RETURN_TO_START & COOLDOWN
        -- ----------------------------------------------------
        UpdateStatus("RETURN_TO_START", "Kembali ke Fujiwara Bunta untuk job berikutnya...")
        local backArrived, backReason = TeleportAndVerifyArrival(BUNTA_POSITION, 6, 8)
        if not backArrived then
            warn("[NYU HUB] Kembali ke Bunta timeout (" .. backReason .. "). Melakukan re-pivot...")
            TeleportAndVerifyArrival(BUNTA_POSITION, 4, 10)
        end

        -- BUG2 FIX: Verifikasi bahwa kita berada dekat Bunta sebelum melanjutkan
        UpdateStatus("VERIFY_RETURN", "Memverifikasi posisi di dekat Fujiwara Bunta...")
        local buntaReturnModel = FindNPCModel(BUNTA_NAME)
        if buntaReturnModel then
            local buntaReturnPart = buntaReturnModel:FindFirstChild("HumanoidRootPart")
                or buntaReturnModel.PrimaryPart
                or buntaReturnModel:FindFirstChildWhichIsA("BasePart")
            if buntaReturnPart then
                local returnRoot = GetRootPart()
                if returnRoot then
                    local distToBunta = (returnRoot.Position - buntaReturnPart.Position).Magnitude
                    if distToBunta > 15 then
                        warn(string.format("[NYU HUB] Masih terlalu jauh dari Bunta (%.1f studs). Re-teleport...", distToBunta))
                        TeleportAndVerifyArrival(BUNTA_POSITION, 6, 8)
                    end
                end
            end
        end

        -- Tunggu hingga data quest lama bersih sebelum siklus berikutnya
        UpdateStatus("COOLDOWN", "Menunggu quest lama bersih & persiapan siklus baru...")
        local clearTimer = 0
        while clearTimer < 4 and AutoFarmEnabled do
            local current = DetectActiveDeliveryTarget()
            if not current or current ~= detectedTarget then
                break
            end
            task.wait(0.5)
            clearTimer = clearTimer + 0.5
        end

        -- BUG2 FIX: Reset referensi agar siklus baru tidak menggunakan target lama
        print(string.format("[NYU HUB] Siklus selesai. LastDeliveredTarget = '%s'. Memulai siklus baru.", tostring(LastDeliveredTarget)))

        if not AutoFarmEnabled then break end
        task.wait(1.0)
    end

    UpdateStatus("IDLE", "Auto Farm dihentikan.", "-")
end

-- 6.2 Auto Farm Tofu Toggle
UtilitiesTab:CreateToggle({
    name = "Auto Farm Tofu",
    flag = "NyuAutoFarmTofu",

    callback = function(enabled)
        AutoFarmEnabled = enabled

        if enabled then
            Window:Notify({
                title = Config.Name,
                content = "Auto Farm Tofu diaktifkan...",
})
            print("[NYU HUB] Auto Farm Tofu: ON")

            if FarmThread then
                task.cancel(FarmThread)
                FarmThread = nil
            end

            FarmThread = task.spawn(RunAutoFarmCycle)
        else
            AutoFarmEnabled = false
            if FarmThread then
                task.cancel(FarmThread)
                FarmThread = nil
            end
            UpdateStatus("IDLE", "Auto Farm dimatikan oleh pengguna.", "-")

            Window:Notify({
                title = Config.Name,
                content = "Auto Farm Tofu dimatikan.",
})
            print("[NYU HUB] Auto Farm Tofu: OFF")
        end
    end,
})

-- 6.3 Tombol Diagnostik Status Quest
UtilitiesTab:CreateButton({
    name = "Run Quest Diagnostics",
    description = "Cek atribut player, GUI dialog, dan salin ke clipboard",

    callback = function()
        RunQuestDiagnostics()
    end,
})

-- =========================================
-- TELEPORT TO PLAYER BY USERNAME
-- =========================================

local SelectedUsername = ""

-- Input username target
UtilitiesTab:CreateInput({
    name = "Player Username",
    placeholder = "Masukkan username pemain...",
    flag = "NyuTeleportUsername",

    callback = function(value)
        SelectedUsername = value or ""
    end,
})

-- Teleport button
UtilitiesTab:CreateButton({
    name = "Teleport to Player",
    description = "Pilih target berdasarkan username",

    callback = function()
        local username = SelectedUsername:match("^%s*(.-)%s*$")

        if username == "" then
            Window:Notify({
                title = Config.Name,
                content = "Masukkan username terlebih dahulu.",
})
            return
        end

        -- Cari username yang tepat di server saat ini
        local targetPlayer

        for _, player in ipairs(Players:GetPlayers()) do
            if player.Name:lower() == username:lower() then
                targetPlayer = player
                break
            end
        end

        if not targetPlayer then
            Window:Notify({
                title = Config.Name,
                content = "Username tidak ditemukan di server ini.",
})
            return
        end

        if targetPlayer == LocalPlayer then
            Window:Notify({
                title = Config.Name,
                content = "Tidak bisa memilih akun sendiri.",
})
            return
        end

        -- Validasi karakter
        local character = LocalPlayer.Character
        local targetCharacter = targetPlayer.Character

        local targetRoot = targetCharacter
            and targetCharacter:FindFirstChild("HumanoidRootPart")

        if not character or not character:FindFirstChild("HumanoidRootPart") then
            Window:Notify({
                title = Config.Name,
                content = "Karakter kamu belum siap.",
})
            return
        end

        if not targetRoot then
            Window:Notify({
                title = Config.Name,
                content = "Karakter target belum siap.",
})
            return
        end

        -- Perpindahan lokal; server game dapat membatalkannya
        character:PivotTo(
            targetRoot.CFrame * CFrame.new(0, 0, 3)
        )

        Window:Notify({
            title = Config.Name,
            content = "Teleport dicoba ke " .. targetPlayer.Name,
})

        print("[NYU HUB] Teleport target:", targetPlayer.Name)
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
