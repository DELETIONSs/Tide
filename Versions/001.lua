--// Tide UI Library (Orion-style API, Animated)
--// Version 1 - Animated & Improved

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
    Text = Color3.fromRGB(240, 240, 240),
    ToggleOn = Color3.fromRGB(78, 134, 78),
    ToggleOff = Color3.fromRGB(50, 50, 50),
    ButtonHover = Color3.fromRGB(60, 100, 140)
}

local function TweenObject(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function dragify(frame)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        TweenObject(frame, {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }, 0.1)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
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
    main.Name = "Main"
    main.Size = UDim2.new(0, 600, 0, 400)
    main.Position = UDim2.new(0.5, -300, 0.5, 0)
    main.AnchorPoint = Vector2.new(0.5, 0)
    main.BackgroundColor3 = Theme.BackgroundMain
    main.BackgroundTransparency = 1
    dragify(main)

    TweenObject(main, {BackgroundTransparency = 0}, 0.5)

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", main)
    title.Text = uiName
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20

    local content = Instance.new("Frame", main)
    content.Name = "Content"
    content.Position = UDim2.new(0, 0, 0, 40)
    content.Size = UDim2.new(1, 0, 1, -40)
    content.BackgroundColor3 = Theme.BackgroundSecondary
    content.BackgroundTransparency = 1
    TweenObject(content, {BackgroundTransparency = 0}, 0.5)
    Instance.new("UICorner", content).CornerRadius = UDim.new(0, 8)

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local Window = {}

    function Window:AddTab(tabName)
        local Tab = {}

        local section = Instance.new("Frame", content)
        section.Size = UDim2.new(1, -20, 0, 0)
        section.BackgroundTransparency = 1

        local tabLabel = Instance.new("TextLabel", section)
        tabLabel.Text = tabName
        tabLabel.Size = UDim2.new(1, 0, 0, 30)
        tabLabel.TextColor3 = Theme.Accent
        tabLabel.Font = Enum.Font.GothamBold
        tabLabel.TextSize = 18
        tabLabel.BackgroundTransparency = 1

        local tabLayout = Instance.new("UIListLayout", section)
        tabLayout.Padding = UDim.new(0, 6)
        tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

        function Tab:AddButton(text, callback)
            local button = Instance.new("TextButton", section)
            button.Size = UDim2.new(1, 0, 0, 30)
            button.Text = text
            button.BackgroundColor3 = Theme.Accent
            button.TextColor3 = Color3.new(1, 1, 1)
            button.Font = Enum.Font.Gotham
            button.TextSize = 14
            Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
            button.MouseEnter:Connect(function()
                TweenObject(button, {BackgroundColor3 = Theme.ButtonHover})
            end)
            button.MouseLeave:Connect(function()
                TweenObject(button, {BackgroundColor3 = Theme.Accent})
            end)
            button.MouseButton1Click:Connect(callback)
        end

        function Tab:AddToggle(text, default, callback)
            local frame = Instance.new("Frame", section)
            frame.Size = UDim2.new(1, 0, 0, 30)
            frame.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", frame)
            label.Text = text
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.TextColor3 = Theme.Text
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.BackgroundTransparency = 1

            local toggle = Instance.new("TextButton", frame)
            toggle.Size = UDim2.new(0.3, 0, 1, 0)
            toggle.Position = UDim2.new(0.7, 0, 0, 0)
            toggle.Text = ""
            toggle.BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff
            Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

            local state = default
            toggle.MouseButton1Click:Connect(function()
                state = not state
                TweenObject(toggle, {
                    BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
                })
                callback(state)
            end)
        end

        return Tab
    end

    local visible = true
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            visible = not visible
            gui.Enabled = visible
        end
    end)

    return Window
end

return Tide
