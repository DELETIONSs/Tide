--// Tide UI Library (Animated, Sidebar, Working Tabs)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

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
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

function Tide:Init(config)
    config = config or {}
    local uiName = config.Name or "Tide UI"
    local toggleKey = config.Key or Enum.KeyCode.RightControl

    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui.Name == "TideUI" then gui:Destroy() end
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "TideUI"
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame", gui)
    main.BackgroundColor3 = Theme.BackgroundMain
    main.Size = UDim2.new(0, 700, 0, 450)
    main.Position = UDim2.new(0.5, -350, 0.5, -225)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Name = "Main"
    dragify(main)
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    local sidebar = Instance.new("Frame", main)
    sidebar.BackgroundColor3 = Theme.BackgroundSecondary
    sidebar.Size = UDim2.new(0, 160, 1, 0)
    sidebar.Position = UDim2.new(0, 0, 0, 0)
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

    local tabButtonsLayout = Instance.new("UIListLayout", sidebar)
    tabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabButtonsLayout.Padding = UDim.new(0, 4)
    tabButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local contentHolder = Instance.new("Frame", main)
    contentHolder.BackgroundColor3 = Theme.BackgroundSecondary
    contentHolder.Size = UDim2.new(1, -160, 1, 0)
    contentHolder.Position = UDim2.new(0, 160, 0, 0)
    Instance.new("UICorner", contentHolder).CornerRadius = UDim.new(0, 8)

    local tabs = {}
    local activeTab = nil

    local Window = {}

    function Window:AddTab(tabName)
        local Tab = {}

        local button = Instance.new("TextButton", sidebar)
        button.Text = tabName
        button.Size = UDim2.new(1, -20, 0, 40)
        button.BackgroundColor3 = Theme.Accent
        button.TextColor3 = Theme.Text
        button.Font = Enum.Font.GothamBold
        button.TextSize = 16
        button.AutoButtonColor = false
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

        local container = Instance.new("Frame", contentHolder)
        container.Visible = false
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1

        local layout = Instance.new("UIListLayout", container)
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        button.MouseButton1Click:Connect(function()
            if activeTab then activeTab.Visible = false end
            container.Visible = true
            activeTab = container
        end)

        function Tab:AddButton(text, callback)
            local button = Instance.new("TextButton", container)
            button.Size = UDim2.new(1, -20, 0, 30)
            button.Position = UDim2.new(0, 10, 0, 0)
            button.BackgroundColor3 = Theme.Accent
            button.TextColor3 = Color3.new(1, 1, 1)
            button.Font = Enum.Font.Gotham
            button.TextSize = 14
            button.Text = text
            Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
            button.MouseButton1Click:Connect(callback)
        end

        function Tab:AddToggle(text, default, callback)
            local frame = Instance.new("Frame", container)
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
            toggle.Text = ""
            toggle.BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff
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

        tabs[tabName] = container
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
