
local UI = {}

function UI.init()
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")

    local player = Players.LocalPlayer
    if not player then
        return
    end

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
    main.BackgroundColor3 = Color3.fromRGB(29, 30, 33)
    main.BorderSizePixel = 0
    main.Active = true
    main.Parent = gui

    Instance.new("UICorner", main).CornerRadius =
        UDim.new(0, 10)

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = Color3.fromRGB(23, 24, 27)
    header.BorderSizePixel = 0
    header.Active = true
    header.Parent = main

    Instance.new("UICorner", header).CornerRadius =
        UDim.new(0, 10)

    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(16, 0)
    title.Size = UDim2.new(1, -120, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "NYU HUB"
    title.TextColor3 = Color3.fromRGB(245, 245, 245)
    title.TextSize = 17
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local minimize = Instance.new("TextButton")
    minimize.Name = "Minimize"
    minimize.Size = UDim2.fromOffset(34, 30)
    minimize.Position = UDim2.new(1, -44, 0, 9)
    minimize.BackgroundColor3 = Color3.fromRGB(45, 46, 50)
    minimize.Text = "—"
    minimize.TextColor3 = Color3.fromRGB(245, 245, 245)
    minimize.TextSize = 16
    minimize.Font = Enum.Font.Gotham
    minimize.Parent = header

    Instance.new("UICorner", minimize).CornerRadius =
        UDim.new(0, 6)

    local sidebar = Instance.new("Frame")
    sidebar.Position = UDim2.fromOffset(0, 48)
    sidebar.Size = UDim2.new(0, 140, 1, -48)
    sidebar.BackgroundColor3 = Color3.fromRGB(25, 26, 29)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Position = UDim2.fromOffset(140, 48)
    content.Size = UDim2.new(1, -140, 1, -48)
    content.BackgroundTransparency = 1
    content.Parent = main

    local pageTitle = Instance.new("TextLabel")
    pageTitle.Position = UDim2.fromOffset(22, 20)
    pageTitle.Size = UDim2.new(1, -44, 0, 30)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "Home"
    pageTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
    pageTitle.TextSize = 21
    pageTitle.Font = Enum.Font.GothamSemibold
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.Parent = content

    local description = Instance.new("TextLabel")
    description.Position = UDim2.fromOffset(22, 58)
    description.Size = UDim2.new(1, -44, 0, 50)
    description.BackgroundTransparency = 1
    description.Text = "Welcome, " .. player.DisplayName
    description.TextColor3 = Color3.fromRGB(175, 178, 185)
    description.TextSize = 13
    description.Font = Enum.Font.Gotham
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextYAlignment = Enum.TextYAlignment.Top
    description.Parent = content

    local pages = {
        {name = "Home", y = 14},
        {name = "Player", y = 58},
        {name = "Settings", y = 102},
    }

    for _, page in ipairs(pages) do
        local button = Instance.new("TextButton")
        button.Name = page.name
        button.Position = UDim2.fromOffset(10, page.y)
        button.Size = UDim2.new(1, -20, 0, 36)
        button.BackgroundColor3 = Color3.fromRGB(35, 36, 40)
        button.BorderSizePixel = 0
        button.Text = page.name
        button.TextColor3 = Color3.fromRGB(225, 226, 230)
        button.TextSize = 13
        button.Font = Enum.Font.GothamMedium
        button.Parent = sidebar

        Instance.new("UICorner", button).CornerRadius =
            UDim.new(0, 6)

        button.Activated:Connect(function()
            pageTitle.Text = page.name

            if page.name == "Home" then
                description.Text =
                    "Welcome, " .. player.DisplayName
            elseif page.name == "Player" then
                description.Text =
                    "Username: " .. player.Name ..
                    "\nDisplay name: " .. player.DisplayName
            else
                description.Text =
                    "Nyu Hub v1.0\nTheme: Dark Charcoal"
            end
        end)
    end

    local minimized = false

    minimize.Activated:Connect(function()
        minimized = not minimized
        sidebar.Visible = not minimized
        content.Visible = not minimized
        main.Size = minimized
            and UDim2.fromOffset(220, 48)
            or UDim2.fromOffset(560, 340)
        minimize.Text = minimized and "+" or "—"
    end)

    -- Drag menggunakan input mouse atau sentuhan.
    local dragging = false
    local dragStart
    local startPosition

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart

            main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    print("[Nyu Hub] UI initialized")
end

return UI
