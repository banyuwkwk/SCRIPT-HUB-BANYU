
--[[
    NYU HUB
    Version: 1.0.0
    Repository: SCRIPT-HUB-BANYU
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
    warn("[Nyu Hub] LocalPlayer tidak tersedia.")
    return
end

local CONFIG = {
    Name = "NYU HUB",
    Version = "1.0.0",

    Colors = {
        Background = Color3.fromRGB(29, 30, 33),
        Sidebar = Color3.fromRGB(23, 24, 27),
        Surface = Color3.fromRGB(39, 40, 44),
        Text = Color3.fromRGB(245, 245, 245),
        Muted = Color3.fromRGB(175, 178, 185),
        Border = Color3.fromRGB(55, 56, 61),
    },
}

local playerGui = player:WaitForChild("PlayerGui")

local previous = playerGui:FindFirstChild("NyuHub")
if previous then
    previous:Destroy()
end

local function create(className, properties, parent)
    local instance = Instance.new(className)

    for property, value in pairs(properties) do
        instance[property] = value
    end

    instance.Parent = parent
    return instance
end

local function round(instance, radius)
    create("UICorner", {
        CornerRadius = UDim.new(0, radius),
    }, instance)
end

local gui = create("ScreenGui", {
    Name = "NyuHub",
    ResetOnSpawn = false,
    DisplayOrder = 100,
}, playerGui)

local main = create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(560, 350),
    Position = UDim2.new(0.5, -280, 0.5, -175),
    BackgroundColor3 = CONFIG.Colors.Background,
    BorderSizePixel = 0,
    Active = true,
}, gui)
round(main, 10)

local header = create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = CONFIG.Colors.Sidebar,
    BorderSizePixel = 0,
    Active = true,
}, main)
round(header, 10)

create("TextLabel", {
    Position = UDim2.fromOffset(16, 0),
    Size = UDim2.new(1, -100, 1, 0),
    BackgroundTransparency = 1,
    Text = CONFIG.Name,
    TextColor3 = CONFIG.Colors.Text,
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local minimize = create("TextButton", {
    Name = "Minimize",
    Position = UDim2.new(1, -42, 0, 9),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = CONFIG.Colors.Surface,
    Text = "—",
    TextColor3 = CONFIG.Colors.Text,
    TextSize = 17,
    Font = Enum.Font.Gotham,
}, header)
round(minimize, 6)

local sidebar = create("Frame", {
    Name = "Sidebar",
    Position = UDim2.fromOffset(0, 48),
    Size = UDim2.new(0, 145, 1, -48),
    BackgroundColor3 = CONFIG.Colors.Sidebar,
    BorderSizePixel = 0,
}, main)

local content = create("Frame", {
    Name = "Content",
    Position = UDim2.fromOffset(145, 48),
    Size = UDim2.new(1, -145, 1, -48),
    BackgroundTransparency = 1,
}, main)

local pageTitle = create("TextLabel", {
    Name = "PageTitle",
    Position = UDim2.fromOffset(22, 22),
    Size = UDim2.new(1, -44, 0, 30),
    BackgroundTransparency = 1,
    Text = "Home",
    TextColor3 = CONFIG.Colors.Text,
    TextSize = 22,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, content)

local description = create("TextLabel", {
    Name = "Description",
    Position = UDim2.fromOffset(22, 62),
    Size = UDim2.new(1, -44, 0, 75),
    BackgroundTransparency = 1,
    Text = "Welcome, " .. player.DisplayName
        .. "\nNyu Hub v" .. CONFIG.Version,
    TextColor3 = CONFIG.Colors.Muted,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, content)

local pages = {
    {
        Name = "Home",
        Description = function()
            return "Welcome, " .. player.DisplayName
                .. "\nNyu Hub v" .. CONFIG.Version
        end,
    },
    {
        Name = "Player",
        Description = function()
            return "Username: " .. player.Name
                .. "\nDisplay name: " .. player.DisplayName
        end,
    },
    {
        Name = "Settings",
        Description = function()
            return "Version: " .. CONFIG.Version
                .. "\nTheme: Dark Charcoal"
        end,
    },
}

for index, page in ipairs(pages) do
    local button = create("TextButton", {
        Name = page.Name .. "Button",
        Position = UDim2.fromOffset(10, 62 + (index - 1) * 43),
        Size = UDim2.new(1, -20, 0, 35),
        BackgroundColor3 = CONFIG.Colors.Surface,
        BorderSizePixel = 0,
        Text = page.Name,
        TextColor3 = CONFIG.Colors.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = true,
    }, sidebar)
    round(button, 6)

    button.Activated:Connect(function()
        pageTitle.Text = page.Name
        description.Text = page.Description()
    end)
end

local minimized = false

minimize.Activated:Connect(function()
    minimized = not minimized

    sidebar.Visible = not minimized
    content.Visible = not minimized

    main.Size = minimized
        and UDim2.fromOffset(220, 48)
        or UDim2.fromOffset(560, 350)

    minimize.Text = minimized and "+" or "—"
end)

-- Drag window with mouse or touch.
local dragging = false
local dragStart
local startPosition
local dragInput

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

print("[Nyu Hub] UI initialized.")
