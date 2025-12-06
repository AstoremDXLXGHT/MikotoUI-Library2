--[[
 Mikoto Delight's Universal UI Library (DelightUI)
 Version: 1.0.0

 Descripción:
 Una librería elegante y minimalista para la creación de interfaces de usuario en Roblox,
 diseñada para ser invocada a través de 'loadstring' desde cualquier executor.
 Presenta un esquema de color negro con acentos verdes y un diseño desplegable.

 Características:
 - Menú principal arrastrable.
 - Categorías desplegables (Dropdowns).
 - Botones, Toggles, Sliders y TextBoxes funcionales.
 - Estilo minimalista, negro y verde.
 - Totalmente modular y fácil de usar.

 Uso:
 local DelightUI = loadstring(game:HttpGet("URL_TO_THIS_SCRIPT_IF_HOSTED_ONLINE") or [[ --[[ PASTE THIS ENTIRE SCRIPT HERE ]] ]] )()
 local ui = DelightUI:createUI("Mi Menú Delight")

 local category1 = ui:addDropdown("Ajustes Generales")
 category1:addButton("Activar Algo", function()
     print("¡Algo activado!")
 end)
 local toggleState = false
 category1:addToggle("Función X", toggleState, function(newState)
     toggleState = newState
     print("Función X ahora es:", newState)
 end)

 local sliderValue = 50
 category1:addSlider("Velocidad", 0, 100, sliderValue, function(value)
     sliderValue = value
     print("Velocidad:", math.floor(value))
 end)

 local category2 = ui:addDropdown("Herramientas Avanzadas")
 category2:addTextBox("Introducir Comando", function(text)
     print("Comando ejecutado:", text)
 end)

 -- Puedes destruir la UI cuando ya no la necesites:
 -- ui:destroy()
]]

local DelightUI = {}

-- [[ Core Roblox Services ]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- [[ Configuration & Aesthetics ]]
local CONFIG = {
    -- Colores
    PRIMARY_BG = Color3.fromRGB(25, 25, 25),    -- Fondo principal oscuro
    SECONDARY_BG = Color3.fromRGB(35, 35, 35),  -- Fondo de elementos (botones, toggles)
    ACCENT_GREEN = Color3.fromRGB(0, 175, 0),  -- Verde vibrante para acentos
    TEXT_COLOR = Color3.fromRGB(230, 230, 230),-- Color de texto claro
    BORDER_COLOR = Color3.fromRGB(0, 150, 0),  -- Borde sutil verde

    -- Tamaños y Espaciado
    MAIN_WIDTH = 300,
    MAIN_HEIGHT = 450,
    HEADER_HEIGHT = 30,
    ITEM_HEIGHT = 30,
    PADDING = 8,
    CORNER_RADIUS = 6,

    -- Fuentes
    FONT = Enum.Font.SourceSansPro,
    FONT_SIZE = Enum.FontSize.Size14,
    HEADER_FONT_SIZE = Enum.FontSize.Size18,
}

-- [[ Helper Functions ]]

-- Función para configurar propiedades comunes de elementos UI
local function setupUIElement(element, properties)
    for prop, value in pairs(properties) do
        pcall(function() element[prop] = value end) -- Usar pcall por si alguna propiedad no existe
    end
    return element
end

-- Función para añadir layout y esquinas a un contenedor
local function applyContainerStyling(container, paddingAmount, isVertical)
    local uilist = Instance.new("UIListLayout")
    uilist.FillDirection = isVertical and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
    uilist.Padding = UDim.new(0, CONFIG.PADDING)
    uilist.SortOrder = Enum.SortOrder.LayoutOrder
    uilist.Parent = container

    local uipadding = Instance.new("UIPadding")
    uipadding.PaddingTop = UDim.new(0, paddingAmount)
    uipadding.PaddingBottom = UDim.new(0, paddingAmount)
    uipadding.PaddingLeft = UDim.new(0, paddingAmount)
    uipadding.PaddingRight = UDim.new(0, paddingAmount)
    uipadding.Parent = container

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS)
    uicorner.Parent = container
end

-- Función para hacer un Frame arrastrable
local function makeDraggable(frame, handle)
    local dragging
    local dragInput
    local dragStart
    local startPosition

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if handle:IsAncestorOf(input.Target) or handle == input.Target then
                dragging = true
                dragInput = input
                dragStart = input.Position
                startPosition = frame.Position
                input.Handled = true
            end
        end
    end

    local function onInputChanged(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
                                        startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end

    local function onInputEnded(input)
        if input == dragInput then
            dragging = false
            dragInput = nil
        end
    end

    UserInputService.InputBegan:Connect(onInputBegan)
    UserInputService.InputChanged:Connect(onInputChanged)
    UserInputService.InputEnded:Connect(onInputEnded)
end

-- [[ DelightUI Core Class ]]
function DelightUI:createUI(title)
    local self = {}
    self.screenGuiName = "DelightUI_Mikoto_" .. LocalPlayer.Name .. "_" .. os.time()
    self.elements = {}

    -- Limpiar cualquier instancia anterior del mismo ScreenGui (si existe)
    if _G[self.screenGuiName] and _G[self.screenGuiName]:IsA("ScreenGui") then
        _G[self.screenGuiName]:Destroy()
        _G[self.screenGuiName] = nil
    end

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = self.screenGuiName
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    _G[self.screenGuiName] = screenGui -- Referencia global para limpieza

    self.screenGui = screenGui

    -- Main Frame (Window)
    local mainFrame = setupUIElement(Instance.new("Frame"), {
        Name = "MainFrame",
        Size = UDim2.new(0, CONFIG.MAIN_WIDTH, 0, CONFIG.MAIN_HEIGHT),
        Position = UDim2.new(0.5, -CONFIG.MAIN_WIDTH / 2, 0.5, -CONFIG.MAIN_HEIGHT / 2),
        BackgroundColor3 = CONFIG.PRIMARY_BG,
        BorderSizePixel = 1,
        BorderColor3 = CONFIG.BORDER_COLOR,
        AnchorPoint = Vector2.new(0.5, 0.5)
    })
    mainFrame.Parent = screenGui
    self.elements.mainFrame = mainFrame

    -- UICorner para el MainFrame
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS)
    mainCorner.Parent = mainFrame

    -- Title Bar (for dragging)
    local titleBar = setupUIElement(Instance.new("Frame"), {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, CONFIG.HEADER_HEIGHT),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = CONFIG.BORDER_COLOR,
        BorderSizePixel = 0
    })
    titleBar.Parent = mainFrame
    self.elements.titleBar = titleBar

    local titleLabel = setupUIElement(Instance.new("TextLabel"), {
        Name = "TitleLabel",
        Size = UDim2.new(1, -CONFIG.HEADER_HEIGHT, 1, 0), -- Un poco más pequeño para el botón de cerrar
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = CONFIG.TEXT_COLOR,
        Font = CONFIG.FONT,
        FontSize = CONFIG.HEADER_FONT_SIZE,
        TextScaled = true,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    titleLabel.Parent = titleBar

    local titlePadding = Instance.new("UIPadding")
    titlePadding.PaddingLeft = UDim.new(0, CONFIG.PADDING)
    titlePadding.Parent = titleLabel

    -- Close Button
    local closeButton = setupUIElement(Instance.new("TextButton"), {
        Name = "CloseButton",
        Size = UDim2.new(0, CONFIG.HEADER_HEIGHT, 1, 0),
        Position = UDim2.new(1, -CONFIG.HEADER_HEIGHT, 0, 0),
        BackgroundColor3 = CONFIG.PRIMARY_BG,
        TextColor3 = CONFIG.TEXT_COLOR,
        Font = CONFIG.FONT,
        Text = "X",
        FontSize = CONFIG.HEADER_FONT_SIZE,
        TextScaled = true,
        BorderSizePixel = 0
    })
    closeButton.Parent = titleBar
    closeButton.Activated:Connect(function()
        self:destroy()
    end)
    -- Estilo hover para el botón de cerrar
    closeButton.MouseEnter:Connect(function() closeButton.BackgroundColor3 = CONFIG.ACCENT_GREEN end)
    closeButton.MouseLeave:Connect(function() closeButton.BackgroundColor3 = CONFIG.PRIMARY_BG end)

    makeDraggable(mainFrame, titleBar) -- Hacer arrastrable por la barra de título

    -- Content Frame (where dropdowns will go)
    local contentFrame = setupUIElement(Instance.new("ScrollingFrame"), {
        Name = "ContentFrame",
        Size = UDim2.new(1, 0, 1, -CONFIG.HEADER_HEIGHT),
        Position = UDim2.new(0, 0, 0, CONFIG.HEADER_HEIGHT),
        BackgroundColor3 = CONFIG.PRIMARY_BG,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0), -- Se ajustará dinámicamente
        ScrollBarImageColor3 = CONFIG.ACCENT_GREEN,
        ScrollBarThickness = 6,
        ScrollingDirection = Enum.ScrollingDirection.Y
    })
    contentFrame.Parent = mainFrame
    self.elements.contentFrame = contentFrame

    applyContainerStyling(contentFrame, CONFIG.PADDING, true) -- Layout vertical para los dropdowns

    -- Helper para ajustar CanvasSize
    local function updateCanvasSize()
        local contentHeight = 0
        for _, child in contentFrame:GetChildren() do
            if child:IsA("Frame") and child.Name ~= "UIPadding" and child.Name ~= "UIListLayout" and child.Name ~= "UICorner" then
                contentHeight = contentHeight + child.Size.Y.Offset + (contentFrame.UIListLayout.Padding.Offset * 2)
            end
        end
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight + (CONFIG.PADDING * 2))
    end
    -- Conectar a cambios de layout para ajustar el CanvasSize
    contentFrame.UIListLayout.Changed:Connect(updateCanvasSize)
    contentFrame.ChildAdded:Connect(function(child)
        if child:IsA("Frame") then
            child.Changed:Connect(function(prop)
                if prop == "Size" then
                    updateCanvasSize()
                end
            end)
        end
        updateCanvasSize()
    end)
    contentFrame.ChildRemoved:Connect(updateCanvasSize)

    -- [[ Dropdown Class ]]
    function self:addDropdown(categoryName)
        local dropdown = {}
        local isExpanded = false

        -- Category Header Button
        local categoryButton = setupUIElement(Instance.new("TextButton"), {
            Name = categoryName .. "_Header",
            Size = UDim2.new(1, 0, 0, CONFIG.HEADER_HEIGHT),
            BackgroundColor3 = CONFIG.SECONDARY_BG,
            BorderSizePixel = 0,
            TextColor3 = CONFIG.TEXT_COLOR,
            Font = CONFIG.FONT,
            FontSize = CONFIG.FONT_SIZE,
            Text = "▼ " .. categoryName,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextScaled = true
        })
        categoryButton.Parent = contentFrame

        local categoryPadding = Instance.new("UIPadding")
        categoryPadding.PaddingLeft = UDim.new(0, CONFIG.PADDING)
        categoryPadding.Parent = categoryButton

        local categoryCorner = Instance.new("UICorner")
        categoryCorner.CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS)
        categoryCorner.Parent = categoryButton
        
        -- Estilo hover
        categoryButton.MouseEnter:Connect(function() categoryButton.BackgroundColor3 = CONFIG.ACCENT_GREEN:Lerp(CONFIG.SECONDARY_BG, 0.7) end)
        categoryButton.MouseLeave:Connect(function() categoryButton.BackgroundColor3 = CONFIG.SECONDARY_BG end)

        -- Dropdown Content Frame
        local dropdownContent = setupUIElement(Instance.new("Frame"), {
            Name = categoryName .. "_Content",
            Size = UDim2.new(1, 0, 0, 0), -- Altura inicial 0, se expandirá
            BackgroundColor3 = CONFIG.PRIMARY_BG,
            BorderSizePixel = 1,
            BorderColor3 = CONFIG.BORDER_COLOR,
            Visible = false
        })
        dropdownContent.Parent = contentFrame

        applyContainerStyling(dropdownContent, CONFIG.PADDING, true) -- Layout vertical para los ítems del dropdown
        
        -- Función para ajustar la altura del dropdownContent
        local function updateDropdownContentHeight()
            local currentHeight = 0
            if dropdownContent.Visible then
                for _, child in dropdownContent:GetChildren() do
                    if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextBox") then
                        currentHeight = currentHeight + child.Size.Y.Offset + dropdownContent.UIListLayout.Padding.Offset
                    end
                end
                dropdownContent.Size = UDim2.new(1, 0, 0, currentHeight + (CONFIG.PADDING * 2))
            else
                dropdownContent.Size = UDim2.new(1, 0, 0, 0)
            end
        end

        dropdownContent.UIListLayout.Changed:Connect(updateDropdownContentHeight)
        dropdownContent.ChildAdded:Connect(updateDropdownContentHeight)
        dropdownContent.ChildRemoved:Connect(updateDropdownContentHeight)


        local function toggleDropdown()
            isExpanded = not isExpanded
            dropdownContent.Visible = isExpanded
            categoryButton.Text = (isExpanded and "▼ " or "▶ ") .. categoryName
            updateDropdownContentHeight() -- Actualizar altura al cambiar visibilidad
        end

        categoryButton.Activated:Connect(toggleDropdown)

        -- [[ Elementos dentro del Dropdown ]]

        function dropdown:addButton(text, callback)
            local button = setupUIElement(Instance.new("TextButton"), {
                Name = text:gsub("%s+", "_") .. "_Button",
                Size = UDim2.new(1, 0, 0, CONFIG.ITEM_HEIGHT),
                BackgroundColor3 = CONFIG.SECONDARY_BG,
                BorderSizePixel = 0,
                TextColor3 = CONFIG.TEXT_COLOR,
                Font = CONFIG.FONT,
                FontSize = CONFIG.FONT_SIZE,
                Text = text,
                TextScaled = true,
                Parent = dropdownContent
            })
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS)
            btnCorner.Parent = button

            button.Activated:Connect(function()
                pcall(callback)
            end)
            -- Estilo hover
            button.MouseEnter:Connect(function() button.BackgroundColor3 = CONFIG.ACCENT_GREEN:Lerp(CONFIG.SECONDARY_BG, 0.7) end)
            button.MouseLeave:Connect(function() button.BackgroundColor3 = CONFIG.SECONDARY_BG end)
            updateDropdownContentHeight()
            return button
        end

        function dropdown:addToggle(text, initialState, callback)
            local toggleContainer = setupUIElement(Instance.new("Frame"), {
                Name = text:gsub("%s+", "_") .. "_ToggleContainer",
                Size = UDim2.new(1, 0, 0, CONFIG.ITEM_HEIGHT),
                BackgroundColor3 = CONFIG.SECONDARY_BG,
                BorderSizePixel = 0,
                Parent = dropdownContent
            })
            local tgCorner = Instance.new("UICorner")
            tgCorner.CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS)
            tgCorner.Parent = toggleContainer
            
            -- Texto del Toggle
            local toggleLabel = setupUIElement(Instance.new("TextLabel"), {
                Name = "ToggleLabel",
                Size = UDim2.new(1, -(CONFIG.ITEM_HEIGHT + CONFIG.PADDING), 1, 0),
                Position = UDim2.new(0, CONFIG.PADDING, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = CONFIG.TEXT_COLOR,
                Font = CONFIG.FONT,
                FontSize = CONFIG.FONT_SIZE,
                Text = text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextScaled = true,
                Parent = toggleContainer
            })

            -- Toggle Switch (Frame)
            local switchFrame = setupUIElement(Instance.new("Frame"), {
                Name = "SwitchFrame",
                Size = UDim2.new(0, CONFIG.ITEM_HEIGHT - CONFIG.PADDING  2, 0, CONFIG.ITEM_HEIGHT - CONFIG.PADDING  2),
                Position = UDim2.new(1, -(CONFIG.ITEM_HEIGHT - CONFIG.PADDING  2 + CONFIG.PADDING), 0.5, -(CONFIG.ITEM_HEIGHT - CONFIG.PADDING  2) / 2),
                BackgroundColor3 = CONFIG.BORDER_COLOR,
                BorderSizePixel = 0,
                Parent = toggleContainer
            })
            local switchCorner = Instance.new("UICorner")
            switchCorner.CornerRadius = UDim.new(1, 0) -- Completamente redondo
            switchCorner.Parent = switchFrame

            -- Toggle Indicator (Ball)
            local indicator = setupUIElement(Instance.new("Frame"), {
                Name = "Indicator",
                Size = UDim2.new(0, (CONFIG.ITEM_HEIGHT - CONFIG.PADDING  2) / 2, 0, (CONFIG.ITEM_HEIGHT - CONFIG.PADDING  2) / 2),
                Position = UDim2.new(0, CONFIG.PADDING / 2, 0.5, -(CONFIG.ITEM_HEIGHT - CONFIG.PADDING * 2) / 4), -- Posición inicial OFF
                BackgroundColor3 = CONFIG.TEXT_COLOR,
                BorderSizePixel = 0,
                Parent = switchFrame
            })
            local indicatorCorner = Instance.new("UICorner")
            indicatorCorner.CornerRadius = UDim.new(1, 0)
            indicatorCorner.Parent = indicator

            local currentState = initialState
            local function updateToggleVisual(state)
                if state then
                    indicator:TweenPosition(UDim2.new(1, -indicator.Size.X.Offset - CONFIG.PADDING / 2, 0.5, -(CONFIG.ITEM_HEIGHT - CONFIG.PADDING * 2) / 4), "Out", "Quad", 0.15, true)
                    switchFrame.BackgroundColor3 = CONFIG.ACCENT_GREEN
                else
                    indicator:TweenPosition(UDim2.new(0, CONFIG.PADDING / 2, 0.5, -(CONFIG.ITEM_HEIGHT - CONFIG.PADDING * 2) / 4), "Out", "Quad", 0.15, true)
                    switchFrame.BackgroundColor3 = CONFIG.BORDER_COLOR
                end
            end

            toggleContainer.Activated:Connect(function()
                currentState = not currentState
                updateToggleVisual(currentState)
                pcall(callback, currentState)
            end)

            updateToggleVisual(currentState) -- Estado inicial
            updateDropdownContentHeight()
            return toggleContainer, function(newState) currentState = newState; updateToggleVisual(newState) end -- Retorna el contenedor y una función para cambiar el estado
        end

        function dropdown:addSlider(text, min, max, initialValue, callback)
            local sliderContainer = setupUIElement(Instance.new("Frame"), {
                Name = text:gsub("%s+", "_") .. "_SliderContainer",
                Size = UDim2.new(1, 0, 0, CONFIG.ITEM_HEIGHT),
                BackgroundColor3 = CONFIG.SECONDARY_BG,
                BorderSizePixel = 0,
                Parent = dropdownContent
            })
            local sldCorner = Instance.new("UICorner")
            sldCorner.CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS)
            sldCorner.Parent = sliderContainer
            
            local sliderLabel = setupUIElement(Instance.new("TextLabel"), {
                Name = "SliderLabel",
                Size = UDim2.new(1, -CONFIG.PADDING, 0.5, 0),
                Position = UDim2.new(0, CONFIG.PADDING, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = CONFIG.TEXT_COLOR,
                Font = CONFIG.FONT,
                FontSize = CONFIG.FONT_SIZE,
                Text = text .. ": " .. tostring(math.floor(initialValue)),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextScaled = true,
                Parent = sliderContainer
            })

            -- Slider Track
            local trackFrame = setupUIElement(Instance.new("Frame"), {
                Name = "TrackFrame",
                Size = UDim2.new(1, -CONFIG.PADDING * 2, 0, 4),
                Position = UDim2.new(0, CONFIG.PADDING, 0.7, -2),
                BackgroundColor3 = CONFIG.PRIMARY_BG,
                BorderSizePixel = 0,
                Parent = sliderContainer
            })
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = trackFrame

            -- Slider Thumb
            local thumb = setupUIElement(Instance.new("Frame"), {
                Name = "Thumb",
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 0, 0.5, -8), -- Posición inicial (ajustada abajo)
                BackgroundColor3 = CONFIG.ACCENT_GREEN,
                BorderSizePixel = 0,
                Parent = trackFrame
            })
            local thumbCorner = Instance.new("UICorner")
            thumbCorner.CornerRadius = UDim.new(1, 0)
            thumbCorner.Parent = thumb

            local currentSliderValue = initialValue
            local draggingSlider = false
            local function updateThumbPosition(value)
                local percentage = (value - min) / (max - min)
                local newX = percentage * (trackFrame.AbsoluteSize.X - thumb.AbsoluteSize.X)
                thumb.Position = UDim2.new(0, newX, 0.5, -thumb.Size.Y.Offset / 2)
                sliderLabel.Text = text .. ": " .. tostring(math.floor(value))
            end

            -- Inicializar posición del thumb
            updateThumbPosition(initialValue)

            local function onThumbInputBegan(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    input.Handled = true
                end
            end

            local function onThumbInputChanged(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    local mouseX = UserInputService:GetMouseLocation().X
                    local trackX = trackFrame.AbsolutePosition.X
                    local trackWidth = trackFrame.AbsoluteSize.X

                    local newThumbX = mouseX - trackX - (thumb.AbsoluteSize.X / 2)
                    newThumbX = math.clamp(newThumbX, 0, trackWidth - thumb.AbsoluteSize.X)

                    local percentage = newThumbX / (trackWidth - thumb.AbsoluteSize.X)
                    currentSliderValue = min + (percentage * (max - min))
                    
                    updateThumbPosition(currentSliderValue)
                    pcall(callback, currentSliderValue)
                end
            end

            local function onThumbInputEnded(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end
            
            thumb.InputBegan:Connect(onThumbInputBegan)
            UserInputService.InputChanged:Connect(onThumbInputChanged)
            UserInputService.InputEnded:Connect(onThumbInputEnded)

            updateDropdownContentHeight()
            return sliderContainer, function(value) currentSliderValue = value; updateThumbPosition(value) end
        end

        function dropdown:addTextBox(placeholderText, callback)
            local textBox = setupUIElement(Instance.new("TextBox"), {
                Name = placeholderText:gsub("%s+", "_") .. "_TextBox",
                Size = UDim2.new(1, 0, 0, CONFIG.ITEM_HEIGHT),
                BackgroundColor3 = CONFIG.SECONDARY_BG,
                BorderSizePixel = 0,
                TextColor3 = CONFIG.TEXT_COLOR,
                Font = CONFIG.FONT,
                FontSize = CONFIG.FONT_SIZE,
                PlaceholderText = placeholderText,
                PlaceholderColor3 = CONFIG.TEXT_COLOR:Lerp(CONFIG.PRIMARY_BG, 0.5),
                Text = "",
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = false,
                ClearTextOnFocus = false, -- Para que no se borre al hacer clic
                Parent = dropdownContent
            })
            local tbCorner = Instance.new("UICorner")
            tbCorner.CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS)
            tbCorner.Parent = textBox

            local tbPadding = Instance.new("UIPadding")
            tbPadding.PaddingLeft = UDim.new(0, CONFIG.PADDING)
            tbPadding.Parent = textBox

            textBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    pcall(callback, textBox.Text)
                    textBox.Text = "" -- Opcional: limpiar después de enviar
                end
            end)
            updateDropdownContentHeight()
            return textBox
        end

        return dropdown
    end

    -- [[ Destructor ]]
    function self:destroy()
        if self.screenGui and self.screenGui.Parent then
            self.screenGui:Destroy()
            _G[self.screenGuiName] = nil
        end
    end

    return self
end

return DelightUI
