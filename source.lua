--// Tide UI Library with Roblox Developer Dashboard Dark Theme
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Tide = {}

local Theme = {
    BackgroundMain = Color3.fromRGB(30, 30, 47),        -- #1e1e2f dark bluish
    BackgroundSecondary = Color3.fromRGB(42, 42, 61),   -- #2a2a3d
    Accent = Color3.fromRGB(58, 142, 230),              -- #3a8ee6
    AccentHover = Color3.fromRGB(72, 156, 244),         -- brighter blue hover
    Text = Color3.fromRGB(235, 235, 245),                -- off-white text
    ToggleOn = Color3.fromRGB(58, 142, 230),
    ToggleOff = Color3.fromRGB(75, 75, 90),
    Shadow = Color3.fromRGB(0, 0, 0),
}

local function dragify(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

function Tide:Init(config)
    config = config or {}
    local uiName = config.Name or "Tide UI"
    local toggleKey = config.Key or Enum.KeyCode.RightControl

    for _, child in ipairs(CoreGui:GetChildren()) do
        if child.Name == "TideUI" then child:Destroy() end
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "TideUI"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local main = Instance.new("Frame", gui)
    main.Name = "Main"
    main.Size = UDim2.new(0, 700, 0, 450)
    main.Position = UDim2.new(0.5, -350, 0.5, -225)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Theme.BackgroundMain
    main.BorderSizePixel = 0
    dragify(main)

    local mainUICorner = Instance.new("UICorner", main)
    mainUICorner.CornerRadius = UDim.new(0, 12)

    -- Topbar Frame
    local topbar = Instance.new("Frame", main)
    topbar.Size = UDim2.new(1, 0, 0, 40)
    topbar.Position = UDim2.new(0, 0, 0, 0)
    topbar.BackgroundColor3 = Theme.BackgroundSecondary
    topbar.BorderSizePixel = 0

    local topbarCorner = Instance.new("UICorner", topbar)
    topbarCorner.CornerRadius = UDim.new(0, 12)
    -- Round top corners only
    topbarCorner.Name = "TopbarCorner"

    -- Mask to flatten bottom corners
    local cornerMask = Instance.new("Frame", topbar)
    cornerMask.Size = UDim2.new(1, 0, 0, 10)
    cornerMask.Position = UDim2.new(0, 0, 1, -10)
    cornerMask.BackgroundColor3 = Theme.BackgroundMain
    cornerMask.BorderSizePixel = 0

    -- Title Label
    local titleLabel = Instance.new("TextLabel", topbar)
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Position = UDim2.new(0, 14, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Text = uiName
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.RichText = false

    -- Close Button
    local closeButton = Instance.new("TextButton", topbar)
    closeButton.Size = UDim2.new(0, 40, 0, 28)
    closeButton.Position = UDim2.new(1, -48, 0, 6)
    closeButton.BackgroundColor3 = Theme.Accent
    closeButton.Text = "✕"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 20
    closeButton.TextColor3 = Theme.Text
    closeButton.AutoButtonColor = false
    closeButton.Name = "CloseButton"
    closeButton.ZIndex = 5
    Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)

    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Theme.AccentHover
        }):Play()
    end)
    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Theme.Accent
        }):Play()
    end)
    closeButton.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)

    -- Sidebar
    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0, 160, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = Theme.BackgroundSecondary
    sidebar.BorderSizePixel = 0
    local sidebarCorner = Instance.new("UICorner", sidebar)
    sidebarCorner.CornerRadius = UDim.new(0, 10)

    local tabLayout = Instance.new("UIListLayout", sidebar)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Content Holder
    local contentHolder = Instance.new("Frame", main)
    contentHolder.Size = UDim2.new(1, -160, 1, -40)
    contentHolder.Position = UDim2.new(0, 160, 0, 40)
    contentHolder.BackgroundColor3 = Theme.BackgroundSecondary
    contentHolder.BorderSizePixel = 0
    local contentCorner = Instance.new("UICorner", contentHolder)
    contentCorner.CornerRadius = UDim.new(0, 10)

    local tabs = {}
    local activeTab

    local Window = {}

    function Window:AddTab(tabName)
        local Tab = {}

        local tabButton = Instance.new("TextButton", sidebar)
        tabButton.Text = tabName
        tabButton.Size = UDim2.new(1, -20, 0, 38)
        tabButton.BackgroundColor3 = Theme.BackgroundMain
        tabButton.TextColor3 = Theme.Text
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.TextSize = 15
        tabButton.AutoButtonColor = false
        Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 6)

        tabButton.MouseEnter:Connect(function()
            TweenService:Create(tabButton, TweenInfo.new(0.25), {
                BackgroundColor3 = Theme.Accent
            }):Play()
        end)
        tabButton.MouseLeave:Connect(function()
            if activeTab ~= tabs[tabName] then
                TweenService:Create(tabButton, TweenInfo.new(0.25), {
                    BackgroundColor3 = Theme.BackgroundMain
                }):Play()
            end
        end)

        local tabContainer = Instance.new("Frame", contentHolder)
        tabContainer.Size = UDim2.new(1, 0, 1, 0)
        tabContainer.BackgroundTransparency = 1
        tabContainer.Visible = false

        local layout = Instance.new("UIListLayout", tabContainer)
        layout.Padding = UDim.new(0, 10)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        tabButton.MouseButton1Click:Connect(function()
            if activeTab then
                activeTab.Visible = false
                -- Reset previous tab button bg
                for _, btn in pairs(sidebar:GetChildren()) do
                    if btn:IsA("TextButton") then
                        TweenService:Create(btn, TweenInfo.new(0.25), {
                            BackgroundColor3 = Theme.BackgroundMain
                        }):Play()
                    end
                end
            end
            tabContainer.Visible = true
            activeTab = tabContainer
            TweenService:Create(tabButton, TweenInfo.new(0.25), {
                BackgroundColor3 = Theme.Accent
            }):Play()
        end)

        function Tab:AddButton(text, callback)
            local button = Instance.new("TextButton", tabContainer)
            button.Text = text
            button.Size = UDim2.new(1, -30, 0, 36)
            button.BackgroundColor3 = Theme.Accent
            button.TextColor3 = Theme.Text
            button.Font = Enum.Font.Gotham
            button.TextSize = 15
            button.AutoButtonColor = false
            button.AnchorPoint = Vector2.new(0, 0)
            button.Position = UDim2.new(0, 15, 0, 0)
            local uic = Instance.new("UICorner", button)
            uic.CornerRadius = UDim.new(0, 8)

            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Theme.AccentHover
                }):Play()
            end)
            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Theme.Accent
                }):Play()
            end)
            button.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)

            return button
        end

        tabs[tabName] = tabContainer
        return Tab
    end

    -- Initialize with default tab
    local defaultTab = Window:AddTab("Main")
    defaultTab:AddButton("Hello World", function()
        print("Button clicked!")
    end)
    -- Set default tab visible
    local firstTabButton = sidebar:FindFirstChildWhichIsA("TextButton")
    if firstTabButton then
        firstTabButton.BackgroundColor3 = Theme.Accent
        tabs["Main"].Visible = true
        activeTab = tabs["Main"]
    end

    -- Toggle UI visibility on key press
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == toggleKey then
            gui.Enabled = not gui.Enabled
        end
    end)

    return Window
end

return Tide
