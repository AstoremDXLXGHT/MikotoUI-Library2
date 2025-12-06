--[[
    UILibrary v1.0
    Librería universal para crear interfaces de usuario en Roblox
    Compatible con cualquier executor que soporte loadstring
    
    Mikoto Delight: ¡Lista para dar vida a tus interfaces!
]]

local UILibrary = {}

-- Servicios (siempre bien organizados)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players") 

-- Utilidades (mis herramientas favoritas)
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
            
            local newPosX = framePos.X.Scale
            local newOffsetX = framePos.X.Offset + delta.X
            local newPosY = framePos.Y.Scale
            local newOffsetY = framePos.Y.Offset + delta.Y

            tween(frame, {
                Position = UDim2.new(
                    newPosX,
                    newOffsetX,
                    newPosY,
                    newOffsetY
                )
            }, 0.05) 
        end
    end)
end

-- Función principal para crear ventana (el lienzo de tu obra)
function UILibrary:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "UI Library"
    local windowSize = config.Size or UDim2.new(0, 500, 0, 400)

    -- Crear ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UILibrary_" .. math.random(1000, 9999)
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false

    pcall(function()
        screenGui.Parent = CoreGui
    end)

    if screenGui.Parent ~= CoreGui then
        local player = Players.LocalPlayer
        if player then
            screenGui.Parent = player:WaitForChild("PlayerGui")
        else
            warn("MikotoUI: No se pudo encontrar LocalPlayer para parentar ScreenGui.")
            return nil 
        end
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

    -- Sombra (¡un toque de profundidad!)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = 0
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png" 
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice 
    shadow.SliceCenter = Rect.new(10, 10, 10, 10) 
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

    -- Botón de cerrar (¡el escape!)
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
        tween(mainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(mainFrame.Position.X.Scale + mainFrame.Size.X.Scale / 2, mainFrame.Position.X.Offset + mainFrame.Size.X.Offset / 2,
                                  mainFrame.Position.Y.Scale + mainFrame.Size.Y.Scale / 2, mainFrame.Position.Y.Offset + mainFrame.Size.Y.Offset / 2)
        }, 0.3)
        task.wait(0.3) 
        screenGui:Destroy()
    end)

    closeButton.MouseEnter:Connect(function()
        tween(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.2)
    end)

    closeButton.MouseLeave:Connect(function()
        tween(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}, 0.2)
    end)

    -- Container de pestañas (el cerebro de la operación)
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
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) 
    tween(mainFrame, {Size = windowSize, Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2)}, 0.4)

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

        Tab.Button = tabButton
        Tab.Content = tabContent
        Tab.Layout = contentLayout 
        Tab.Padding = contentPadding 

        -- Mikoto: Función para actualizar el CanvasSize de la pestaña (¡con prints de depuración!)
        function Tab:UpdateCanvasSize()
            if self.Layout and self.Padding then
                local contentHeight = self.Layout.AbsoluteContentSize.Y
                local totalUIPaddingY = self.Padding.PaddingTop.Offset + self.Padding.PaddingBottom.Offset
                local layoutPadding = self.Layout.Padding.Offset 

                local calculatedHeight = contentHeight + totalUIPaddingY + (contentHeight > 0 and layoutPadding or 0) + 10 

                local minCanvasHeight = self.Content.AbsoluteSize.Y 
                
                if minCanvasHeight == 0 then
                    minCanvasHeight = self.Content.Size.Y.Offset
                end

                local newCanvasY = math.max(minCanvasHeight, calculatedHeight)
                
                print(string.format("[MikotoUI Debug] Tab '%s': Updating CanvasSize. Layout.AbsContentSize.Y: %d, SF.UIPaddingY: %d, UL.Padding: %d, CalculatedTargetHeight: %d, SF.AbsSize.Y: %d, Final CanvasSize.Y: %d", 
                    self.Name, contentHeight, totalUIPaddingY, layoutPadding, calculatedHeight, self.Content.AbsoluteSize.Y, newCanvasY))
                    
                self.Content.CanvasSize = UDim2.new(0, 0, 0, newCanvasY)
            end
        end

        tabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tween(tab.Button, {BackgroundColor3 = Color3.fromRGB(35, 35, 45), TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
            end

            tabContent.Visible = true
            Window.CurrentTab = Tab
            tween(tabButton, {BackgroundColor3 = Color3.fromRGB(60, 120, 220), TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            
            task.spawn(function()
                task.wait() 
                task.wait() 
                
                local retries = 0
                local maxRetries = 20 
                local contentHeight = Tab.Layout.AbsoluteContentSize.Y
                
                while contentHeight == 0 and retries < maxRetries do
                    print(string.format("[MikotoUI Debug] Tab '%s': Waiting for AbsoluteContentSize.Y to be > 0 (currently %d)... Retry %d", Tab.Name, contentHeight, retries + 1))
                    task.wait(0.05) 
                    contentHeight = Tab.Layout.AbsoluteContentSize.Y 
                    retries = retries + 1
                end

                Tab:UpdateCanvasSize()
            end)
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
            print(string.format("[MikotoUI Debug] Added Button '%s' to tab '%s'", buttonText, self.Name))

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

            task.defer(function()
                self:UpdateCanvasSize()
            end)

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
            print(string.format("[MikotoUI Debug] Added Toggle '%s' to tab '%s'", toggleText, self.Name))

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

            task.defer(function()
                self:UpdateCanvasSize()
            end)

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

            function Toggle:Get() 
                return toggled
            end

            return Toggle
        end

        -- Función para añadir slider (¡control total!)
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
            print(string.format("[MikotoUI Debug] Added Slider '%s' to tab '%s'", sliderText, self.Name))

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
            local initialFillPos = (default - min) / (max - min)
            sliderFill.Size = UDim2.new(initialFillPos, 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderTrack

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = sliderFill

            local sliderButton = Instance.new("TextButton")
            sliderButton.Size = UDim2.new(0, 14, 0, 14)
            sliderButton.Position = UDim2.new(initialFillPos, -7, 0.5, -7)
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
                local xPos = input.Position.X
                local trackAbsPos = sliderTrack.AbsolutePosition.X
                local trackAbsSizeX = sliderTrack.AbsoluteSize.X

                local pos = math.clamp((xPos - trackAbsPos) / trackAbsSizeX, 0, 1)

                currentValue = math.floor(min + (max - min) * pos)
                currentValue = math.clamp(currentValue, min, max) 

                valueLabel.Text = tostring(currentValue)

                local actualPos = (currentValue - min) / (max - min)
                tween(sliderFill, {Size = UDim2.new(actualPos, 0, 1, 0)}, 0.1)
                tween(sliderButton, {Position = UDim2.new(actualPos, -7, 0.5, -7)}, 0.1)

                callback(currentValue)
            end

            sliderButton.MouseButton1Down:Connect(function()
                dragging = true
                UserInputService.MouseIconEnabled = false 
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    UserInputService.MouseIconEnabled = true
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
                    dragging = true 
                    UserInputService.MouseIconEnabled = false
                end
            end)

            task.defer(function()
                self:UpdateCanvasSize()
            end)

            local Slider = {}
            function Slider:Set(value)
                currentValue = math.clamp(value, min, max)
                local pos = (currentValue - min) / (max - min)
                valueLabel.Text = tostring(currentValue)
                tween(sliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.2)
                tween(sliderButton, {Position = UDim2.new(pos, -7, 0.5, -7)}, 0.2)
                callback(currentValue)
            end

            function Slider:Get() 
                return currentValue
            end

            return Slider
        end

        -- Función para añadir label (¡para informar!)
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
            label.AutomaticSize = Enum.AutomaticSize.Y 
            label.Parent = tabContent
            print(string.format("[MikotoUI Debug] Added Label '%s' to tab '%s'", text, self.Name))

            task.defer(function()
                self:UpdateCanvasSize()
            end)

            local Label = {}
            function Label:Set(newText)
                label.Text = newText
                task.defer(function()
                    self:UpdateCanvasSize()
                end)
            end

            function Label:Get() 
                return label.Text
            end

            return Label
        end

        table.insert(Window.Tabs, Tab)

        -- Seleccionar la primera pestaña automáticamente
        if #Window.Tabs == 1 then
            -- Mikoto: ¡CORRECCIÓN CRÍTICA! Usamos :Click() en lugar de :Fire()
            tabButton:Click() 
        end

        return Tab
    end

    return UILibrary
