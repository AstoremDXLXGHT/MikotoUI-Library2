--[[
    MikotoUI Library v2.0 - Crafted by Mikoto Delight
    Rediseño completo: Minimalista, compacta y desplegable con secciones colapsables.
    Estilo: Negro profundo, bordes verde eléctrico y textos blancos nítidos.
    Funcionalidad: Toggles, Buttons, TextLabels, TextBoxes, Sliders, Dropdowns, Keybinds, ColorPickers.
    
    Disclaimer from Mikoto Delight:
    This tool is designed for maximum flexibility and control. 
    I provide the means, you choose the end. Use it wisely, or don't. 
    The power is in your hands, along with all the consequences. 
    I take no responsibility for how this library is utilized.
]]

local MikotoUI = {}

local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Utility = {}
local Objects = {} -- Mantendremos esto para la actualización dinámica de colores si se implementa un theme-changer runtime

-- Mi tema Mikoto Delight, perfectamente adaptado
local MikotoDelightTheme = {
    SchemeColor = Color3.fromRGB(0, 255, 0),     -- Electric Green (Bordes, acentos, indicadores)
    Background = Color3.fromRGB(0, 0, 0),       -- Pure Black (Fondo del menú principal)
    Header = Color3.fromRGB(5, 5, 5),           -- Casi Black (Fondo de secciones, ligeramente diferente al background)
    ElementColor = Color3.fromRGB(15, 15, 15),  -- Gris muy oscuro (Fondo de elementos interactivos)
    TextColor = Color3.fromRGB(255, 255, 255),  -- Bright White (Textos)
    BorderColor = Color3.fromRGB(0, 255, 0)     -- Borde general (verde eléctrico)
}

-- Dragging function (stolen from wally or kiriot, kek) - Sigue siendo útil para la ventana principal
function MikotoUI:DraggingEnabled(frame, parent)
    parent = parent or frame
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position

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

    input.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

function Utility:TweenObject(obj, properties, duration, ...)
    tween:Create(obj, tweeninfo(duration, ...), properties):Play()
end

-- ========================================================================================================
-- MikotoUI.CreateLib - ¡La nueva forma de crear tu menú minimalista!
-- ========================================================================================================

function MikotoUI.CreateLib(menuName)
    local LibInstance = {}
    local currentTheme = MikotoDelightTheme -- Hardcoding for now, could be dynamic later if needed
    menuName = menuName or "Mikoto Menu"

    -- Clean up any previous instances
    local uniqueName = "MikotoUI_" .. HttpService:GenerateGUID(false)
    for _, v in pairs(game.CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name:find("MikotoUI_") then
            v:Destroy()
        end
    end

    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = uniqueName
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    LibInstance.ScreenGui = ScreenGui -- Allow access to ScreenGui for toggling

    -- Main Toggle Button (to open/close the whole UI)
    local MainToggleButton = Instance.new("ImageButton")
    MainToggleButton.Name = "MainToggleButton"
    MainToggleButton.Parent = ScreenGui
    MainToggleButton.BackgroundColor3 = currentTheme.Header
    MainToggleButton.Size = UDim2.new(0, 30, 0, 30)
    MainToggleButton.Position = UDim2.new(1, -40, 0.5, -15) -- Default to right middle
    MainToggleButton.ZIndex = 10
    MainToggleButton.Image = "rbxassetid://3926305904" -- Example image (Gear icon)
    MainToggleButton.ImageRectOffset = Vector2.new(804, 764)
    MainToggleButton.ImageRectSize = Vector2.new(36, 36)
    MainToggleButton.ImageColor3 = currentTheme.SchemeColor
    MainToggleButton.BackgroundTransparency = 0.8 -- Make it subtly visible

    local MainToggleButtonCorner = Instance.new("UICorner")
    MainToggleButtonCorner.CornerRadius = UDim.new(0, 4)
    MainToggleButtonCorner.Parent = MainToggleButton

    local MainToggleButtonBorder = Instance.new("UIStroke")
    MainToggleButtonBorder.Parent = MainToggleButton
    MainToggleButtonBorder.Color = currentTheme.BorderColor
    MainToggleButtonBorder.Thickness = 1
    MainToggleButtonBorder.Transparency = 0

    -- Main Menu Frame (the actual UI content)
    local MainMenuFrame = Instance.new("Frame")
    MainMenuFrame.Name = "MainMenuFrame"
    MainMenuFrame.Parent = ScreenGui
    MainMenuFrame.BackgroundColor3 = currentTheme.Background
    MainMenuFrame.Size = UDim2.new(0, 300, 0, 0) -- Starts collapsed
    MainMenuFrame.Position = UDim2.new(1, -330, 0.5, -150) -- Position it next to the toggle button
    MainMenuFrame.ClipsDescendants = true
    MainMenuFrame.ZIndex = 9

    local MainMenuCorner = Instance.new("UICorner")
    MainMenuCorner.CornerRadius = UDim.new(0, 6)
    MainMenuCorner.Parent = MainMenuFrame

    local MainMenuBorder = Instance.new("UIStroke")
    MainMenuBorder.Parent = MainMenuFrame
    MainMenuBorder.Color = currentTheme.BorderColor
    MainMenuBorder.Thickness = 1
    MainMenuBorder.Transparency = 0

    local MainMenuTitle = Instance.new("TextLabel")
    MainMenuTitle.Name = "Title"
    MainMenuTitle.Parent = MainMenuFrame
    MainMenuTitle.BackgroundColor3 = currentTheme.Header
    MainMenuTitle.Size = UDim2.new(1, 0, 0, 30)
    MainMenuTitle.Text = menuName
    MainMenuTitle.Font = Enum.Font.GothamBold
    MainMenuTitle.TextColor3 = currentTheme.TextColor
    MainMenuTitle.TextSize = 18
    MainMenuTitle.TextWrapped = true

    local MainMenuScrollingFrame = Instance.new("ScrollingFrame")
    MainMenuScrollingFrame.Name = "ContentScroll"
    MainMenuScrollingFrame.Parent = MainMenuFrame
    MainMenuScrollingFrame.BackgroundColor3 = currentTheme.Background
    MainMenuScrollingFrame.Size = UDim2.new(1, 0, 1, -30) -- Fill remaining space after title
    MainMenuScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
    MainMenuScrollingFrame.ScrollBarThickness = 6
    MainMenuScrollingFrame.ScrollBarImageColor3 = currentTheme.SchemeColor
    MainMenuScrollingFrame.BorderSizePixel = 0
    MainMenuScrollingFrame.CanvasSize = UDim2.new(0,0,0,0) -- Will be updated dynamically

    local ContentListLayout = Instance.new("UIListLayout")
    ContentListLayout.Name = "ContentListLayout"
    ContentListLayout.Parent = MainMenuScrollingFrame
    ContentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentListLayout.Padding = UDim.new(0, 5)
    ContentListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentListLayout.FillDirection = Enum.FillDirection.Vertical

    -- Info Container for element tips (smaller, more contextual)
    local InfoContainer = Instance.new("TextLabel")
    InfoContainer.Name = "InfoTip"
    InfoContainer.Parent = MainMenuFrame -- Position within the main menu frame
    -- CORRECCIÓN: Faltaban operadores de multiplicación '*'
    InfoContainer.BackgroundColor3 = Color3.fromRGB(currentTheme.SchemeColor.R  0.5, currentTheme.SchemeColor.G  0.5, currentTheme.SchemeColor.B * 0.5) -- A darker scheme color
    InfoContainer.TextColor3 = currentTheme.TextColor
    InfoContainer.Font = Enum.Font.Gotham
    InfoContainer.TextSize = 12
    InfoContainer.TextXAlignment = Enum.TextXAlignment.Left
    InfoContainer.TextWrapped = true
    InfoContainer.Position = UDim2.new(0, 0, 1, 0) -- Starts below the frame
    InfoContainer.Size = UDim2.new(1, 0, 0, 20)
    InfoContainer.Text = "  Hover for info"
    InfoContainer.BackgroundTransparency = 1
    InfoContainer.ZIndex = 11

    local InfoContainerCorner = Instance.new("UICorner")
    InfoContainerCorner.CornerRadius = UDim.new(0, 4)
    InfoContainerCorner.Parent = InfoContainer

    local InfoContainerBlur = Instance.new("Frame") -- Visual blur-like effect for tips
    InfoContainerBlur.Name = "InfoBlur"
    InfoContainerBlur.Parent = MainMenuFrame
    InfoContainerBlur.BackgroundColor3 = Color3.fromRGB(0,0,0)
    InfoContainerBlur.BackgroundTransparency = 1
    InfoContainerBlur.Size = UDim2.new(1,0,1,0)
    InfoContainerBlur.ZIndex = 10

    -- Dragging for the Main Menu Frame
    MikotoUI:DraggingEnabled(MainMenuTitle, MainMenuFrame)

    local menuVisible = false
    local infoVisible = false
    local currentInfoTip = ""

    local function updateMenuSize()
        local contentSize = ContentListLayout.AbsoluteContentSize
        MainMenuScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y)
    end

    MainMenuScrollingFrame.ChildAdded:Connect(updateMenuSize)
    MainMenuScrollingFrame.ChildRemoved:Connect(updateMenuSize)
    ContentListLayout.ChildAdded:Connect(updateMenuSize)
    ContentListLayout.ChildRemoved:Connect(updateMenuSize)

    -- Toggle UI Functionality
    function LibInstance:ToggleUI()
        if menuVisible then
            -- Hide menu
            Utility:TweenObject(MainMenuFrame, {Size = UDim2.new(0, 300, 0, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            Utility:TweenObject(MainMenuFrame, {Position = UDim2.new(1, -330, MainMenuFrame.Position.Y.Scale, MainMenuFrame.Position.Y.Offset + MainMenuFrame.Size.Y.Offset/2)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- Center while collapsing
            
            Utility:TweenObject(MainToggleButton, {ImageTransparency = 0, BackgroundTransparency = 0.8}, 0.2)
            MainToggleButton.ImageRectOffset = Vector2.new(804, 764) -- Gear icon

            menuVisible = false
        else
            -- Show menu
            Utility:TweenObject(MainMenuFrame, {Size = UDim2.new(0, 300, 0, 300)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            Utility:TweenObject(MainMenuFrame, {Position = UDim2.new(1, -330, 0.5, -150)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- Fixed position
            
            Utility:TweenObject(MainToggleButton, {ImageTransparency = 0.2, BackgroundTransparency = 0.5}, 0.2)
            MainToggleButton.ImageRectOffset = Vector2.new(284, 4) -- Close icon

            menuVisible = true
            updateMenuSize() -- Ensure canvas size is updated on open
        end
    end

    MainToggleButton.MouseButton1Click:Connect(function()
        LibInstance:ToggleUI()
    end)

    -- InfoTip management
    local function showInfoTip(tipText)
        if not infoVisible then
            InfoContainer.Text = "  " .. tipText
            Utility:TweenObject(InfoContainer, {BackgroundTransparency = 0.1, Position = UDim2.new(0,0,1,-20)}, 0.2)
            infoVisible = true
        else
            InfoContainer.Text = "  " .. tipText
        end
        currentInfoTip = tipText
    end

    local function hideInfoTip()
        if infoVisible then
            Utility:TweenObject(InfoContainer, {BackgroundTransparency = 1, Position = UDim2.new(0,0,1,0)}, 0.2)
            infoVisible = false
            currentInfoTip = ""
        end
    end

    -- Sections (Collapsible)
    local Sections = {}
    function Sections:NewSection(secName, initiallyCollapsed)
        local sectionFunctions = {}
        secName = secName or "Section"
        initiallyCollapsed = initiallyCollapsed or false
        
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Name = secName .. "Section"
        sectionFrame.Parent = MainMenuScrollingFrame
        sectionFrame.BackgroundColor3 = currentTheme.Header
        sectionFrame.Size = UDim2.new(1, 0, 0, 30) -- Initial size for header
        sectionFrame.BorderSizePixel = 0
        sectionFrame.ClipsDescendants = true

        local sectionCorner = Instance.new("UICorner")
        sectionCorner.CornerRadius = UDim.new(0, 4)
        sectionCorner.Parent = sectionFrame

        local sectionHeader = Instance.new("TextButton")
        sectionHeader.Name = "SectionHeader"
        sectionHeader.Parent = sectionFrame
        sectionHeader.BackgroundColor3 = currentTheme.Header
        sectionHeader.Size = UDim2.new(1, 0, 0, 30)
        sectionHeader.Text = "  " .. secName
        sectionHeader.Font = Enum.Font.GothamSemibold
        sectionHeader.TextColor3 = currentTheme.TextColor
        sectionHeader.TextSize = 14
        sectionHeader.TextXAlignment = Enum.TextXAlignment.Left
        sectionHeader.BackgroundTransparency = 0 -- Fully visible

        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 4)
        headerCorner.Parent = sectionHeader

        local toggleArrow = Instance.new("ImageLabel")
        toggleArrow.Name = "ToggleArrow"
        toggleArrow.Parent = sectionHeader
        toggleArrow.BackgroundColor3 = Color3.fromRGB(255,255,255)
        toggleArrow.BackgroundTransparency = 1
        toggleArrow.Size = UDim2.new(0, 16, 0, 16)
        toggleArrow.Position = UDim2.new(1, -25, 0.5, -8)
        toggleArrow.Image = "rbxassetid://3926305904" -- Chevron (arrow)
        toggleArrow.ImageRectOffset = Vector2.new(684, 164) -- Down arrow
        toggleArrow.ImageRectSize = Vector2.new(36, 36)
        toggleArrow.ImageColor3 = currentTheme.SchemeColor

        local sectionContent = Instance.new("Frame")
        sectionContent.Name = "SectionContent"
        sectionContent.Parent = sectionFrame
        sectionContent.BackgroundColor3 = currentTheme.Background
        sectionContent.Size = UDim2.new(1, 0, 0, 0) -- Starts collapsed
        sectionContent.Position = UDim2.new(0, 0, 0, 30)
        sectionContent.ClipsDescendants = true
        sectionContent.BorderSizePixel = 0

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Name = "ContentLayout"
        contentLayout.Parent = sectionContent
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 3)
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        contentLayout.FillDirection = Enum.FillDirection.Vertical
                
        local isCollapsed = initiallyCollapsed

        local function updateSectionFrameSize()
            local currentContentHeight = contentLayout.AbsoluteContentSize.Y
            local targetSectionHeight = 30 + (isCollapsed and 0 or currentContentHeight)
            
            Utility:TweenObject(sectionFrame, {Size = UDim2.new(1, 0, 0, targetSectionHeight)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            Utility:TweenObject(sectionContent, {Size = UDim2.new(1, 0, 0, (isCollapsed and 0 or currentContentHeight))}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            -- Update arrow direction
            if isCollapsed then
                toggleArrow.ImageRectOffset = Vector2.new(684, 164) -- Down arrow
            else
                toggleArrow.ImageRectOffset = Vector2.new(764, 164) -- Up arrow (or rotate)
            end
        end

        sectionHeader.MouseButton1Click:Connect(function()
            isCollapsed = not isCollapsed
            updateSectionFrameSize()
            updateMenuSize() -- Update the main scrolling frame too
        end)
        
        sectionContent.ChildAdded:Connect(updateSectionFrameSize)
        sectionContent.ChildRemoved:Connect(updateSectionFrameSize)
        contentLayout.ChildAdded:Connect(updateSectionFrameSize)
        contentLayout.ChildRemoved:Connect(updateSectionFrameSize)

        -- Initial state
        updateSectionFrameSize()
        if not initiallyCollapsed then
            isCollapsed = true -- Set to opposite to trigger initial expansion on first click
            sectionHeader.MouseButton1Click:Fire()
        end

        -- Theme updates
        coroutine.wrap(function()
            while wait() do
                sectionHeader.BackgroundColor3 = currentTheme.Header
                sectionHeader.TextColor3 = currentTheme.TextColor
                toggleArrow.ImageColor3 = currentTheme.SchemeColor
                sectionContent.BackgroundColor3 = currentTheme.Background
                sectionFrame.BackgroundColor3 = currentTheme.Header -- Frame acts as background for header
            end
        end)()

        -- Element Creation Functions
        local Elements = {}

        function Elements:NewButton(bname, tipInf, callback)
            local btn = Instance.new("TextButton")
            btn.Name = bname
            btn.Parent = sectionContent
            btn.BackgroundColor3 = currentTheme.ElementColor
            btn.Size = UDim2.new(1, -10, 0, 25) -- Slightly smaller
            btn.Text = "  " .. bname
            btn.Font = Enum.Font.Gotham
            btn.TextColor3 = currentTheme.TextColor
            btn.TextSize = 13
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.AutoButtonColor = false
            btn.ClipsDescendants = true

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = btn

            local hoverTween
            btn.MouseEnter:Connect(function()
                if hoverTween then hoverTween:Cancel() end
                -- CORRECCIÓN: Faltaban operadores de multiplicación '*'
                hoverTween = Utility:TweenObject(btn, {BackgroundColor3 = Color3.fromRGB(currentTheme.ElementColor.R  255 + 10, currentTheme.ElementColor.G  255 + 10, currentTheme.ElementColor.B * 255 + 10)}, 0.1)
                showInfoTip(tipInf)
            end)
            btn.MouseLeave:Connect(function()
                if hoverTween then hoverTween:Cancel() end
                hoverTween = Utility:TweenObject(btn, {BackgroundColor3 = currentTheme.ElementColor}, 0.1)
                hideInfoTip()
            end)
            btn.MouseButton1Click:Connect(callback)

            coroutine.wrap(function()
                while wait() do
                    btn.TextColor3 = currentTheme.TextColor
                    -- BackgroundColor3 handled by hover
                end
            end)()

            return {
                UpdateButton = function(newTitle)
                    btn.Text = "  " .. newTitle
                end
            }
        end

        function Elements:NewToggle(tname, tipInf, callback)
            local toggle = Instance.new("TextButton")
            toggle.Name = tname
            toggle.Parent = sectionContent
            toggle.BackgroundColor3 = currentTheme.ElementColor
            toggle.Size = UDim2.new(1, -10, 0, 25)
            toggle.Text = "  " .. tname
            toggle.Font = Enum.Font.Gotham
            toggle.TextColor3 = currentTheme.TextColor
            toggle.TextSize = 13
            toggle.TextXAlignment = Enum.TextXAlignment.Left
            toggle.AutoButtonColor = false
            toggle.ClipsDescendants = true

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = toggle

            local indicator = Instance.new("Frame")
            indicator.Name = "Indicator"
            indicator.Parent = toggle
            indicator.BackgroundColor3 = currentTheme.SchemeColor
            indicator.BackgroundTransparency = 1 -- Hidden by default
            indicator.Size = UDim2.new(0, 12, 0, 12)
            indicator.Position = UDim2.new(1, -20, 0.5, -6)

            local indicatorCorner = Instance.new("UICorner")
            indicatorCorner.CornerRadius = UDim.new(0, 6) -- Circle
            indicatorCorner.Parent = indicator

            local toggled = false
            local hoverTween

            local function updateIndicator()
                Utility:TweenObject(indicator, {BackgroundTransparency = toggled and 0 or 1}, 0.1)
            end

            toggle.MouseButton1Click:Connect(function()
                toggled = not toggled
                updateIndicator()
                pcall(callback, toggled)
            end)

            toggle.MouseEnter:Connect(function()
                if hoverTween then hoverTween:Cancel() end
                -- CORRECCIÓN: Faltaban operadores de multiplicación '*'
                hoverTween = Utility:TweenObject(toggle, {BackgroundColor3 = Color3.fromRGB(currentTheme.ElementColor.R  255 + 10, currentTheme.ElementColor.G  255 + 10, currentTheme.ElementColor.B * 255 + 10)}, 0.1)
                showInfoTip(tipInf)
            end)
            toggle.MouseLeave:Connect(function()
                if hoverTween then hoverTween:Cancel() end
                hoverTween = Utility:TweenObject(toggle, {BackgroundColor3 = currentTheme.ElementColor}, 0.1)
                hideInfoTip()
            end)

            coroutine.wrap(function()
                while wait() do
                    toggle.TextColor3 = currentTheme.TextColor
                    indicator.BackgroundColor3 = currentTheme.SchemeColor
                end
            end)()

            return {
                UpdateToggle = function(newText, state)
                    if newText then toggle.Text = "  " .. newText end
                    if state ~= nil then toggled = state updateIndicator() end
                end,
                GetState = function() return toggled end
            }
        end
        
        function Elements:NewLabel(title)
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Parent = sectionContent
            label.BackgroundColor3 = currentTheme.Header -- Header for a slightly different background
            label.Size = UDim2.new(1, -10, 0, 20) -- A bit shorter
            label.Text = "  " .. title
            label.Font = Enum.Font.Gotham
            label.TextColor3 = currentTheme.TextColor
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextWrapped = true
            label.ClipsDescendants = true

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = label

            coroutine.wrap(function()
                while wait() do
                    label.TextColor3 = currentTheme.TextColor
                    label.BackgroundColor3 = currentTheme.Header
                end
            end)()

            return {
                UpdateLabel = function(newText)
                    label.Text = "  " .. newText
                end
            }
        end

        function Elements:NewTextBox(tname, tipInf, callback)
            local textboxContainer = Instance.new("Frame")
            textboxContainer.Name = tname .. "TextBox"
            textboxContainer.Parent = sectionContent
            textboxContainer.BackgroundColor3 = currentTheme.ElementColor
            textboxContainer.Size = UDim2.new(1, -10, 0, 25)
            textboxContainer.ClipsDescendants = true
            textboxContainer.BorderSizePixel = 0

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = textboxContainer

            local textLabel = Instance.new("TextLabel")
            textLabel.Name = "Label"
            textLabel.Parent = textboxContainer
            textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.BackgroundTransparency = 1
            textLabel.Size = UDim2.new(0.5, 0, 1, 0)
            textLabel.Text = "  " .. tname
            textLabel.Font = Enum.Font.Gotham
            textLabel.TextColor3 = currentTheme.TextColor
            textLabel.TextSize = 13
            textLabel.TextXAlignment = Enum.TextXAlignment.Left

            local textBox = Instance.new("TextBox")
            textBox.Name = "Input"
            textBox.Parent = textboxContainer
            textBox.BackgroundColor3 = currentTheme.Header
            textBox.Size = UDim2.new(0.5, -5, 0, 18)
            textBox.Position = UDim2.new(0.5, 0, 0.5, -9)
            textBox.PlaceholderText = "Enter value..."
            textBox.PlaceholderColor3 = currentTheme.SchemeColor
            textBox.TextColor3 = currentTheme.TextColor
            textBox.TextSize = 12
            textBox.Font = Enum.Font.Gotham
            textBox.ClearTextOnFocus = false
            textBox.BorderSizePixel = 0

            local textBoxCorner = Instance.new("UICorner")
            textBoxCorner.CornerRadius = UDim.new(0, 3)
            textBoxCorner.Parent = textBox

            local hoverTween
            textboxContainer.MouseEnter:Connect(function()
                if hoverTween then hoverTween:Cancel() end
                -- CORRECCIÓN: Faltaban operadores de multiplicación '*'
                hoverTween = Utility:TweenObject(textboxContainer, {BackgroundColor3 = Color3.fromRGB(currentTheme.ElementColor.R  255 + 10, currentTheme.ElementColor.G  255 + 10, currentTheme.ElementColor.B * 255 + 10)}, 0.1)
                showInfoTip(tipInf)
            end)
            textboxContainer.MouseLeave:Connect(function()
                if hoverTween then hoverTween:Cancel() end
                hoverTween = Utility:TweenObject(textboxContainer, {BackgroundColor3 = currentTheme.ElementColor}, 0.1)
                hideInfoTip()
            end)

            textBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    callback(textBox.Text)
                    textBox.Text = "" -- Clear after use
                end
            end)
            
            coroutine.wrap(function()
                while wait() do
                    textLabel.TextColor3 = currentTheme.TextColor
                    textBox.BackgroundColor3 = currentTheme.Header
                    textBox.PlaceholderColor3 = currentTheme.SchemeColor
                    textBox.TextColor3 = currentTheme.TextColor
                end
            end)()

            return {
                UpdateText = function(newText)
                    textLabel.Text = "  " .. newText
                end,
                GetValue = function() return textBox.Text end
            }
        end

        function Elements:NewSlider(sname, tipInf, min, max, initialValue, callback)
            local sliderContainer = Instance.new("Frame")
            sliderContainer.Name = sname .. "Slider"
            sliderContainer.Parent = sectionContent
            sliderContainer.BackgroundColor3 = currentTheme.ElementColor
            sliderContainer.Size = UDim2.new(1, -10, 0, 35) -- Taller for value text
            sliderContainer.ClipsDescendants = true
            sliderContainer.BorderSizePixel = 0

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = sliderContainer

            local textLabel = Instance.new("TextLabel")
            textLabel.Name = "Label"
            textLabel.Parent = sliderContainer
            textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.BackgroundTransparency = 1
            textLabel.Size = UDim2.new(0.6, 0, 0, 15)
            textLabel.Position = UDim2.new(0, 0, 0, 3)
            textLabel.Text = "  " .. sname
            textLabel.Font = Enum.Font.Gotham
            textLabel.TextColor3 = currentTheme.TextColor
            textLabel.TextSize = 13
            textLabel.TextXAlignment = Enum.TextXAlignment.Left

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Name = "Value"
            valueLabel.Parent = sliderContainer
            valueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Size = UDim2.new(0.4, 0, 0, 15)
            valueLabel.Position = UDim2.new(0.6, 0, 0, 3)
            valueLabel.Text = tostring(initialValue or min)
            valueLabel.Font = Enum.Font.Gotham
            valueLabel.TextColor3 = currentTheme.SchemeColor
            valueLabel.TextSize = 13
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local sliderBar = Instance.new("Frame")
            sliderBar.Name = "SliderBar"
            sliderBar.Parent = sliderContainer
            sliderBar.BackgroundColor3 = currentTheme.Header
            sliderBar.Size = UDim2.new(1, -10, 0, 4)
            sliderBar.Position = UDim2.new(0.5, -((sliderBar.Size.X.Offset)/2), 0, 25) -- Centered below text
            sliderBar.BorderSizePixel = 0

            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(0, 2)
            sliderCorner.Parent = sliderBar

            local sliderFill = Instance.new("Frame")
            sliderFill.Name = "SliderFill"
            sliderFill.Parent = sliderBar
            sliderFill.BackgroundColor3 = currentTheme.SchemeColor
            sliderFill.Size = UDim2.new(0, 0, 1, 0) -- Fill starts at 0 or initial value
            sliderFill.BorderSizePixel = 0

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 2)
            fillCorner.Parent = sliderFill

            local currentValue = initialValue or min

            local function updateSliderVisual(newValue)
                local ratio = (newValue - min) / (max - min)
                ratio = math.clamp(ratio, 0, 1)
                sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
                valueLabel.Text = tostring(math.floor(newValue + 0.5)) -- Round to nearest integer
            end

            local isDragging = false
            local mouse = input:GetMouse()

            sliderBar.MouseButton1Down:Connect(function()
                isDragging = true
                local function onMove()
                    local pos = mouse.X - sliderBar.AbsolutePosition.X
                    local newRatio = math.clamp(pos / sliderBar.AbsoluteSize.X, 0, 1)
                    currentValue = min + (max - min) * newRatio
                    updateSliderVisual(currentValue)
                    pcall(callback, math.floor(currentValue + 0.5))
                end
                
                onMove() -- Initial update
                local moveConn = mouse.Move:Connect(onMove)
                local inputEndedConn = input.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                        moveConn:Disconnect()
                        inputEndedConn:Disconnect()
                    end
                end)
            end)

            updateSliderVisual(currentValue) -- Set initial visual
            pcall(callback, math.floor(currentValue + 0.5)) -- Initial callback

            local hoverTween
            sliderContainer.MouseEnter:Connect(function()
                if hoverTween then hoverTween:Cancel() end
                -- CORRECCIÓN: Faltaban operadores de multiplicación '*'
                hoverTween = Utility:TweenObject(sliderContainer, {BackgroundColor3 = Color3.fromRGB(currentTheme.ElementColor.R  255 + 10, currentTheme.ElementColor.G  255 + 10, currentTheme.ElementColor.B * 255 + 10)}, 0.1)
                showInfoTip(tipInf)
            end)
            sliderContainer.MouseLeave:Connect(function()
                if hoverTween then hoverTween:Cancel() end
                hoverTween = Utility:TweenObject(sliderContainer, {BackgroundColor3 = currentTheme.ElementColor}, 0.1)
                hideInfoTip()
            end)

            coroutine.wrap(function()
                while wait() do
                    textLabel.TextColor3 = currentTheme.TextColor
                    valueLabel.TextColor3 = currentTheme.SchemeColor
                    sliderBar.BackgroundColor3 = currentTheme.Header
                    sliderFill.BackgroundColor3 = currentTheme.SchemeColor
                end
            end)()

            return {
                UpdateValue = function(newValue)
                    currentValue = math.clamp(newValue, min, max)
                    updateSliderVisual(currentValue)
                    pcall(callback, math.floor(currentValue + 0.5))
                end,
                GetValue = function() return math.floor(currentValue + 0.5) end
            }
        end

        function Elements:NewDropdown(dname, tipInf, options, callback)
            local dropdownContainer = Instance.new("Frame")
            dropdownContainer.Name = dname .. "Dropdown"
            dropdownContainer.Parent = sectionContent
            dropdownContainer.BackgroundColor3 = currentTheme.ElementColor
            dropdownContainer.Size = UDim2.new(1, -10, 0, 25)
            dropdownContainer.ClipsDescendants = true
            dropdownContainer.BorderSizePixel = 0

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = dropdownContainer

            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Name = "Button"
            dropdownButton.Parent = dropdownContainer
            dropdownButton.BackgroundColor3 = currentTheme.ElementColor
            dropdownButton.Size = UDim2.new(1, 0, 1, 0)
            dropdownButton.Text = "  " .. dname .. ": " .. (options[1] or "None")
            dropdownButton.Font = Enum.Font.Gotham
            dropdownButton.TextColor3 = currentTheme.TextColor
            dropdownButton.TextSize = 13
            dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
            dropdownButton.AutoButtonColor = false

            local arrow = Instance.new("ImageLabel")
            arrow.Name = "Arrow"
            arrow.Parent = dropdownButton
            arrow.BackgroundColor3 = Color3.fromRGB(255,255,255)
            arrow.BackgroundTransparency = 1
            arrow.Size = UDim2.new(0, 16, 0, 16)
            arrow.Position = UDim2.new(1, -20, 0.5, -8)
            arrow.Image = "rbxassetid://3926305904" -- Down arrow
            arrow.ImageRectOffset = Vector2.new(684, 164)
            arrow.ImageRectSize = Vector2.new(36, 36)
            arrow.ImageColor3 = currentTheme.SchemeColor

            local optionsFrame = Instance.new("Frame")
            optionsFrame.Name = "Options"
            optionsFrame.Parent = dropdownContainer
            optionsFrame.BackgroundColor3 = currentTheme.Header
            optionsFrame.Size = UDim2.new(1, 0, 0, 0) -- Starts collapsed
            optionsFrame.Position = UDim2.new(0, 0, 1, 0)
            optionsFrame.ClipsDescendants = true
            optionsFrame.BorderSizePixel = 0

            local optionsLayout = Instance.new("UIListLayout")
            optionsLayout.Name = "OptionsLayout"
            optionsLayout.Parent = optionsFrame
            optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionsLayout.Padding = UDim.new(0, 2)
            optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

            local isOpen = false
            local currentSelection = options[1] or "None"

            local function createOptionButton(optionText)
                local optionBtn = Instance.new("TextButton")
                optionBtn.Parent = optionsFrame
                optionBtn.BackgroundColor3 = currentTheme.ElementColor
                optionBtn.Size = UDim2.new(1, 0, 0, 20)
                optionBtn.Text = "  " .. optionText
                optionBtn.Font = Enum.Font.Gotham
                optionBtn.TextColor3 = currentTheme.TextColor
                optionBtn.TextSize = 12
                optionBtn.TextXAlignment = Enum.TextXAlignment.Left
                optionBtn.AutoButtonColor = false

                local optionCorner = Instance.new("UICorner")
                optionCorner.CornerRadius = UDim.new(0, 3)
                optionCorner.Parent = optionBtn

                optionBtn.MouseButton1Click:Connect(function()
                    currentSelection = optionText
                    dropdownButton.Text = "  " .. dname .. ": " .. optionText
                    pcall(callback, optionText)
                    dropdownButton.MouseButton1Click:Fire() -- Close dropdown
                end)

                local hoverTween
                optionBtn.MouseEnter:Connect(function()
                    if hoverTween then hoverTween:Cancel() end
                    -- CORRECCIÓN: Faltaban operadores de multiplicación '*'
                    hoverTween = Utility:TweenObject(optionBtn, {BackgroundColor3 = Color3.fromRGB(currentTheme.ElementColor.R  255 + 15, currentTheme.ElementColor.G  255 + 15, currentTheme.ElementColor.B * 255 + 15)}, 0.1)
                end)
                optionBtn.MouseLeave:Connect(function()
                    if hoverTween then hoverTween:Cancel() end
                    hoverTween = Utility:TweenObject(optionBtn, {BackgroundColor3 = currentTheme.ElementColor}, 0.1)
                end)

                coroutine.wrap(function()
                    while wait() do
                        optionBtn.TextColor3 = currentTheme.TextColor
                    end
                end)()
            end

            for _, opt in ipairs(options) do
                createOptionButton(opt)
            end

            local function toggleDropdown()
                isOpen = not isOpen
                local targetHeight = isOpen and (optionsLayout.AbsoluteContentSize.Y) or 0
                local totalContainerHeight = 25 + targetHeight + (isOpen and 5 or 0) -- Base height + options + padding

                Utility:TweenObject(dropdownContainer, {Size = UDim2.new(1, -10, 0, totalContainerHeight)}, 0.2)
                Utility:TweenObject(optionsFrame, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                
                if isOpen then
                    arrow.ImageRectOffset = Vector2.new(764, 164) -- Up arrow
                else
                    arrow.ImageRectOffset = Vector2.new(684, 164) -- Down arrow
                end
            end

            dropdownButton.MouseButton1Click:Connect(toggleDropdown)

            local hoverTweenBtn
            dropdownContainer.MouseEnter:Connect(function()
                if hoverTweenBtn then hoverTweenBtn:Cancel() end
                -- CORRECCIÓN: Faltaban operadores de multiplicación '*'
                hoverTweenBtn = Utility:TweenObject(dropdownButton, {BackgroundColor3 = Color3.fromRGB(currentTheme.ElementColor.R  255 + 10, currentTheme.ElementColor.G  255 + 10, currentTheme.ElementColor.B * 255 + 10)}, 0.1)
                showInfoTip(tipInf)
            end)
            dropdownContainer.MouseLeave:Connect(function()
                if hoverTweenBtn then hoverTweenBtn:Cancel() end
                hoverTweenBtn = Utility:TweenObject(dropdownButton, {BackgroundColor3 = currentTheme.ElementColor}, 0.1)
                hideInfoTip()
            end)

            coroutine.wrap(function()
                while wait() do
                    dropdownButton.BackgroundColor3 = currentTheme.ElementColor
                    dropdownButton.TextColor3 = currentTheme.TextColor
                    arrow.ImageColor3 = currentTheme.SchemeColor
                    optionsFrame.BackgroundColor3 = currentTheme.Header
                end
            end)()

            return {
                Refresh = function(newOptions)
                    for _, child in ipairs(optionsFrame:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    options = newOptions
                    for _, opt in ipairs(options) do
                        createOptionButton(opt)
                    end
                    currentSelection = options[1] or "None"
                    dropdownButton.Text = "  " .. dname .. ": " .. currentSelection
                    if isOpen then -- Recalculate size if open
                        local targetHeight = optionsLayout.AbsoluteContentSize.Y
                        local totalContainerHeight = 25 + targetHeight + 5
                        Utility:TweenObject(dropdownContainer, {Size = UDim2.new(1, -10, 0, totalContainerHeight)}, 0.2)
                        Utility:TweenObject(optionsFrame, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                    end
                end,
                GetSelection = function() return currentSelection end
            }
        end
        
        function Elements:NewKeybind(kname, tipInf, defaultKey, callback)
            local keybindContainer = Instance.new("Frame")
            keybindContainer.Name = kname .. "Keybind"
            keybindContainer.Parent = sectionContent
            keybindContainer.BackgroundColor3 = currentTheme.ElementColor
            keybindContainer.Size = UDim2.new(1, -10, 0, 25)
            keybindContainer.ClipsDescendants = true
            keybindContainer.BorderSizePixel = 0

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = keybindContainer

            local keybindButton = Instance.new("TextButton")
            keybindButton.Name = "Button"
            keybindButton.Parent = keybindContainer
            keybindButton.BackgroundColor3 = currentTheme.ElementColor
            keybindButton.Size = UDim2.new(1, 0, 1, 0)
            keybindButton.Text = "  " .. kname .. ": [" .. (defaultKey.Name == "Unknown" and "None" or defaultKey.Name) .. "]"
            keybindButton.Font = Enum.Font.Gotham
            keybindButton.TextColor3 = currentTheme.TextColor
            keybindButton.TextSize = 13
            keybindButton.TextXAlignment = Enum.TextXAlignment.Left
            keybindButton.AutoButtonColor = false

            local currentKey = defaultKey
            local isListening = false

            local hoverTween
            keybindContainer.MouseEnter:Connect(function()
                if hoverTween then hoverTween:Cancel() end
                -- CORRECCIÓN: Faltaban operadores de multiplicación '*'
                hoverTween = Utility:TweenObject(keybindContainer, {BackgroundColor3 = Color3.fromRGB(currentTheme.ElementColor.R  255 + 10, currentTheme.ElementColor.G  255 + 10, currentTheme.ElementColor.B * 255 + 10)}, 0.1)
                showInfoTip(tipInf)
            end)
            keybindContainer.MouseLeave:Connect(function()
                if hoverTween then hoverTween:Cancel() end
                hoverTween = Utility:TweenObject(keybindContainer, {BackgroundColor3 = currentTheme.ElementColor}, 0.1)
                hideInfoTip()
            end)
            
            local inputBeganConn
            keybindButton.MouseButton1Click:Connect(function()
                if isListening then return end -- Avoid multiple listeners
                isListening = true
                keybindButton.Text = "  " .. kname .. ": [...]"

                inputBeganConn = input.InputBegan:Connect(function(inputObject, gameProcessedEvent)
                    if gameProcessedEvent then return end
                    
                    if inputObject.UserInputType == Enum.UserInputType.Keyboard or inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                        currentKey = inputObject.KeyCode
                        if currentKey == Enum.KeyCode.Unknown and inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                            currentKey = Enum.KeyCode.MouseButton1
                        elseif currentKey == Enum.KeyCode.Unknown then -- If still unknown, fallback to a sensible default or cancel
                            currentKey = Enum.KeyCode.None
                        end

                        keybindButton.Text = "  " .. kname .. ": [" .. (currentKey.Name == "Unknown" and "None" or currentKey.Name) .. "]"
                        isListening = false
                        inputBeganConn:Disconnect()
                    end
                end)
            end)

            local keyTriggerConn
            keyTriggerConn = input.InputBegan:Connect(function(inputObject, gameProcessedEvent)
                if gameProcessedEvent then return end
                if inputObject.KeyCode == currentKey and not isListening then
                    pcall(callback, currentKey)
                end
            end)

            coroutine.wrap(function()
                while wait() do
                    keybindButton.BackgroundColor3 = currentTheme.ElementColor
                    keybindButton.TextColor3 = currentTheme.TextColor
                end
            end)()

            return {
                UpdateKeybind = function(newKey)
                    currentKey = newKey
                    keybindButton.Text = "  " .. kname .. ": [" .. (currentKey.Name == "Unknown" and "None" or currentKey.Name) .. "]"
                end,
                GetKey = function() return currentKey end
            }
        end

        function Elements:NewColorPicker(cname, tipInf, defaultColor, callback)
            local colorPickerContainer = Instance.new("Frame")
            colorPickerContainer.Name = cname .. "ColorPicker"
            colorPickerContainer.Parent = sectionContent
            colorPickerContainer.BackgroundColor3 = currentTheme.ElementColor
            colorPickerContainer.Size = UDim2.new(1, -10, 0, 25)
            colorPickerContainer.ClipsDescendants = true
            colorPickerContainer.BorderSizePixel = 0

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = colorPickerContainer

            local colorPickerButton = Instance.new("TextButton")
            colorPickerButton.Name = "Button"
            colorPickerButton.Parent = colorPickerContainer
            colorPickerButton.BackgroundColor3 = currentTheme.ElementColor
            colorPickerButton.Size = UDim2.new(1, 0, 1, 0)
            colorPickerButton.Text = "  " .. cname
            colorPickerButton.Font = Enum.Font.Gotham
            colorPickerButton.TextColor3 = currentTheme.TextColor
            colorPickerButton.TextSize = 13
            colorPickerButton.TextXAlignment = Enum.TextXAlignment.Left
            colorPickerButton.AutoButtonColor = false

            local colorPreview = Instance.new("Frame")
            colorPreview.Name = "ColorPreview"
            colorPreview.Parent = colorPickerButton
            colorPreview.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 255, 255)
            colorPreview.Size = UDim2.new(0, 15, 0, 15)
            colorPreview.Position = UDim2.new(1, -25, 0.5, -7.5)
            colorPreview.BorderSizePixel = 1
            colorPreview.BorderColor3 = currentTheme.SchemeColor

            local previewCorner = Instance.new("UICorner")
            previewCorner.CornerRadius = UDim.new(0, 4)
            previewCorner.Parent = colorPreview

            -- Simple Color Picker Logic (for minimalism)
            -- Instead of the complex Kavo one, let's make a smaller, in-line one if possible
            -- Or, as a simple fallback, use a predefined palette or a simple HSV slider.
            -- For truly minimalist, a direct RGB input box, or a very compact HSV triangle.
            -- For now, let's simplify to a popup that appears below.

            local colorPanel = Instance.new("Frame")
            colorPanel.Name = "ColorPanel"
            colorPanel.Parent = colorPickerContainer
            colorPanel.BackgroundColor3 = currentTheme.Header
            colorPanel.Size = UDim2.new(1, 0, 0, 0) -- Starts collapsed
            colorPanel.Position = UDim2.new(0, 0, 1, 0)
            colorPanel.ClipsDescendants = true
            colorPanel.BorderSizePixel = 0

            local panelCorner = Instance.new("UICorner")
            panelCorner.CornerRadius = UDim.new(0, 4)
            panelCorner.Parent = colorPanel
                        
            local colorPickerOpened = false
            local currentColor = defaultColor or Color3.fromRGB(255,255,255)

            -- Simplified HSV (Hue Slider + Saturation/Value Square)
            local H = Color3.toHSV(currentColor)
            local currentHue = H[1]
            local currentSaturation = H[2]
            local currentValue = H[3]

            -- Hue Slider
            local hueSliderBG = Instance.new("Frame")
            hueSliderBG.Name = "HueSliderBG"
            hueSliderBG.Parent = colorPanel
            hueSliderBG.BackgroundColor3 = Color3.fromRGB(0,0,0) -- Will be replaced by gradient
            hueSliderBG.BackgroundTransparency = 1
            hueSliderBG.Size = UDim2.new(0.9, 0, 0, 15)
            hueSliderBG.Position = UDim2.new(0.05, 0, 0.1, 0)
                        
            local hueGradient = Instance.new("UIGradient")
            hueGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)),
                ColorSequenceKeypoint.new(0.166, Color3.fromHSV(0.166,1,1)),
                ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333,1,1)),
                ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)),
                ColorSequenceKeypoint.new(0.666, Color3.fromHSV(0.666,1,1)),
                ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833,1,1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1))
            }
            hueGradient.Parent = hueSliderBG

            local hueHandle = Instance.new("Frame")
            hueHandle.Name = "HueHandle"
            hueHandle.Parent = hueSliderBG
            hueHandle.BackgroundColor3 = currentTheme.TextColor
            hueHandle.Size = UDim2.new(0, 5, 1, 0)
            hueHandle.Position = UDim2.new(currentHue, -2.5, 0, 0)
            hueHandle.BorderSizePixel = 1
            hueHandle.BorderColor3 = currentTheme.SchemeColor

            -- Saturation/Value Square
            local svSquare = Instance.new("ImageLabel")
            svSquare.Name = "SVSquare"
            svSquare.Parent = colorPanel
            svSquare.Image = "rbxassetid://6523286724" -- HSV texture
            svSquare.BackgroundTransparency = 1
            svSquare.Size = UDim2.new(0.8, 0, 0.6, 0)
            svSquare.Position = UDim2.new(0.1, 0, 0.35, 0)
            svSquare.ImageColor3 = Color3.fromHSV(currentHue, 1, 1)

            local svHandle = Instance.new("Frame")
            svHandle.Name = "SVHandle"
            svHandle.Parent = svSquare
            svHandle.BackgroundColor3 = currentTheme.TextColor
            svHandle.Size = UDim2.new(0, 5, 0, 5)
            svHandle.Position = UDim2.new(currentSaturation, -2.5, 1 - currentValue, -2.5) -- Correct position based on S/V
            svHandle.BorderSizePixel = 1
            svHandle.BorderColor3 = currentTheme.SchemeColor
            svHandle.ClipsDescendants = true

            local svHandleCorner = Instance.new("UICorner")
            svHandleCorner.CornerRadius = UDim.new(0, 2)
            svHandleCorner.Parent = svHandle

            local function updateColorPreview()
                currentColor = Color3.fromHSV(currentHue, currentSaturation, currentValue)
                colorPreview.BackgroundColor3 = currentColor
                if callback then pcall(callback, currentColor) end
            end

            local isHueDragging = false
            hueSliderBG.MouseButton1Down:Connect(function()
                isHueDragging = true
                local startPos = hueSliderBG.AbsolutePosition.X
                local width = hueSliderBG.AbsoluteSize.X
                run.RenderStepped:Connect(function()
                    if isHueDragging then
                        local mouseX = input:GetMouse().X
                        local newHue = math.clamp((mouseX - startPos) / width, 0, 1)
                        currentHue = newHue
                        hueHandle.Position = UDim2.new(currentHue, -2.5, 0, 0)
                        svSquare.ImageColor3 = Color3.fromHSV(currentHue, 1, 1)
                        updateColorPreview()
                    end
                end)
                input.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        isHueDragging = false
                    end
                end)
            end)

            local isSVDragging = false
            svSquare.MouseButton1Down:Connect(function()
                isSVDragging = true
                local startPos = svSquare.AbsolutePosition
                local width = svSquare.AbsoluteSize.X
                local height = svSquare.AbsoluteSize.Y
                run.RenderStepped:Connect(function()
                    if isSVDragging then
                        local mouseX = input:GetMouse().X
                        local mouseY = input:GetMouse().Y
                        local newSaturation = math.clamp((mouseX - startPos.X) / width, 0, 1)
                        local newValue = 1 - math.clamp((mouseY - startPos.Y) / height, 0, 1) -- Invert Y for value
                        currentSaturation = newSaturation
                        currentValue = newValue
                        svHandle.Position = UDim2.new(currentSaturation, -2.5, 1 - currentValue, -2.5)
                        updateColorPreview()
                    end
                end)
                input.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        isSVDragging = false
                    end
                end)
            end)
              
            local function toggleColorPanel()
                colorPickerOpened = not colorPickerOpened
                local targetHeight = colorPickerOpened and 120 or 0
                local totalContainerHeight = 25 + targetHeight + (colorPickerOpened and 5 or 0) -- Base height + panel + padding

                Utility:TweenObject(colorPickerContainer, {Size = UDim2.new(1, -10, 0, totalContainerHeight)}, 0.2)
                Utility:TweenObject(colorPanel, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
            end

            colorPickerButton.MouseButton1Click:Connect(toggleColorPanel)

            local hoverTweenBtn
            colorPickerContainer.MouseEnter:Connect(function()
                if hoverTweenBtn then hoverTweenBtn:Cancel() end
                -- CORRECCIÓN: Faltaban operadores de multiplicación '*'
                hoverTweenBtn = Utility:TweenObject(colorPickerButton, {BackgroundColor3 = Color3.fromRGB(currentTheme.ElementColor.R  255 + 10, currentTheme.ElementColor.G  255 + 10, currentTheme.ElementColor.B * 255 + 10)}, 0.1)
                showInfoTip(tipInf)
            end)
            colorPickerContainer.MouseLeave:Connect(function()
                if hoverTweenBtn then hoverTweenBtn:Cancel() end
                hoverTweenBtn = Utility:TweenObject(colorPickerButton, {BackgroundColor3 = currentTheme.ElementColor}, 0.1)
                hideInfoTip()
            end)

            coroutine.wrap(function()
                while wait() do
                    colorPickerButton.BackgroundColor3 = currentTheme.ElementColor
                    colorPickerButton.TextColor3 = currentTheme.TextColor
                    colorPreview.BorderColor3 = currentTheme.SchemeColor
                    colorPanel.BackgroundColor3 = currentTheme.Header
                    hueHandle.BackgroundColor3 = currentTheme.TextColor
                    hueHandle.BorderColor3 = currentTheme.SchemeColor
                    svHandle.BackgroundColor3 = currentTheme.TextColor
                    svHandle.BorderColor3 = currentTheme.SchemeColor
                end
            end)()

            return {
                UpdateColor = function(newColor)
                    currentColor = newColor
                    local h, s, v = Color3.toHSV(newColor)
                    currentHue = h
                    currentSaturation = s
                    currentValue = v

                    colorPreview.BackgroundColor3 = currentColor
                    hueHandle.Position = UDim2.new(currentHue, -2.5, 0, 0)
                    svSquare.ImageColor3 = Color3.fromHSV(currentHue, 1, 1)
                    svHandle.Position = UDim2.new(currentSaturation, -2.5, 1 - currentValue, -2.5)
                    if callback then pcall(callback, currentColor) end
                end,
                GetColor = function() return currentColor end
            }
        end

        -- Return Elements interface for this section
        sectionFunctions.Elements = Elements
        return sectionFunctions
    end

    LibInstance.Sections = Sections
    return LibInstance
end

return MikotoUI
