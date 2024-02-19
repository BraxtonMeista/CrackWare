local defaultColor = Color3.new(0.1, 0.1, 0.1)
local toggleColor = Color3.fromRGB(114, 137, 218) 
l
local NovaWare = Instance.new("ScreenGui")
NovaWare.Parent = CoreGui

local function MakeDraggable(frame)--\\Probably Should Just Used .Draggable
    local dragging
    local dragStart
    local startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.Touch and dragging then
            update(input)
        end
    end)
end


local function CreateTab(options)
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(0.15, 0, 0.07, 0)
    tabFrame.Position = options.Position or UDim2.new(0.5, 0, 0.2, 0)
    tabFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    tabFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    tabFrame.BorderSizePixel = 0
    tabFrame.Parent = NovaWare
 
 
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0.3, 0)
    topCorner.Parent = tabFrame
    
    
    local FrameCorner = Instance.new("Frame")
    FrameCorner.Size = UDim2.new(1, 0, 0.5, 0) 
    FrameCorner.Position = UDim2.new(0, 0, 0.5, 0)
    FrameCorner.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1) 
    FrameCorner.BorderSizePixel = 0
    FrameCorner.Parent = tabFrame
    
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 23, 0, 23)
    icon.Position = UDim2.new(0, 1, 0, -12) 
    icon.Image = options.Icon or "" 
    icon.BackgroundTransparency = 1
    icon.Parent = FrameCorner
    
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.8, 0, 1, 0)
    textLabel.Position = UDim2.new(-0.09, 0, -0.4, 0) 
    textLabel.Text = options.Name or "Tab"
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 20 
    textLabel.Parent = FrameCorner
    
    
    MakeDraggable(tabFrame)
    
    return tabFrame
end

local function CreateToggle(options)
    local column = options.Column or 1
    local yOffset = 0
    
    if options.Parent then
        yOffset = options.Parent.Size.Y.Offset 
        for _, child in ipairs(options.Parent:GetChildren()) do
            if child:IsA("TextButton") then
                yOffset = yOffset + child.Size.Y.Offset
            end
        end
    end
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 0, 30)
    toggleButton.Position = UDim2.new(0, 0, 1, yOffset) 
    toggleButton.Text = ""
    toggleButton.BackgroundColor3 = defaultColor
    toggleButton.BorderSizePixel = 0
    toggleButton.AutoButtonColor = false
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextSize = 0
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.TextXAlignment = Enum.TextXAlignment.Left 
    toggleButton.Parent = options.Parent or frame
    
    local toggleText = Instance.new("TextLabel")
    toggleText.Size = UDim2.new(1, 0, 1, 0)
    toggleText.Position = UDim2.new(0, 5, 0, 0) 
    toggleText.BackgroundTransparency = 1
    toggleText.Text = options.Name or "Toggle"
    toggleText.TextColor3 = Color3.new(1, 1, 1)
    toggleText.Font = Enum.Font.SourceSansBold
    toggleText.TextSize = 17
    toggleText.TextXAlignment = Enum.TextXAlignment.Left
    toggleText.Parent = toggleButton
    
    local function updateToggleState()
        if options.Value then
            game:GetService("TweenService"):Create(toggleButton, TweenInfo.new(0.3), {BackgroundColor3 = toggleColor}):Play()
        else
            game:GetService("TweenService"):Create(toggleButton, TweenInfo.new(0.3), {BackgroundColor3 = defaultColor}):Play()
        end
    end

    local function toggleCallback()
        options.Value = not options.Value
        updateToggleState()
        if options.Callback then
            options.Callback(options.Value)
        end
        
        if options.SaveToFile then
            local file = options.SaveToFile
            local data = {}
            if isfile(file) then
                pcall(function()
                    data = game:GetService("HttpService"):JSONDecode(readfile(file))
                end)
            end
            data[options.Name] = options.Value
            writefile(file, game:GetService("HttpService"):JSONEncode(data))
            print("Saved settings:", options.Name, options.Value)
        end
    end
    
    toggleButton.MouseButton1Click:Connect(toggleCallback)
    
   
    if options.LoadFromFile then
        local file = options.LoadFromFile
        if isfile(file) then
            local data = {}
            pcall(function()
                data = game:GetService("HttpService"):JSONDecode(readfile(file))
            end)
            if data[options.Name] ~= nil then
                options.Value = data[options.Name]
                updateToggleState()
                if options.Callback then
                    options.Callback(options.Value)
                end
                print("Loaded settings:", options.Name, options.Value)
            end
        end
    end
end


local function CreateTabToggle()
    local isVisible = false
    
    local tabToggle = Instance.new("TextButton")
    tabToggle.Size = UDim2.new(0, 50, 0, 50)
    tabToggle.Position = UDim2.new(1, -60, 0.5, -25) 
    tabToggle.AnchorPoint = Vector2.new(1, 0.5) 
    tabToggle.Text = "NV"
    tabToggle.Font = Enum.Font.SourceSansBold
    tabToggle.FontSize = Enum.FontSize.Size14
    tabToggle.TextColor3 = Color3.new(1, 1, 1)
    tabToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    tabToggle.TextSize = 25
    tabToggle.BorderSizePixel = 0
    tabToggle.AutoButtonColor = false
    tabToggle.Active = true
    tabToggle.Draggable = true
    tabToggle.Parent = NovaWare
    
    local uiCorners = Instance.new("UICorner")
    uiCorners.CornerRadius = UDim.new(0.1, 0)
    uiCorners.Parent = tabToggle
    
    local function toggleTabs()
        isVisible = not isVisible
        for _, tab in ipairs(NovaWare:GetChildren()) do
            if tab:IsA("Frame") then
                tab.Visible = isVisible
            end
        end
    end
    
    tabToggle.MouseButton1Click:Connect(toggleTabs)
end

local TabToggle = CreateTabToggle()
