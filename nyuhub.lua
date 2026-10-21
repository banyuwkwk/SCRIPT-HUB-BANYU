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

local function TryTriggerPrompt(model)
    if not model then return false end
    local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and fireproximityprompt then
        fireproximityprompt(prompt)
        return true
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
            print("[NYU HUB] Invoked CompleteDeliveryQuest for:", targetNPCName)
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
    print("========== [NYU HUB] QUEST & CLIENT DIAGNOSTICS ==========")
    local attrs = LocalPlayer:GetAttributes()
    local attrCount = 0
    for k, v in pairs(attrs) do
        attrCount = attrCount + 1
        print(string.format("  [Player Attribute] %s = %s (%s)", tostring(k), tostring(v), typeof(v)))
    end
    if attrCount == 0 then
        print("  [Player Attribute] Tidak ada attribute pada LocalPlayer.")
    end

    print("  [Player Children]:")
    for _, child in ipairs(LocalPlayer:GetChildren()) do
        if child:IsA("ValueBase") or child:IsA("Folder") or child:IsA("Configuration") then
            print(string.format("    - %s (%s)", child.Name, child.ClassName))
            for _, subChild in ipairs(child:GetChildren()) do
                if subChild:IsA("ValueBase") then
                    print(string.format("        * %s = %s", subChild.Name, tostring(subChild.Value)))
                end
            end
        end
    end

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        print("  [Quest-related ScreenGuis]:")
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                local nameLower = gui.Name:lower()
                if nameLower:find("quest") or nameLower:find("job") or nameLower:find("delivery") or nameLower:find("mission") or nameLower:find("dialog") then
                    print(string.format("    - Active GUI: %s", gui.Name))
                    for _, desc in ipairs(gui:GetDescendants()) do
                        if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and desc.Visible then
                            local text = desc.Text:gsub("%s+", " "):match("^%s*(.-)%s*$")
                            if #text > 0 and #text < 80 then
                                print(string.format("        [%s] '%s'", desc.Name, text))
                            end
                        end
                    end
                end
            end
        end
    end

    local workspace = game:GetService("Workspace")
    local npcFolder = workspace:FindFirstChild("NPCs")
    local buntaModel = npcFolder and npcFolder:FindFirstChild(BUNTA_NAME) or workspace:FindFirstChild(BUNTA_NAME)
    if buntaModel then
        local prompt = buntaModel:FindFirstChildWhichIsA("ProximityPrompt", true)
        print(string.format("  [NPC %s] Ada di Workspace. ProximityPrompt: %s", BUNTA_NAME, prompt and (prompt.ActionText .. " [" .. prompt.ObjectText .. "]") or "TIDAK ADA"))
    else
        print(string.format("  [NPC %s] Belum ditemukan di Workspace.NPCs.", BUNTA_NAME))
    end
    print("==========================================================")
end

local function RunAutoFarmCycle()
    while AutoFarmEnabled do
        -- TAHAP 1: Navigasi ke Fujiwara Bunta
        CurrentFarmState = "NAVIGATE_TO_BUNTA"
        print("[NYU HUB] State:", CurrentFarmState)
        
        local root = GetRootPart()
        if not root then
            task.wait(1)
            continue
        end

        SafeTeleport(CFrame.new(BUNTA_POSITION))

        local waitCount = 0
        while waitCount < 10 and AutoFarmEnabled do
            task.wait(0.1)
            waitCount = waitCount + 1
        end
        if not AutoFarmEnabled then break end

        -- TAHAP 2: Interaksi dengan Fujiwara Bunta
        CurrentFarmState = "INTERACTING_BUNTA"
        print("[NYU HUB] State:", CurrentFarmState)
        local buntaModel = FindNPCModel(BUNTA_NAME)
        if buntaModel then
            TryTriggerPrompt(buntaModel)
        end

        -- TAHAP 3: Deteksi Target Quest Aktif (Dengan Timeout & Polling)
        CurrentFarmState = "WAIT_FOR_JOB_TARGET"
        print("[NYU HUB] State:", CurrentFarmState)

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
            print("[NYU HUB] Target delivery belum terdeteksi. Silakan periksa via tombol Run Quest Diagnostics jika job perlu interaksi manual awal.")
            task.wait(2)
            continue
        end

        print(string.format("[NYU HUB] Target terdeteksi: '%s' via %s", detectedTarget, detectSource))
        Window:Notify({
            title = Config.Name,
            content = "Target: " .. detectedTarget,
        })

        -- TAHAP 4: Navigasi ke Penerima
        CurrentFarmState = "NAVIGATE_TO_RECEIVER"
        print("[NYU HUB] State:", CurrentFarmState, "Target:", detectedTarget)
        local targetModel = FindNPCModel(detectedTarget)
        if targetModel then
            local targetPart = targetModel:FindFirstChild("HumanoidRootPart") or targetModel.PrimaryPart or targetModel:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                SafeTeleport(targetPart.CFrame * CFrame.new(0, 0, 3))
            end
        else
            print(string.format("[NYU HUB] Model target '%s' belum ditemukan di Workspace. Mengirim sinyal penyelesaian.", detectedTarget))
        end

        local waitReceiver = 0
        while waitReceiver < 8 and AutoFarmEnabled do
            task.wait(0.1)
            waitReceiver = waitReceiver + 1
        end
        if not AutoFarmEnabled then break end

        -- TAHAP 5: Selesaikan Delivery
        CurrentFarmState = "COMPLETING_DELIVERY"
        print("[NYU HUB] State:", CurrentFarmState)
        if targetModel then
            TryTriggerPrompt(targetModel)
        end
        TryCompleteDelivery(detectedTarget)

        -- TAHAP 6: Jeda Siklus
        CurrentFarmState = "COOLDOWN"
        print("[NYU HUB] Siklus selesai. Jeda sebelum mengulang...")
        local cd = 3
        while cd > 0 and AutoFarmEnabled do
            task.wait(1)
            cd = cd - 1
        end
    end

    CurrentFarmState = "IDLE"
    print("[NYU HUB] State:", CurrentFarmState)
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
            CurrentFarmState = "IDLE"

            Window:Notify({
                title = Config.Name,
                content = "Auto Farm Tofu dimatikan.",
            })
            print("[NYU HUB] Auto Farm Tofu: OFF (Proses dihentikan)")
        end
    end,
})

-- 6.3 Tombol Diagnostik Status Quest
UtilitiesTab:CreateButton({
    name = "Run Quest Diagnostics",
    description = "Cek atribut player, GUI, dan status quest aktif di console (F9)",

    callback = function()
        Window:Notify({
            title = Config.Name,
            content = "Diagnostik dijalankan. Buka console F9.",
        })
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
