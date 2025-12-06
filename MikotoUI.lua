--[[
    UILibrary v1.0
    Librería universal para crear interfaces de usuario en Roblox
    Compatible con cualquier executor que soporte loadstring
]]

local UILibrary = {}

-- Servicios
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Utilidades
local function tween(object, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function makeDraggable(frame, dragHandle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    dragHandle = dragHandle or frame
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            tween(frame, {
                Position = UDim2.new(
                    framePos.X.Scale,
                    framePos.X.Offset + delta.X,
                    framePos.Y.Scale,
                    framePos.Y.Offset + delta.Y
                )
            }, 0.1)
        end
    end)
end

-- Función principal para crear ventana
function UILibrary:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "UI Library"
    local windowSize = config.Size or UDim2.new(0, 500, 0, 400)
    
    -- Crear ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UILibrary_" .. math.random(1000, 9999)
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    -- Proteger GUI si es posible
    pcall(function()
        screenGui.Parent = CoreGui
    end)
    
    if screenGui.Parent ~= CoreGui then
        screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = windowSize
    mainFrame.Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame
    
    -- Sombra
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = 0
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.Parent = mainFrame
    
    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowName
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Botón de cerrar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(0.3)
        screenGui:Destroy()
    end)
    
    closeButton.MouseEnter:Connect(function()
        tween(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.2)
    end)
    
    closeButton.MouseLeave:Connect(function()
        tween(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}, 0.2)
    end)
    
    -- Container de pestañas
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 120, 1, -50)
    tabContainer.Position = UDim2.new(0, 10, 0, 45)
    tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 5)
    tabPadding.PaddingLeft = UDim.new(0, 5)
    tabPadding.PaddingRight = UDim.new(0, 5)
    tabPadding.Parent = tabContainer
    
    -- Container de contenido
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -145, 1, -50)
    contentContainer.Position = UDim2.new(0, 135, 0, 45)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame
    
    -- Hacer draggable
    makeDraggable(mainFrame, titleBar)
    
    -- Animación de entrada
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    tween(mainFrame, {Size = windowSize}, 0.4)
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    function Window:CreateTab(tabName)
        local Tab = {}
        Tab.Name = tabName
        Tab.Elements = {}
        
        -- Botón de pestaña
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(1, 0, 0, 35)
        tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        tabButton.BorderSizePixel = 0
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = tabContainer
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 5)
        buttonCorner.Parent = tabButton
        
        -- Contenido de la pestaña
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
        tabContent.Visible = false
        tabContent.Parent = contentContainer
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.Parent = tabContent
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingTop = UDim.new(0, 5)
        contentPadding.PaddingLeft = UDim.new(0, 5)
        contentPadding.PaddingRight = UDim.new(0, 5)
        contentPadding.Parent = tabContent
        
        tabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tween(tab.Button, {BackgroundColor3 = Color3.fromRGB(35, 35, 45), TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
            end
            
            tabContent.Visible = true
            Window.CurrentTab = Tab
            tween(tabButton, {BackgroundColor3 = Color3.fromRGB(60, 120, 220), TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        end)
        
        tabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                tween(tabButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}, 0.2)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                tween(tabButton, {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}, 0.2)
            end
        end)
        
        Tab.Button = tabButton
        Tab.Content = tabContent
        
        -- Función para añadir botón
        function Tab:AddButton(buttonConfig)
            local buttonText = buttonConfig.Name or "Button"
            local callback = buttonConfig.Callback or function() end
            
            local button = Instance.new("TextButton")
            button.Name = buttonText
            button.Size = UDim2.new(1, -10, 0, 35)
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            button.BorderSizePixel = 0
            button.Text = buttonText
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 14
            button.Font = Enum.Font.Gotham
            button.Parent = tabContent
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = button
            
            button.MouseButton1Click:Connect(callback)
            
            button.MouseEnter:Connect(function()
                tween(button, {BackgroundColor3 = Color3.fromRGB(60, 120, 220)}, 0.2)
            end)
            
            button.MouseLeave:Connect(function()
                tween(button, {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}, 0.2)
            end)
            
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
            
            return button
        end
        
        -- Función para añadir toggle
        function Tab:AddToggle(toggleConfig)
            local toggleText = toggleConfig.Name or "Toggle"
            local defaultValue = toggleConfig.Default or false
            local callback = toggleConfig.Callback or function() end
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = toggleText
            toggleFrame.Size = UDim2.new(1, -10, 0, 35)
            toggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = tabContent
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 6)
            toggleCorner.Parent = toggleFrame
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(1, -50, 1, 0)
            toggleLabel.Position = UDim2.new(0, 10, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = toggleText
            toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleLabel.TextSize = 14
            toggleLabel.Font = Enum.Font.Gotham
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 40, 0, 20)
            toggleButton.Position = UDim2.new(1, -45, 0.5, -10)
            toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(60, 220, 120) or Color3.fromRGB(80, 80, 90)
            toggleButton.BorderSizePixel = 0
            toggleButton.Text = ""
            toggleButton.Parent = toggleFrame
            
            local toggleBtnCorner = Instance.new("UICorner")
            toggleBtnCorner.CornerRadius = UDim.new(1, 0)
            toggleBtnCorner.Parent = toggleButton
            
            local toggleIndicator = Instance.new("Frame")
            toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
            toggleIndicator.Position = defaultValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleIndicator.BorderSizePixel = 0
            toggleIndicator.Parent = toggleButton
            
            local indicatorCorner = Instance.new("UICorner")
            indicatorCorner.CornerRadius = UDim.new(1, 0)
            indicatorCorner.Parent = toggleIndicator
            
            local toggled = defaultValue
            
            toggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                
                tween(toggleButton, {
                    BackgroundColor3 = toggled and Color3.fromRGB(60, 220, 120) or Color3.fromRGB(80, 80, 90)
                }, 0.2)
                
                tween(toggleIndicator, {
                    Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                }, 0.2)
                
                callback(toggled)
            end)
            
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
            
            local Toggle = {}
            function Toggle:Set(value)
                toggled = value
                tween(toggleButton, {
                    BackgroundColor3 = value and Color3.fromRGB(60, 220, 120) or Color3.fromRGB(80, 80, 90)
                }, 0.2)
                tween(toggleIndicator, {
                    Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                }, 0.2)
                callback(value)
            end
            
            return Toggle
        end
        
        -- Función para añadir slider
        function Tab:AddSlider(sliderConfig)
            local sliderText = sliderConfig.Name or "Slider"
            local min = sliderConfig.Min or 0
            local max = sliderConfig.Max or 100
            local default = sliderConfig.Default or min
            local callback = sliderConfig.Callback or function() end
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = sliderText
            sliderFrame.Size = UDim2.new(1, -10, 0, 50)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = tabContent
            
            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(0, 6)
            sliderCorner.Parent = sliderFrame
            
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Size = UDim2.new(1, -20, 0, 20)
            sliderLabel.Position = UDim2.new(0, 10, 0, 5)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = sliderText
            sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            sliderLabel.TextSize = 14
            sliderLabel.Font = Enum.Font.Gotham
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderFrame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 50, 0, 20)
            valueLabel.Position = UDim2.new(1, -60, 0, 5)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(default)
            valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            valueLabel.TextSize = 13
            valueLabel.Font = Enum.Font.Gotham
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = sliderFrame
            
            local sliderTrack = Instance.new("Frame")
            sliderTrack.Size = UDim2.new(1, -20, 0, 6)
            sliderTrack.Position = UDim2.new(0, 10, 1, -15)
            sliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            sliderTrack.BorderSizePixel = 0
            sliderTrack.Parent = sliderFrame
            
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = sliderTrack
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderTrack
            
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = sliderFill
            
            local sliderButton = Instance.new("TextButton")
            sliderButton.Size = UDim2.new(0, 14, 0, 14)
            sliderButton.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
            sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sliderButton.BorderSizePixel = 0
            sliderButton.Text = ""
            sliderButton.Parent = sliderTrack
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(1, 0)
            btnCorner.Parent = sliderButton
            
            local dragging = false
            local currentValue = default
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                currentValue = math.floor(min + (max - min) * pos)
                
                valueLabel.Text = tostring(currentValue)
                
                tween(sliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                tween(sliderButton, {Position = UDim2.new(pos, -7, 0.5, -7)}, 0.1)
                
                callback(currentValue)
            end
            
            sliderButton.MouseButton1Down:Connect(function()
                dragging = true
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            sliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    updateSlider(input)
                end
            end)
            
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
            
            local Slider = {}
            function Slider:Set(value)
                currentValue = math.clamp(value, min, max)
                local pos = (currentValue - min) / (max - min)
                valueLabel.Text = tostring(currentValue)
                tween(sliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.2)
                tween(sliderButton, {Position = UDim2.new(pos, -7, 0.5, -7)}, 0.2)
                callback(currentValue)
            end
            
            return Slider
        end
        
        -- Función para añadir label
        function Tab:AddLabel(text)
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -10, 0, 30)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextWrapped = true
            label.Parent = tabContent
            
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
            
            local Label = {}
            function Label:Set(newText)
                label.Text = newText
            end
            
            return Label
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Seleccionar la primera pestaña automáticamente
        if #Window.Tabs == 1 then
            tabButton:Click()
        end
        
        return Tab
    end
    
    return Window
end

return UILibrary

