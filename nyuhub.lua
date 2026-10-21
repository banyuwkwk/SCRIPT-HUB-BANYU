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

-- Teleport dengan verifikasi jarak fisik aktual dan stabilisasi kecepatan
local function TeleportToPosition(targetPos, maxWaitSeconds)
    maxWaitSeconds = maxWaitSeconds or 6
    local root = GetRootPart()
    if not root then return false end

    local character = LocalPlayer.Character
    if not character then return false end

    local targetV3 = typeof(targetPos) == "CFrame" and targetPos.Position or targetPos
    local targetCF = typeof(targetPos) == "CFrame" and targetPos or CFrame.new(targetPos)

    -- Nolkan kecepatan physics linear dan angular agar karakter tidak meluncur
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

-- ====================================================
-- DIALOGUE CONTAINER ISOLATION & STATE INSPECTOR
-- ====================================================

-- Mencari container ScreenGui/Frame spesifik milik dialog Fujiwara Bunta
local function FindBuntaDialogueContainer()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil, nil end

    local signaturePhrases = {
        "fujiwara",
        "tofu",
        "job for me",
        "for sale",
        "take it",
        "nevermind",
        "break the tofu",
        "good to know",
        "are you sure you want to",
    }

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local gName = gui.Name:lower()
            -- Abaikan GUI Rayfield dan NYU HUB
            if not gName:find("rayfield") and not gName:find("nyu") then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and desc.Visible then
                        local text = desc.Text:lower()
                        for _, sig in ipairs(signaturePhrases) do
                            if text:find(sig, 1, true) then
                                -- Container ditemukan! Cari Frame pembungkus teratas di bawah ScreenGui atau gunakan ScreenGui
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
            narration = "",
            buttons = {},
            optionJob = nil,
            optionSale = nil,
            optionTakeIt = nil,
            optionNevermind = nil,
            advanceBtn = nil,
            isJobAcceptedNarration = false,
        }
    end

    local narrationList = {}
    local buttons = {}
    local optJob = nil
    local optSale = nil
    local optTakeIt = nil
    local optNevermind = nil
    local advanceBtn = nil

    for _, desc in ipairs(container:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Visible and #desc.Text > 0 then
            local clean = desc.Text:gsub("%s+", " "):match("^%s*(.-)%s*$")
            if clean and #clean > 0 then
                table.insert(narrationList, clean)
            end
        elseif desc:IsA("GuiButton") and desc.Visible then
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

    return {
        isOpen = true,
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

-- =========================================
-- REFACTORED STATE MACHINE AUTO FARM
-- =========================================

local function RunAutoFarmCycle()
    while AutoFarmEnabled do
        -- ----------------------------------------------------
        -- STATE 1: RETURN_TO_START
        -- ----------------------------------------------------
        UpdateStatus("RETURN_TO_START", "Navigasi menuju Fujiwara Bunta...")
        local arrived = TeleportToPosition(BUNTA_POSITION, 6)
        if not arrived then
            warn("[NYU HUB] Karakter belum mencapai posisi Bunta. Mengulang navigasi...")
            task.wait(1)
            continue
        end
        if not AutoFarmEnabled then break end

        -- ----------------------------------------------------
        -- STATE 2: VERIFY_POSITION
        -- ----------------------------------------------------
        UpdateStatus("VERIFY_POSITION", "Memverifikasi stabilitas posisi karakter...")
        local root = GetRootPart()
        local buntaModel = FindNPCModel(BUNTA_NAME)
        if not buntaModel or not root then
            warn("[NYU HUB] Bunta model atau karakter belum siap. Menunggu...")
            task.wait(1.5)
            continue
        end

        local distBunta = (root.Position - BUNTA_POSITION).Magnitude
        if distBunta > 15 then
            warn(string.format("[NYU HUB] Posisi karakter belum stabil (jarak: %.1f studs). Mengulang...", distBunta))
            task.wait(1)
            continue
        end
        task.wait(0.6)
        if not AutoFarmEnabled then break end

        -- ----------------------------------------------------
        -- STATE 3: OPEN_DIALOG (Hanya jika dialog belum terbuka dan job belum aktif)
        -- ----------------------------------------------------
        local activeTarget = DetectActiveDeliveryTarget()
        if activeTarget then
            print(string.format("[NYU HUB] Job delivery sudah aktif sebelumnya untuk '%s'. Melewati pembukaan dialog.", activeTarget))
        else
            local dInfo = InspectBuntaDialogue()
            if not dInfo.isOpen then
                UpdateStatus("OPEN_DIALOG", "Memicu interaksi NPC Fujiwara Bunta...")
                local interactAttempts = 0
                local maxAttempts = 4

                while interactAttempts < maxAttempts and AutoFarmEnabled do
                    interactAttempts = interactAttempts + 1
                    print(string.format("[NYU HUB] Membuka dialog Bunta (percobaan #%d)...", interactAttempts))
                    InteractWithBunta(buntaModel)

                    local waitOpen = 0
                    while waitOpen < 2.0 and AutoFarmEnabled do
                        task.wait(0.4)
                        waitOpen = waitOpen + 0.4
                        dInfo = InspectBuntaDialogue()
                        if dInfo.isOpen then
                            break
                        end
                    end
                    if dInfo.isOpen then break end
                    task.wait(0.8)
                end
            end

            if not AutoFarmEnabled then break end

            dInfo = InspectBuntaDialogue()
            if not dInfo.isOpen then
                warn("[NYU HUB] Dialog Bunta gagal dibuka setelah percobaan interaksi. Mengulang dari navigasi...")
                task.wait(1.5)
                continue
            end

            print(string.format("[NYU HUB DIALOG] Dialog aktif terdeteksi. Container: '%s' | Narasi: '%s'", dInfo.container.Name, dInfo.narration))

            -- ----------------------------------------------------
            -- STATE 4: SELECT_JOB_OPTION ("Do you have a job for me?")
            -- ----------------------------------------------------
            -- Jika dialog sudah berada di tahap konfirmasi atau sudah diterima, lewati tahap awal
            if not dInfo.optionTakeIt and not dInfo.isJobAcceptedNarration then
                UpdateStatus("SELECT_JOB_OPTION", "Memilih opsi 'Do you have a job for me?'...")
                local s1Timeout = 6
                local s1Elapsed = 0
                local s1Success = false

                while s1Elapsed < s1Timeout and AutoFarmEnabled do
                    dInfo = InspectBuntaDialogue()
                    if dInfo.optionTakeIt or dInfo.isJobAcceptedNarration then
                        s1Success = true
                        break
                    end

                    if dInfo.optionJob then
                        print(string.format("[NYU HUB DIALOG] [SELECT_JOB_OPTION] Menekan tombol: '%s'", dInfo.optionJob.text))
                        ClickGuiButton(dInfo.optionJob.instance)
                        s1Success = true
                        task.wait(0.8)
                        break
                    elseif dInfo.advanceBtn then
                        print(string.format("[NYU HUB DIALOG] [SELECT_JOB_OPTION] Menekan tombol pengantar: '%s'", dInfo.advanceBtn.text))
                        ClickGuiButton(dInfo.advanceBtn.instance)
                        task.wait(0.6)
                    end

                    task.wait(0.4)
                    s1Elapsed = s1Elapsed + 0.4
                end

                if not AutoFarmEnabled then break end
                if not s1Success then
                    warn("[NYU HUB] Gagal memilih opsi tahap 1 ('Do you have a job for me?'). Mengulang siklus...")
                    task.wait(1.5)
                    continue
                end
            end

            -- ----------------------------------------------------
            -- STATE 5: ADVANCE_DIALOG (Menuju 'Sure, I'll take it.')
            -- ----------------------------------------------------
            UpdateStatus("ADVANCE_DIALOG", "Menunggu tahap konfirmasi job...")
            local advTimeout = 8
            local advElapsed = 0

            while advElapsed < advTimeout and AutoFarmEnabled do
                dInfo = InspectBuntaDialogue()
                if dInfo.optionTakeIt or dInfo.isJobAcceptedNarration then
                    break
                end
                if dInfo.advanceBtn then
                    print(string.format("[NYU HUB DIALOG] [ADVANCE_DIALOG] Menekan tombol lanjutan: '%s'", dInfo.advanceBtn.text))
                    ClickGuiButton(dInfo.advanceBtn.instance)
                    task.wait(0.6)
                else
                    task.wait(0.4)
                end
                advElapsed = advElapsed + 0.4
            end

            if not AutoFarmEnabled then break end

            -- ----------------------------------------------------
            -- STATE 6: CONFIRM_JOB ("Sure, I'll take it.")
            -- ----------------------------------------------------
            dInfo = InspectBuntaDialogue()
            if not dInfo.isJobAcceptedNarration then
                if dInfo.optionTakeIt then
                    UpdateStatus("CONFIRM_JOB", "Memilih opsi konfirmasi: 'Sure, I\\'ll take it.'...")
                    print(string.format("[NYU HUB DIALOG] [CONFIRM_JOB] Menekan tombol: '%s'", dInfo.optionTakeIt.text))
                    ClickGuiButton(dInfo.optionTakeIt.instance)
                    task.wait(0.8)
                else
                    warn("[NYU HUB] Opsi 'Sure, I\\'ll take it.' tidak ditemukan. Mengulang siklus...")
                    task.wait(1.5)
                    continue
                end
            else
                print("[NYU HUB DIALOG] Narasi konfirmasi terdeteksi ('" .. dInfo.narration .. "'). Langsung verifikasi job.")
            end

            if not AutoFarmEnabled then break end

            -- ----------------------------------------------------
            -- STATE 7: VERIFY_JOB (Tutup dialog penutup jika ada)
            -- ----------------------------------------------------
            UpdateStatus("VERIFY_JOB", "Memverifikasi status job dan membaca penerima...")
            dInfo = InspectBuntaDialogue()
            if dInfo.isOpen and dInfo.advanceBtn then
                ClickGuiButton(dInfo.advanceBtn.instance)
                task.wait(0.5)
            end
        end

        -- Polling verifikasi target penerima dari data game
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
            warn("[NYU HUB] Target job belum terverifikasi setelah dialog selesai. Mengulang siklus...")
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

        -- ----------------------------------------------------
        -- STATE 8: DELIVER
        -- ----------------------------------------------------
        UpdateStatus("DELIVER", "Teleport ke penerima: " .. detectedTarget, detectedTarget)
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

        if targetModel then
            local prompt = targetModel:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and fireproximityprompt then
                pcall(function() fireproximityprompt(prompt) end)
            end
        end
        TryCompleteDelivery(detectedTarget)

        -- ----------------------------------------------------
        -- STATE 9: VERIFY_DELIVERY
        -- ----------------------------------------------------
        UpdateStatus("VERIFY_DELIVERY", "Paket diserahkan ke " .. detectedTarget, detectedTarget)
        task.wait(1.5)
        if not AutoFarmEnabled then break end

        -- ----------------------------------------------------
        -- STATE 10: RETURN_TO_START (Kembali ke Bunta)
        -- ----------------------------------------------------
        UpdateStatus("RETURN_TO_START", "Kembali ke Fujiwara Bunta untuk job berikutnya...")
        local backArrived = TeleportToPosition(BUNTA_POSITION, 6)
        if not backArrived then
            warn("[NYU HUB] Verifikasi posisi kembali ke Bunta timeout. Melakukan re-pivot...")
            TeleportToPosition(BUNTA_POSITION, 4)
        end

        -- ----------------------------------------------------
        -- STATE 11: COOLDOWN (Tunggu tracker quest lama bersih)
        -- ----------------------------------------------------
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
