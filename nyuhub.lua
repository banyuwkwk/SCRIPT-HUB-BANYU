--[[
    NYU HUB
    Version: 1.1.0
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
    Version = "1.1.0",
    Subtitle = "Utility Tools v1.1.0",

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
    range = { 1, 100 },
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

local function GetRootPart()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart", 5)
end

local function SafeTeleport(targetCFrame)
    local root = GetRootPart()
    if not root then return false end
    local character = LocalPlayer.Character
    if character then
        character:PivotTo(targetCFrame)
        return true
    end
    return false
end

-- Teleport dengan verifikasi jarak fisik dan stabilisasi posisi
local function TeleportToPosition(targetPos, maxWaitSeconds)
    maxWaitSeconds = maxWaitSeconds or 6
    local root = GetRootPart()
    if not root then return false end

    local character = LocalPlayer.Character
    if not character then return false end

    local targetV3 = typeof(targetPos) == "CFrame" and targetPos.Position or targetPos
    local targetCF = typeof(targetPos) == "CFrame" and targetPos or CFrame.new(targetPos)

    -- Nolkan kecepatan linear dan angular agar karakter tidak meluncur atau mental
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)

    character:PivotTo(targetCF)

    -- Loop verifikasi jarak fisik aktual karakter
    local elapsed = 0
    while elapsed < maxWaitSeconds and AutoFarmEnabled do
        task.wait(0.1)
        elapsed = elapsed + 0.1

        root = GetRootPart()
        if root then
            local dist = (root.Position - targetV3).Magnitude
            if dist <= 12 then
                -- Karakter sudah berada tepat di titik target
                pcall(function()
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end)
                task.wait(0.6) -- Jeda stabilisasi posisi di server
                return true
            end
            -- Re-pivot jika terjadi rubberband
            if elapsed > 1.5 and dist > 12 then
                character:PivotTo(targetCF)
            end
        end
    end

    return false
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

    -- Metode 1: firesignal (jika didukung executor)
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

-- Interaksi khusus dan terarah hanya ke NPC Fujiwara Bunta
local function InteractWithBunta(buntaModel)
    if not buntaModel then return false end

    local root = GetRootPart()
    local buntaPart = buntaModel:FindFirstChild("HumanoidRootPart")
        or buntaModel.PrimaryPart
        or buntaModel:FindFirstChild("Head")
        or buntaModel:FindFirstChildWhichIsA("BasePart")

    -- Verifikasi jarak aman: pastikan karakter memang berada dekat Bunta (< 25 studs)
    if root and buntaPart then
        local dist = (root.Position - buntaPart.Position).Magnitude
        if dist > 25 then
            warn(string.format("[NYU HUB] Karakter masih berjarak %.1f studs dari Bunta. Interaksi ditunda.", dist))
            return false
        end
    end

    local interacted = false

    -- 1. ProximityPrompt KHUSUS di dalam model Fujiwara Bunta
    local prompt = buntaModel:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and fireproximityprompt then
        pcall(function()
            fireproximityprompt(prompt)
            interacted = true
        end)
    end

    -- 2. ClickDetector KHUSUS di dalam model Fujiwara Bunta
    for _, desc in ipairs(buntaModel:GetDescendants()) do
        if desc:IsA("ClickDetector") and fireclickdetector then
            pcall(function()
                fireclickdetector(desc)
                interacted = true
            end)
        end
    end

    -- 3. Arahkan kamera langsung ke Bunta dan lakukan simulasi klik mouse
    pcall(function()
        local camera = workspace.CurrentCamera
        if camera and buntaPart then
            camera.CFrame = CFrame.new(camera.CFrame.Position, buntaPart.Position)
            local screenPos, onScreen = camera:WorldToViewportPoint(buntaPart.Position)
            if onScreen then
                local vim = game:GetService("VirtualInputManager")
                vim:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 1)
                task.wait(0.05)
                vim:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 1)
                interacted = true
            end
        end
    end)

    return interacted
end

-- Deteksi dan klik tombol opsi dialog dua tahap dengan filter teks terlarang
local function FindAndClickDialogOption(targetPhrase, forbiddenPhrase, stageName)
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return false end

    local foundOptions = {}
    local chosenButton = nil
    local chosenText = ""

    local lowerTarget = targetPhrase:lower()
    local lowerForbidden = forbiddenPhrase and forbiddenPhrase:lower() or nil

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local gName = gui.Name:lower()
            -- Abaikan GUI NYU HUB dan Rayfield
            if not gName:find("rayfield") and not gName:find("nyu") then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("GuiButton") and desc.Visible then
                        local btnText = ""
                        if desc:IsA("TextButton") and #desc.Text > 0 then
                            btnText = desc.Text
                        else
                            for _, sub in ipairs(desc:GetDescendants()) do
                                if sub:IsA("TextLabel") and sub.Visible and #sub.Text > 0 then
                                    btnText = sub.Text
                                    break
                                end
                            end
                        end

                        local cleanText = btnText:gsub("%s+", " "):match("^%s*(.-)%s*$") or ""
                        if #cleanText > 0 then
                            table.insert(foundOptions, {button = desc, text = cleanText})

                            local lowerClean = cleanText:lower()
                            if lowerClean:find(lowerTarget, 1, true) then
                                if not lowerForbidden or not lowerClean:find(lowerForbidden, 1, true) then
                                    chosenButton = desc
                                    chosenText = cleanText
                                end
                            end
                        end
                    end
                end
            end
        end
        if chosenButton then break end
    end

    -- Cetak seluruh opsi dialog yang terdeteksi di layar
    if #foundOptions > 0 then
        local optionSummary = {}
        for i, opt in ipairs(foundOptions) do
            table.insert(optionSummary, string.format("[%d] '%s'", i, opt.text))
        end
        print(string.format("[NYU HUB DIALOG] [%s] Opsi terdeteksi di layar: %s", stageName, table.concat(optionSummary, " | ")))
    end

    if chosenButton then
        print(string.format("[NYU HUB DIALOG] [%s] MEMILIH: '%s'", stageName, chosenText))
        local clickOk = ClickGuiButton(chosenButton)
        return clickOk
    end

    return false
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
    local checkFolders = {"Quests", "Quest", "Job", "CurrentJob", "Delivery", "PlayerData"}
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
    local lines = {}
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

    -- 3. ScreenGuis & Visible Buttons
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        logLine("  [Active ScreenGuis & Buttons]:")
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                local gName = gui.Name:lower()
                if not gName:find("rayfield") and not gName:find("nyu") then
                    logLine(string.format("    - ScreenGui: %s", gui.Name))
                    for _, desc in ipairs(gui:GetDescendants()) do
                        if desc:IsA("GuiButton") and desc.Visible then
                            local text = desc:IsA("TextButton") and desc.Text or "(ImageButton)"
                            logLine(string.format("        [Button] %s: '%s'", desc.Name, text))
                        elseif desc:IsA("TextLabel") and desc.Visible and #desc.Text > 0 and #desc.Text < 80 then
                            logLine(string.format("        [Label] %s: '%s'", desc.Name, desc.Text))
                        end
                    end
                end
            end
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

local function RunAutoFarmCycle()
    while AutoFarmEnabled do
        -- TAHAP 1: Navigasi ke Fujiwara Bunta & Verifikasi Posisi Fisik
        UpdateStatus("NAVIGATING_TO_BUNTA", "Teleport & verifikasi posisi di Fujiwara Bunta...")
        local arrived = TeleportToPosition(BUNTA_POSITION, 6)
        if not arrived then
            warn("[NYU HUB] Karakter belum mencapai posisi Bunta. Mengulang teleport...")
            task.wait(1)
            continue
        end
        if not AutoFarmEnabled then break end

        -- Verifikasi keberadaan model Bunta di dekat karakter
        local buntaModel = FindNPCModel(BUNTA_NAME)
        if not buntaModel then
            warn("[NYU HUB] Model NPC Bunta belum dimuat di workspace. Menunggu...")
            task.wait(1.5)
            continue
        end

        -- Jeda stabilisasi posisi sebelum interaksi
        task.wait(0.6)
        if not AutoFarmEnabled then break end

        -- TAHAP 2: Buka Dialog Bunta & Pilih Opsi Tahap 1 ("Do you have a job for me?")
        UpdateStatus("OPENING_DIALOG", "Memicu dialog dengan Fujiwara Bunta...")
        local stage1Accepted = false
        local interactAttempts = 0
        local maxInteractAttempts = 5

        while interactAttempts < maxInteractAttempts and AutoFarmEnabled do
            interactAttempts = interactAttempts + 1
            print(string.format("[NYU HUB] Interaksi Bunta percobaan #%d...", interactAttempts))
            InteractWithBunta(buntaModel)

            -- Tunggu dialog tahap 1 muncul dan klik "Do you have a job for me?"
            local waitS1 = 0
            while waitS1 < 2.0 and AutoFarmEnabled do
                task.wait(0.4)
                waitS1 = waitS1 + 0.4
                if FindAndClickDialogOption("job for me", "for sale", "Tahap 1") then
                    stage1Accepted = true
                    break
                end
            end

            if stage1Accepted then
                break
            end
            task.wait(0.8)
        end

        if not AutoFarmEnabled then break end

        if not stage1Accepted then
            warn("[NYU HUB] Dialog Tahap 1 ('Do you have a job for me?') belum berhasil dipilih. Mengulang dari navigasi...")
            task.wait(1.5)
            continue
        end

        -- TAHAP 3: Tunggu & Pilih Opsi Tahap 2 ("Sure, I'll take it.")
        UpdateStatus("APPLYING_JOB_S2", "Menunggu dialog konfirmasi: 'Sure, I\\'ll take it.'...")
        task.wait(0.8)
        if not AutoFarmEnabled then break end

        local stage2Accepted = false
        local s2Timeout = 6
        local s2Elapsed = 0

        while s2Elapsed < s2Timeout and AutoFarmEnabled do
            stage2Accepted = FindAndClickDialogOption("take it", "nevermind", "Tahap 2")
            if stage2Accepted then
                break
            end
            task.wait(0.5)
            s2Elapsed = s2Elapsed + 0.5
        end

        if not AutoFarmEnabled then break end

        if not stage2Accepted then
            warn("[NYU HUB] Dialog Tahap 2 ('Sure, I\\'ll take it.') belum berhasil dipilih. Mengulang interaksi...")
            task.wait(1.5)
            continue
        end

        -- TAHAP 4: Verifikasi Job Aktif & Baca Target Penerima
        UpdateStatus("WAIT_FOR_JOB_TARGET", "Memverifikasi job aktif & mendeteksi target penerima...")
        local detectedTarget = nil
        local detectSource = nil
        local detectTimeout = 10
        local elapsed = 0

        while elapsed < detectTimeout and AutoFarmEnabled do
            detectedTarget, detectSource = DetectActiveDeliveryTarget()
            if detectedTarget then
                break
            end
            task.wait(0.5)
            elapsed = elapsed + 0.5
        end

        if not AutoFarmEnabled then break end

        if not detectedTarget then
            warn("[NYU HUB] Target job belum terdeteksi setelah konfirmasi dialog. Mengulang siklus...")
            task.wait(2)
            continue
        end

        print(string.format("[NYU HUB] VERIFIKASI SUKSES: Job diterima! Target = '%s' (via %s)", detectedTarget, detectSource))
        UpdateStatus("JOB_ACCEPTED", string.format("Target: %s (via %s)", detectedTarget, detectSource), detectedTarget)
        Window:Notify({
            title = Config.Name,
            content = "Job Aktif: Antar ke " .. detectedTarget,
        })

        task.wait(0.5)
        if not AutoFarmEnabled then break end

        -- TAHAP 5: Navigasi ke Penerima & Serahkan Paket
        UpdateStatus("DELIVERING", "Teleport ke penerima: " .. detectedTarget, detectedTarget)
        local targetModel = FindNPCModel(detectedTarget)
        if targetModel then
            local targetPart = targetModel:FindFirstChild("HumanoidRootPart")
                or targetModel.PrimaryPart
                or targetModel:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                TeleportToPosition(targetPart.Position + Vector3.new(0, 0, 3), 5)
            end
        else
            print(string.format("[NYU HUB] Model target '%s' belum ditemukan di workspace. Mengirim sinyal network.", detectedTarget))
        end

        local waitReceiver = 0
        while waitReceiver < 8 and AutoFarmEnabled do
            task.wait(0.1)
            waitReceiver = waitReceiver + 1
        end
        if not AutoFarmEnabled then break end

        -- Memicu interaksi penerima dan menyelesaikan quest
        if targetModel then
            local prompt = targetModel:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and fireproximityprompt then
                pcall(function() fireproximityprompt(prompt) end)
            end
        end
        TryCompleteDelivery(detectedTarget)

        UpdateStatus("DELIVERY_COMPLETE", "Paket diserahkan ke " .. detectedTarget, detectedTarget)
        task.wait(1.5)
        if not AutoFarmEnabled then break end

        -- TAHAP 6: Kembali ke Bunta & Verifikasi Posisi Selesai
        UpdateStatus("RETURNING_TO_BUNTA", "Kembali ke Fujiwara Bunta untuk job berikutnya...")
        local backArrived = TeleportToPosition(BUNTA_POSITION, 6)
        if not backArrived then
            warn("[NYU HUB] Verifikasi posisi kembali ke Bunta timeout. Mencoba ulang...")
        end

        -- Tunggu hingga target aktif sebelumnya benar-benar terhapus dari tracker
        local clearTimer = 0
        while clearTimer < 4 and AutoFarmEnabled do
            local current = DetectActiveDeliveryTarget()
            if not current or current ~= detectedTarget then
                break
            end
            task.wait(0.5)
            clearTimer = clearTimer + 0.5
        end

        if not AutoFarmEnabled then break end

        -- Jeda stabilisasi posisi sebelum memulai job baru
        UpdateStatus("COOLDOWN", "Siklus selesai. Siap memulai job baru...")
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
