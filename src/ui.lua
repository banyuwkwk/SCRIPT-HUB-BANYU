
local UI = {}

function UI.create(player, config)
    local playerGui = player:WaitForChild("PlayerGui")

    local oldGui = playerGui:FindFirstChild("NyuHub")
    if oldGui then
        oldGui:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "NyuHub"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 100
    gui.Parent = playerGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.fromOffset(560, 340)
    main.Position = UDim2.new(0.5, -280, 0.5, -170)
    main.BackgroundColor3 = config.Theme.Background
    main.BorderSizePixel = 0
    main.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 140, 1, 0)
    sidebar.BackgroundColor3 = config.Theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 48)
    title.Position = UDim2.fromOffset(12, 8)
    title.BackgroundTransparency = 1
    title.Text = string.upper(config.Name)
    title.TextColor3 = config.Theme.Text
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = sidebar

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Position = UDim2.fromOffset(140, 0)
    content.Size = UDim2.new(1, -140, 1, 0)
    content.BackgroundTransparency = 1
    content.Parent = main

    local pageTitle = Instance.new("TextLabel")
    pageTitle.Name = "PageTitle"
    pageTitle.Position = UDim2.fromOffset(22, 20)
    pageTitle.Size = UDim2.new(1, -44, 0, 32)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "Home"
    pageTitle.TextColor3 = config.Theme.Text
    pageTitle.TextSize = 21
    pageTitle.Font = Enum.Font.GothamSemibold
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.Parent = content

    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Position = UDim2.fromOffset(22, 60)
    description.Size = UDim2.new(1, -44, 0, 60)
    description.BackgroundTransparency = 1
    description.Text = "Welcome to Nyu Hub"
    description.TextColor3 = config.Theme.Muted
    description.TextSize = 13
    description.Font = Enum.Font.Gotham
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Parent = content

    local pages = {"Home", "Player", "Settings"}

    for index, name in ipairs(pages) do
        local button = Instance.new("TextButton")
        button.Name = name .. "Button"
        button.Position = UDim2.fromOffset(10, 64 + (index - 1) * 42)
        button.Size = UDim2.new(1, -20, 0, 34)
        button.BackgroundColor3 = config.Theme.Surface
        button.BorderSizePixel = 0
        button.Text = name
        button.TextColor3 = config.Theme.Text
        button.TextSize = 13
        button.Font = Enum.Font.GothamMedium
        button.Parent = sidebar

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button

        button.Activated:Connect(function()
            pageTitle.Text = name

            if name == "Home" then
                description.Text = "Welcome to Nyu Hub"
            elseif name == "Player" then
                description.Text = "Player information and status"
            else
                description.Text = "Hub preferences and configuration"
            end
        end)
    end

    local minimize = Instance.new("TextButton")
    minimize.Name = "MinimizeButton"
    minimize.Position = UDim2.new(1, -42, 0, 12)
    minimize.Size = UDim2.fromOffset(28, 28)
    minimize.BackgroundColor3 = config.Theme.Surface
    minimize.Text = "—"
    minimize.TextColor3 = config.Theme.Text
    minimize.TextSize = 16
    minimize.Font = Enum.Font.Gotham
    minimize.Parent = content

    local minimized = false

    minimize.Activated:Connect(function()
        minimized = not minimized
        sidebar.Visible = not minimized
        content.Visible = not minimized
        main.Size = minimized
            and UDim2.fromOffset(200, 48)
            or UDim2.fromOffset(560, 340)

        minimize.Text = minimized and "+" or "—"
    end)

    return gui
end

return UI
