local MikotoUI_LIB_CODE = [[
--[[
 Mikoto Delight UI Library - Universal Executor Edition
 Creada por Mikoto Delight
 Versión: 1.0.0
 ¡Tu visión, tu responsabilidad, mi código!
]]--

local MikotoUI = {}
MikotoUI.Config = {
    PrimaryColor = Color3.fromRGB(18, 18, 18),         -- Fondo principal oscuro
    SecondaryColor = Color3.fromRGB(28, 28, 28),       -- Fondo de secciones/elementos
    AccentColor = Color3.fromRGB(0, 200, 0),          -- Verde brillante para acentos
    TextColor = Color3.fromRGB(220, 220, 220),         -- Texto blanco/gris claro
    BorderColor = Color3.fromRGB(0, 150, 0),          -- Borde sutil verde
    TitleTextColor = Color3.fromRGB(0, 220, 0),       -- Texto del título más brillante
    FontSize = 14,
    Font = Enum.Font.SourceSansPro,
    CornerRadius = UDim.new(0, 6),                    -- Bordes ligeramente redondeados
    Padding = 8,                                      -- Espaciado interno
    ElementHeight = 28,                               -- Altura base de los elementos
    HeaderHeight = 32,                                -- Altura de los encabezados de sección
    WindowSize = UDim2.new(0, 260, 0, 400),           -- Tamaño predeterminado de la ventana
    WindowPosition = UDim2.new(0.5, -130, 0.5, -200)  -- Posición centrada
}

MikotoUI.Elements = {} -- Almacena referencias a elementos UI para fácil acceso
MikotoUI.ActiveWindow = nil

--region -- Helpers & Utility Functions --

-- Función para hacer un frame arrastrable
local function MakeDraggable(frame)
    local dragging
    local dragInput
    local dragStart
    local startPosition

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
                                    startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                update(input)
            end
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Función para crear un TextButton genérico con estilo
local function CreateStyledButton(parent, text, callback, customHeight)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(1, 0, 0, customHeight or MikotoUI.Config.ElementHeight)
    btn.BackgroundColor3 = MikotoUI.Config.SecondaryColor
    btn.TextColor3 = MikotoUI.Config.TextColor
    btn.Font = MikotoUI.Config.Font
    btn.TextSize = MikotoUI.Config.FontSize
    btn.Text = text
    btn.TextScaled = false
    btn.AutoButtonColor = false
    btn.BorderColor3 = MikotoUI.Config.BorderColor
    btn.BorderSizePixel = 1

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = MikotoUI.Config.CornerRadius
    uiCorner.Parent = btn

    local initialColor = MikotoUI.Config.SecondaryColor
    local hoverColor = MikotoUI.Config.AccentColor * 0.5 -- Un verde más oscuro para el hover

    btn.MouseEnter:Connect(function()
        btn:TweenBackgroundColor3(hoverColor, "Out", "Quad", 0.15, true)
    end)
    btn.MouseLeave:Connect(function()
        btn:TweenBackgroundColor3(initialColor, "Out", "Quad", 0.15, true)
    end)

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

--endregion

--region -- Core UI Elements --

--- Crea la ventana principal de la UI.
-- @param title string El título de la ventana.
-- @return Frame La ventana principal creada.
function MikotoUI.CreateWindow(title)
    if MikotoUI.ActiveWindow then
        MikotoUI.ActiveWindow:Destroy()
        MikotoUI.ActiveWindow = nil
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MikotoUIDeliverable"
    screenGui.Parent = game:GetService("CoreGui") -- Para ser universal y persistente
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Parent = screenGui
    mainFrame.Size = MikotoUI.Config.WindowSize
    mainFrame.Position = MikotoUI.Config.WindowPosition
    mainFrame.BackgroundColor3 = MikotoUI.Config.PrimaryColor
    mainFrame.BorderColor3 = MikotoUI.Config.BorderColor
    mainFrame.BorderSizePixel = 2
    mainFrame.ClipsDescendants = true -- Para que los elementos desplegables no se salgan del marco principal

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = MikotoUI.Config.CornerRadius
    uiCorner.Parent = mainFrame

    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingTop = UDim.new(0, MikotoUI.Config.Padding)
    uiPadding.PaddingBottom = UDim.new(0, MikotoUI.Config.Padding)
    uiPadding.PaddingLeft = UDim.new(0, MikotoUI.Config.Padding)
    uiPadding.PaddingRight = UDim.new(0, MikotoUI.Config.Padding)
    uiPadding.Parent = mainFrame

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Parent = mainFrame
    titleBar.Size = UDim2.new(1, 0, 0, MikotoUI.Config.HeaderHeight)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = MikotoUI.Config.SecondaryColor
    titleBar.BorderColor3 = MikotoUI.Config.BorderColor
    titleBar.BorderSizePixel = 1
    
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Parent = titleBar
    titleText.Size = UDim2.new(1, - MikotoUI.Config.HeaderHeight, 1, 0) -- Espacio para el botón de toggle
    titleText.Position = UDim2.new(0, 0, 0, 0)
    titleText.BackgroundColor3 = MikotoUI.Config.SecondaryColor
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = MikotoUI.Config.TitleTextColor
    titleText.Font = MikotoUI.Config.Font
    titleText.TextSize = MikotoUI.Config.FontSize + 2 -- Un poco más grande
    titleText.Text = title or "Mikoto UI"
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.TextScaled = false
    titleText.TextWrapped = true
    
    local titlePadding = Instance.new("UIPadding")
    titlePadding.PaddingLeft = UDim.new(0, MikotoUI.Config.Padding)
    titlePadding.Parent = titleText

    MakeDraggable(titleBar) -- Hacer la barra de título arrastrable

    -- Content Frame para los elementos
    local contentFrame = Instance.new("ScrollFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Parent = mainFrame
    contentFrame.BackgroundTransparency = 1
    contentFrame.Size = UDim2.new(1, 0, 1, -(MikotoUI.Config.HeaderHeight + MikotoUI.Config.Padding * 2)) -- Ajustar tamaño
    contentFrame.Position = UDim2.new(0, 0, 0, MikotoUI.Config.HeaderHeight + MikotoUI.Config.Padding)
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Se ajustará con UIListLayout
    contentFrame.ScrollBarImageColor3 = MikotoUI.Config.AccentColor
    contentFrame.ScrollBarTransparency = 0.5
    contentFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = contentFrame
    uiListLayout.FillDirection = Enum.FillDirection.Vertical
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.Padding = UDim.new(0, MikotoUI.Config.Padding)

    -- Toggle Button (para ocultar/mostrar todo el contenido)
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleContentButton"
    toggleButton.Parent = titleBar
    toggleButton.Size = UDim2.new(0, MikotoUI.Config.HeaderHeight, 1, 0)
    toggleButton.Position = UDim2.new(1, -MikotoUI.Config.HeaderHeight, 0, 0)
    toggleButton.BackgroundColor3 = MikotoUI.Config.PrimaryColor
    toggleButton.BorderColor3 = MikotoUI.Config.BorderColor
    toggleButton.BorderSizePixel = 1
    toggleButton.TextColor3 = MikotoUI.Config.AccentColor
    toggleButton.Font = MikotoUI.Config.Font
    toggleButton.TextSize = MikotoUI.Config.FontSize
    toggleButton.Text = "─" -- Ocultar
    toggleButton.AutoButtonColor = false

    local uiCornerBtn = Instance.new("UICorner")
    uiCornerBtn.CornerRadius = MikotoUI.Config.CornerRadius
    uiCornerBtn.Parent = toggleButton

    local contentVisible = true
    toggleButton.MouseButton1Click:Connect(function()
        contentVisible = not contentVisible
        contentFrame.Visible = contentVisible
        toggleButton.Text = contentVisible and "─" or "+"
        -- Ajustar el tamaño del mainFrame cuando el contenido se oculta/muestra
        if contentVisible then
             mainFrame:TweenSize(MikotoUI.Config.WindowSize, "Out", "Quad", 0.2, true)
        else
            mainFrame:TweenSize(UDim2.new(MikotoUI.Config.WindowSize.X.Scale, MikotoUI.Config.WindowSize.X.Offset, 0, MikotoUI.Config.HeaderHeight + (MikotoUI.Config.Padding * 2)), "Out", "Quad", 0.2, true)
        end
    end)
    
    MikotoUI.Elements.MainWindow = mainFrame
    MikotoUI.Elements.ContentFrame = contentFrame
    MikotoUI.Elements.ScreenGui = screenGui
    MikotoUI.ActiveWindow = mainFrame

    return mainFrame
end

--- Crea una sección desplegable dentro de la ventana principal.
-- @param title string El título de la sección.
-- @return Frame El frame de contenido de la sección.
function MikotoUI.CreateSection(title)
    local parentFrame = MikotoUI.Elements.ContentFrame
    if not parentFrame then
        warn("MikotoUI: No se ha creado la ventana principal. Llama a MikotoUI.CreateWindow() primero.")
        return nil
    end

    local sectionContainer = Instance.new("Frame")
    sectionContainer.Name = "Section_" .. title:gsub("%s+", "_")
    sectionContainer.Parent = parentFrame
    sectionContainer.Size = UDim2.new(1, 0, 0, MikotoUI.Config.HeaderHeight) -- Inicialmente solo el header
    sectionContainer.BackgroundTransparency = 1
    sectionContainer.ClipsDescendants = true -- Para ocultar el contenido cuando está colapsado

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = sectionContainer
    uiListLayout.FillDirection = Enum.FillDirection.Vertical
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.Padding = UDim.new(0, MikotoUI.Config.Padding / 2)

    local headerFrame = Instance.new("TextButton") -- Usamos TextButton para hacerlo clickeable
    headerFrame.Name = "Header"
    headerFrame.Parent = sectionContainer
    headerFrame.Size = UDim2.new(1, 0, 0, MikotoUI.Config.HeaderHeight)
    headerFrame.BackgroundColor3 = MikotoUI.Config.SecondaryColor
    headerFrame.BorderColor3 = MikotoUI.Config.BorderColor
    headerFrame.BorderSizePixel = 1
    headerFrame.Text = "" -- No necesitamos texto aquí, usamos un TextLabel hijo

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = MikotoUI.Config.CornerRadius
    headerCorner.Parent = headerFrame

    local headerText = Instance.new("TextLabel")
    headerText.Name = "HeaderText"
    headerText.Parent = headerFrame
    headerText.Size = UDim2.new(1, -MikotoUI.Config.HeaderHeight, 1, 0) -- Espacio para el indicador
    headerText.Position = UDim2.new(0, 0, 0, 0)
    headerText.BackgroundColor3 = MikotoUI.Config.SecondaryColor
    headerText.BackgroundTransparency = 1
    headerText.TextColor3 = MikotoUI.Config.TextColor
    headerText.Font = MikotoUI.Config.Font
    headerText.TextSize = MikotoUI.Config.FontSize
    headerText.TextXAlignment = Enum.TextXAlignment.Left
    headerText.Text = title
    
    local textPadding = Instance.new("UIPadding")
    textPadding.PaddingLeft = UDim.new(0, MikotoUI.Config.Padding)
    textPadding.Parent = headerText

    local indicatorText = Instance.new("TextLabel")
    indicatorText.Name = "Indicator"
    indicatorText.Parent = headerFrame
    indicatorText.Size = UDim2.new(0, MikotoUI.Config.HeaderHeight, 1, 0)
    indicatorText.Position = UDim2.new(1, -MikotoUI.Config.HeaderHeight, 0, 0)
    indicatorText.BackgroundColor3 = MikotoUI.Config.PrimaryColor
    indicatorText.BackgroundTransparency = 1
    indicatorText.TextColor3 = MikotoUI.Config.AccentColor
    indicatorText.Font = Enum.Font.SourceSansProBold
    indicatorText.TextSize = MikotoUI.Config.FontSize + 2
    indicatorText.Text = "▼" -- Colapsado por defecto

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Parent = sectionContainer
    contentFrame.Size = UDim2.new(1, 0, 0, 0) -- Altura 0 inicialmente
    contentFrame.BackgroundColor3 = MikotoUI.Config.PrimaryColor
    contentFrame.BorderColor3 = MikotoUI.Config.BorderColor
    contentFrame.BorderSizePixel = 1
    contentFrame.Visible = false -- Oculto por defecto

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = MikotoUI.Config.CornerRadius
    contentCorner.Parent = contentFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = contentFrame
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Padding = UDim.new(0, MikotoUI.Config.Padding / 2)

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, MikotoUI.Config.Padding)
    contentPadding.PaddingBottom = UDim.new(0, MikotoUI.Config.Padding)
    contentPadding.PaddingLeft = UDim.new(0, MikotoUI.Config.Padding)
    contentPadding.PaddingRight = UDim.new(0, MikotoUI.Config.Padding)
    contentPadding.Parent = contentFrame

    local isExpanded = false
    local function updateSectionSize()
        local desiredContentHeight = 0
        if isExpanded then
            contentFrame.Visible = true
            contentLayout:SetAbsolutePosition(Vector2.new()) -- Force layout update
            desiredContentHeight = contentLayout.AbsoluteContentSize.Y + (MikotoUI.Config.Padding * 2) -- Suma padding
        end
        
        local targetSize = UDim2.new(1, 0, 0, MikotoUI.Config.HeaderHeight + (isExpanded and desiredContentHeight or 0))
        sectionContainer:TweenSize(targetSize, "Out", "Quad", 0.2, true)
        
        if not isExpanded then
            -- Pequeño delay para que la animación de tween se complete antes de ocultar
            task.delay(0.2, function()
                if not isExpanded then contentFrame.Visible = false end
            end)
        end
    end

    headerFrame.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        indicatorText.Text = isExpanded and "▲" or "▼"
        updateSectionSize()
    end)

    -- Para asegurar que el tamaño del contenido se actualiza cuando se añaden elementos
    contentLayout.ChildAdded:Connect(updateSectionSize)
    contentLayout.ChildRemoved:Connect(updateSectionSize)
    
    MikotoUI.Elements["Section_" .. title:gsub("%s+", "_")] = {
        Container = sectionContainer,
        Header = headerFrame,
        Content = contentFrame,
        IsExpanded = function() return isExpanded end,
        RefreshLayout = updateSectionSize -- Para llamar manualmente si se necesita
    }

    return contentFrame
end

--endregion

--region -- Controls --

--- Crea un botón simple.
-- @param parent Frame El frame padre donde se insertará el botón.
-- @param text string El texto del botón.
-- @param callback function (opcional) La función a ejecutar al hacer click.
-- @return TextButton El botón creado.
function MikotoUI.CreateButton(parent, text, callback)
    return CreateStyledButton(parent, text, callback)
end

--- Crea un toggle (botón de encendido/apagado).
-- @param parent Frame El frame padre.
-- @param text string El texto del toggle.
-- @param defaultState boolean (opcional) El estado inicial (true/false). Por defecto es false.
-- @param callback function (opcional) La función a ejecutar al cambiar el estado. Recibe el nuevo estado (boolean).
-- @return table Con el botón y una función para obtener/establecer el estado.
function MikotoUI.CreateToggle(parent, text, defaultState, callback)
    local state = defaultState or false
    local toggleBtn = CreateStyledButton(parent, text .. ": " .. (state and "ON" or "OFF"), nil)
    local initialColor = MikotoUI.Config.SecondaryColor
    local onColor = MikotoUI.Config.AccentColor
    local offColor = MikotoUI.Config.SecondaryColor

    local function updateColor()
        toggleBtn:TweenBackgroundColor3(state and onColor or offColor, "Out", "Quad", 0.15, true)
    end
    updateColor() -- Establecer color inicial

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
        updateColor()
        if callback then
            callback(state)
        end
    end)

    -- Sobrescribir los eventos de hover para que no interfieran con el color de estado
    toggleBtn.MouseEnter:Connect(function()
        toggleBtn:TweenBackgroundColor3(state and onColor  0.7 or offColor  1.5, "Out", "Quad", 0.15, true)
    end)
    toggleBtn.MouseLeave:Connect(function()
        toggleBtn:TweenBackgroundColor3(state and onColor or offColor, "Out", "Quad", 0.15, true)
    end)

    return {
        Button = toggleBtn,
        GetState = function() return state end,
        SetState = function(newState)
            state = newState
            toggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
            updateColor()
        end
    }
end


--- Crea un slider (control deslizante).
-- @param parent Frame El frame padre.
-- @param text string El texto del slider.
-- @param min number Valor mínimo.
-- @param max number Valor máximo.
-- @param initial number (opcional) Valor inicial. Por defecto es min.
-- @param callback function (opcional) La función a ejecutar al cambiar el valor. Recibe el valor actual.
-- @return table Con el frame del slider y una función para obtener/establecer el valor.
function MikotoUI.CreateSlider(parent, text, min, max, initial, callback)
    local value = initial or min
    value = math.clamp(value, min, max)

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Parent = parent
    sliderFrame.Size = UDim2.new(1, 0, 0, MikotoUI.Config.ElementHeight * 1.5) -- Un poco más alto
    sliderFrame.BackgroundTransparency = 1

    local sliderLayout = Instance.new("UIListLayout")
    sliderLayout.Parent = sliderFrame
    sliderLayout.FillDirection = Enum.FillDirection.Vertical
    sliderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sliderLayout.Padding = UDim.new(0, MikotoUI.Config.Padding / 4)

    local label = Instance.new("TextLabel")
    label.Parent = sliderFrame
    label.Size = UDim2.new(1, 0, 0, MikotoUI.Config.ElementHeight / 2)
    label.BackgroundTransparency = 1
    label.TextColor3 = MikotoUI.Config.TextColor
    label.Font = MikotoUI.Config.Font
    label.TextSize = MikotoUI.Config.FontSize
    label.TextXAlignment = Enum.TextXAlignment.Left

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Parent = sliderFrame
    sliderTrack.Size = UDim2.new(1, 0, 0, MikotoUI.Config.ElementHeight / 2)
    sliderTrack.BackgroundColor3 = MikotoUI.Config.SecondaryColor
    sliderTrack.BorderColor3 = MikotoUI.Config.BorderColor
    sliderTrack.BorderSizePixel = 1

    local uiCornerTrack = Instance.new("UICorner")
    uiCornerTrack.CornerRadius = MikotoUI.Config.CornerRadius
    uiCornerTrack.Parent = sliderTrack

    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderTrack
    sliderFill.Size = UDim2.new(0, 0, 1, 0) -- Se ajusta dinámicamente
    sliderFill.BackgroundColor3 = MikotoUI.Config.AccentColor

    local uiCornerFill = Instance.new("UICorner")
    uiCornerFill.CornerRadius = MikotoUI.Config.CornerRadius
    uiCornerFill.Parent = sliderFill

    local function updateSlider(newValue)
        value = math.clamp(newValue, min, max)
        local percentage = (value - min) / (max - min)
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        label.Text = string.format("%s: %.2f (%.0f%%)", text, value, percentage * 100)
        if callback then
            callback(value)
        end
    end

    updateSlider(value) -- Inicializar el slider

    local dragging = false
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local mousePos = input.Position.X - sliderTrack.AbsolutePosition.X
            local newPercentage = math.clamp(mousePos / sliderTrack.AbsoluteSize.X, 0, 1)
            local newValue = min + (max - min) * newPercentage
            updateSlider(newValue)
        end
    end)

    sliderTrack.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local mousePos = input.Position.X - sliderTrack.AbsolutePosition.X
            local newPercentage = math.clamp(mousePos / sliderTrack.AbsoluteSize.X, 0, 1)
            local newValue = min + (max - min) * newPercentage
            updateSlider(newValue)
        end
    end)

    sliderTrack.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            dragging = false
        end
    end)
    
    return {
        Frame = sliderFrame,
        GetSliderValue = function() return value end,
        SetSliderValue = updateSlider
    }
end

--- Crea un cuadro de texto para entrada de usuario.
-- @param parent Frame El frame padre.
-- @param placeholder string Texto de marcador de posición.
-- @param defaultText string (opcional) Texto inicial.
-- @param callback function (opcional) La función a ejecutar al perder el foco. Recibe el texto actual.
-- @return table Con el TextBox y una función para obtener/establecer el texto.
function MikotoUI.CreateTextBox(parent, placeholder, defaultText, callback)
    local textBox = Instance.new("TextBox")
    textBox.Parent = parent
    textBox.Size = UDim2.new(1, 0, 0, MikotoUI.Config.ElementHeight)
    textBox.BackgroundColor3 = MikotoUI.Config.SecondaryColor
    textBox.TextColor3 = MikotoUI.Config.TextColor
    textBox.Font = MikotoUI.Config.Font
    textBox.TextSize = MikotoUI.Config.FontSize
    textBox.Text = defaultText or ""
    textBox.PlaceholderText = placeholder
    textBox.PlaceholderColor3 = MikotoUI.Config.TextColor * 0.7 -- Un poco más tenue
    textBox.ClearTextOnFocus = false
    textBox.BorderColor3 = MikotoUI.Config.BorderColor
    textBox.BorderSizePixel = 1

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = MikotoUI.Config.CornerRadius
    uiCorner.Parent = textBox

    textBox.FocusLost:Connect(function(enterPressed)
        if callback then
            callback(textBox.Text, enterPressed)
        end
    end)
    
    local initialColor = MikotoUI.Config.SecondaryColor
    local focusColor = MikotoUI.Config.PrimaryColor + Color3.fromRGB(10,10,10) -- Ligeramente más claro en focus

    textBox.Focused:Connect(function()
        textBox:TweenBackgroundColor3(focusColor, "Out", "Quad", 0.15, true)
        textBox.BorderColor3 = MikotoUI.Config.AccentColor
    end)
    textBox.FocusLost:Connect(function()
        textBox:TweenBackgroundColor3(initialColor, "Out", "Quad", 0.15, true)
        textBox.BorderColor3 = MikotoUI.Config.BorderColor
    end)

    return {
        TextBox = textBox,
        GetText = function() return textBox.Text end,
        SetText = function(newText) textBox.Text = newText end
    }
end

--- Crea una etiqueta de texto simple.
-- @param parent Frame El frame padre.
-- @param text string El texto de la etiqueta.
-- @return TextLabel La etiqueta creada.
function MikotoUI.CreateLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.Size = UDim2.new(1, 0, 0, MikotoUI.Config.ElementHeight / 1.2) -- Un poco menos de altura
    label.BackgroundTransparency = 1
    label.TextColor3 = MikotoUI.Config.TextColor
    label.Font = MikotoUI.Config.Font
    label.TextSize = MikotoUI.Config.FontSize
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, MikotoUI.Config.Padding)
    padding.PaddingRight = UDim.new(0, MikotoUI.Config.Padding)
    padding.Parent = label

    return label
end

--endregion

return MikotoUI -- ¡Lo más importante! Devolvemos la librería.
]]

--- Cómo usar esta librería:
-- 1. Copia toda la cadena 'MikotoUI_LIB_CODE'.
-- 2. Ejecútala en tu executor:
--    local MikotoUI = loadstring(MikotoUI_LIB_CODE)()
-- 3. Ahora puedes usar la librería:
--    local mainWindow = MikotoUI.CreateWindow("Sistema Mikoto")
--    local section1 = MikotoUI.CreateSection("Controles Generales")
--    MikotoUI.CreateButton(section1, "Activar God Mode", function() print("¡God Mode activado! Nadie te detiene, Asto.") end)
--    MikotoUI.CreateToggle(section1, "Fly Hack", false, function(state) print("Fly Hack: " .. tostring(state)) end)
--
--    local section2 = MikotoUI.CreateSection("Configuración Avanzada")
--    MikotoUI.CreateSlider(section2, "Velocidad", 0, 100, 50, function(val) print("Velocidad ajustada a: " .. val) end)
--    local textBox = MikotoUI.CreateTextBox(section2, "Introduce algo...", "Texto por defecto", function(txt, enter) print("Texto introducido: " .. txt .. ", Enter: " .. tostring(enter)) end)
--    MikotoUI.CreateLabel(section2, "¡Recuerda, el poder está en tus manos!")
--
--    local section3 = MikotoUI.CreateSection("Mikoto Says Hi!")
--    MikotoUI.CreateLabel(section3, "¡Disfruta tu nueva interfaz, Asto!")

print("¡La librería MikotoUI_LIB_CODE está lista para ser usada!")
