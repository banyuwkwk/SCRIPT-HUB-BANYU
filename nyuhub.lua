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

local function InteractWithBunta(buntaModel)
    if not buntaModel then return false end

    local interacted = false

    -- 1. ProximityPrompt jika tersedia
    local prompt = buntaModel:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and fireproximityprompt then
        pcall(function()
            fireproximityprompt(prompt)
            interacted = true
        end)
    end

    -- 2. ClickDetector pada part NPC
    for _, desc in ipairs(buntaModel:GetDescendants()) do
        if desc:IsA("ClickDetector") and fireclickdetector then
            pcall(function()
                fireclickdetector(desc)
                interacted = true
            end)
        end
    end

    -- 3. Klik simulasi mouse pada posisi visual NPC di layar
    pcall(function()
        local camera = workspace.CurrentCamera
        local targetPart = buntaModel:FindFirstChild("Head")
            or buntaModel:FindFirstChild("HumanoidRootPart")
            or buntaModel.PrimaryPart
            or buntaModel:FindFirstChildWhichIsA("BasePart")

        if camera and targetPart then
            local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
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

local function TryAcceptJobFromDialog()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return false end

    local acceptKeywords = {
        "delivery", "tofu", "job", "kerja", "terima", "ambil",
        "accept", "apply", "yes", "ya", "mulai", "start", "antar"
    }

    local matchedButton = nil

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local gName = gui.Name:lower()
            -- Abaikan GUI NYU HUB dan Rayfield
            if not gName:find("rayfield") and not gName:find("nyu") then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("GuiButton") and desc.Visible then
                        local btnText = ""
                        if desc:IsA("TextButton") then
                            btnText = desc.Text:lower()
                        end
                        local bName = desc.Name:lower()

                        for _, kw in ipairs(acceptKeywords) do
                            if btnText:find(kw) or bName:find(kw) then
                                matchedButton = desc
                                break
                            end
                        end

                        if not matchedButton then
                            for _, sub in ipairs(desc:GetDescendants()) do
                                if sub:IsA("TextLabel") and sub.Visible then
                                    local subText = sub.Text:lower()
                                    for _, kw in ipairs(acceptKeywords) do
                                        if subText:find(kw) then
                                            matchedButton = desc
                                            break
                                        end
                                    end
                                end
                                if matchedButton then break end
                            end
                        end

                        if matchedButton then break end
                    end
                end
            end
        end
        if matchedButton then break end
    end

    -- Jika kata kunci tidak cocok tapi dialog NPC sedang aktif dengan pilihan opsi
    if not matchedButton then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                local gName = gui.Name:lower()
                if gName:find("dialog") or gName:find("interaction") or gName:find("talk") or gName:find("npc") then
                    for _, desc in ipairs(gui:GetDescendants()) do
                        if desc:IsA("GuiButton") and desc.Visible then
                            matchedButton = desc
                            break
                        end
                    end
                end
            end
            if matchedButton then break end
        end
    end

    if matchedButton then
        print("[NYU HUB] Mengklik opsi dialog:", matchedButton.Name, matchedButton:IsA("TextButton") and ("'" .. matchedButton.Text .. "'") or "")
        return ClickGuiButton(matchedButton)
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
        -- TAHAP 1: Navigasi ke Fujiwara Bunta
        UpdateStatus("NAVIGATING_TO_BUNTA", "Teleport ke Fujiwara Bunta...")
        local root = GetRootPart()
        if not root then
            task.wait(1)
            continue
        end

        SafeTeleport(CFrame.new(BUNTA_POSITION))

        local waitPos = 0
        while waitPos < 8 and AutoFarmEnabled do
            task.wait(0.1)
            waitPos = waitPos + 1
        end
        if not AutoFarmEnabled then break end

        -- TAHAP 2: Buka Dialog NPC Bunta
        UpdateStatus("OPENING_DIALOG", "Memicu dialog NPC Fujiwara Bunta...")
        local buntaModel = FindNPCModel(BUNTA_NAME)
        if buntaModel then
            InteractWithBunta(buntaModel)
        end

        task.wait(0.5)
        if not AutoFarmEnabled then break end

        -- TAHAP 3: Pilih Opsi Terima Job di Dialog
        UpdateStatus("ACCEPTING_JOB", "Mencari & memilih tombol terima job di dialog...")
        local acceptAttempts = 0
        local accepted = false
        while acceptAttempts < 6 and AutoFarmEnabled do
            accepted = TryAcceptJobFromDialog()
            if accepted then
                break
            end
            task.wait(0.5)
            acceptAttempts = acceptAttempts + 1
        end

        if not AutoFarmEnabled then break end

        -- TAHAP 4: Verifikasi Job Aktif & Baca Target Penerima
        UpdateStatus("WAIT_FOR_JOB_TARGET", "Memverifikasi job & mendeteksi target...")
        local detectedTarget = nil
        local detectSource = nil
        local detectTimeout = 8
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
            UpdateStatus("WAIT_FOR_JOB_TARGET", "Target belum terdeteksi. Mengulang interaksi Bunta...")
            task.wait(1.5)
            continue
        end

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
                SafeTeleport(targetPart.CFrame * CFrame.new(0, 0, 3))
            end
        else
            print(string.format("[NYU HUB] Model '%s' belum ditemukan di workspace. Menyelesaikan via network.", detectedTarget))
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

        -- TAHAP 6: Kembali ke Bunta & Persiapan Siklus Berikutnya
        UpdateStatus("RETURNING_TO_BUNTA", "Kembali ke Fujiwara Bunta untuk job berikutnya...")
        SafeTeleport(CFrame.new(BUNTA_POSITION))

        -- Tunggu hingga target aktif sebelumnya terhapus dari tracker
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

        UpdateStatus("COOLDOWN", "Siklus selesai. Memulai job baru...")
        task.wait(1.5)
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
