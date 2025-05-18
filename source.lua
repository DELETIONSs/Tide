--// Tide UI Library (Refactored, Animated, Sidebar, Working Tabs)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Tide = {}

local Theme = {
    BackgroundMain = Color3.fromRGB(33, 33, 36),
    BackgroundSecondary = Color3.fromRGB(29, 30, 37),
    Accent = Color3.fromRGB(48, 74, 104),
    AccentHover = Color3.fromRGB(58, 84, 124),
    Text = Color3.fromRGB(240, 240, 240),
    ToggleOn = Color3.fromRGB(78, 134, 78),
    ToggleOff = Color3.fromRGB(36, 36, 36)
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

    -- Remove previous instances
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
    dragify(main)
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0, 160, 1, 0)
    sidebar.Position = UDim2.new(0, 0, 0, 0)
    sidebar.BackgroundColor3 = Theme.BackgroundSecondary
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

    local tabLayout = Instance.new("UIListLayout", sidebar)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local contentHolder = Instance.new("Frame", main)
    contentHolder.Size = UDim2.new(1, -160, 1, 0)
    contentHolder.Position = UDim2.new(0, 160, 0, 0)
    contentHolder.BackgroundColor3 = Theme.BackgroundSecondary
    Instance.new("UICorner", contentHolder).CornerRadius = UDim.new(0, 8)

    local tabs = {}
    local activeTab

    local Window = {}

    function Window:AddTab(tabName)
        local Tab = {}

        local tabButton = Instance.new("TextButton", sidebar)
        tabButton.Text = tabName
        tabButton.Size = UDim2.new(1, -20, 0, 40)
        tabButton.BackgroundColor3 = Theme.Accent
        tabButton.TextColor3 = Theme.Text
        tabButton.Font = Enum.Font.GothamBold
        tabButton.TextSize = 16
        tabButton.AutoButtonColor = false
        Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 6)

        tabButton.MouseEnter:Connect(function()
            TweenService:Create(tabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.AccentHover
            }):Play()
        end)

        tabButton.MouseLeave:Connect(function()
            TweenService:Create(tabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Accent
            }):Play()
        end)

        local tabContainer = Instance.new("Frame", contentHolder)
        tabContainer.Size = UDim2.new(1, 0, 1, 0)
        tabContainer.BackgroundTransparency = 1
        tabContainer.Visible = false

        local layout = Instance.new("UIListLayout", tabContainer)
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        tabButton.MouseButton1Click:Connect(function()
            if activeTab then activeTab.Visible = false end
            tabContainer.Visible = true
            activeTab = tabContainer
        end)

        function Tab:AddButton(text, callback)
            local button = Instance.new("TextButton", tabContainer)
            button.Text = text
            button.Size = UDim2.new(1, -20, 0, 30)
            button.Position = UDim2.new(0, 10, 0, 0)
            button.BackgroundColor3 = Theme.Accent
            button.TextColor3 = Theme.Text
            button.Font = Enum.Font.Gotham
            button.TextSize = 14
            Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

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

            button.MouseButton1Click:Connect(callback)
        end

        function Tab:AddToggle(text, default, callback)
            local frame = Instance.new("Frame", tabContainer)
            frame.Size = UDim2.new(1, -20, 0, 30)
            frame.BackgroundTransparency = 1
            frame.Position = UDim2.new(0, 10, 0, 0)

            local label = Instance.new("TextLabel", frame)
            label.Text = text
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.TextColor3 = Theme.Text
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left

            local toggle = Instance.new("TextButton", frame)
            toggle.Size = UDim2.new(0.3, 0, 1, 0)
            toggle.Position = UDim2.new(0.7, 0, 0, 0)
            toggle.BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff
            toggle.Text = ""
            Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

            local state = default
            toggle.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(toggle, TweenInfo.new(0.2), {
                    BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
                }):Play()
                callback(state)
            end)
        end

        tabs[tabName] = tabContainer
        return Tab
    end

    local visible = true
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            visible = not visible
            gui.Enabled = visible
        end
    end)

    return Window
end

return Tide
