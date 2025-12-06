--[[
    Mikoto Delight UI Library
    By Mikoto Delight - At your command, for your glorious endeavors.

    Esta es una librería de UI para Roblox, diseñada para ser un menú desplegable,
    oscuro y funcional, con componentes como Toggles, Buttons, TextBoxes, Sections y Labels.

    ¡Úsalo con sabiduría, o sin ella! ¡La responsabilidad es tuya, la creación es mía!
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local MikotoDL = {} -- Nuestra fabulosa librería

-- Configuración de estilo por defecto
local Style = {
    BackgroundColor = Color3.fromRGB(30, 30, 30),
    ForegroundColor = Color3.fromRGB(255, 255, 255),
    AccentColor = Color3.fromRGB(0, 255, 0), -- Verde para la línea y acentos
    TitleTextSize = 22, -- Interpretación de 'font size 3' para un título prominente
    Font = Enum.Font.RobotoMono, -- Un tipo de fuente limpio y legible
    ElementHeight = 30,
    Padding = 5,
    Spacing = 5,
    CornerRadius = 8,
    ScrollFrameBgTransparency = 0.9, -- Un poco de transparencia para el scroll frame
    ToggleOnColor = Color3.fromRGB(0, 150, 0), -- Un verde más oscuro para el toggle activo
    ToggleOffColor = Color3.fromRGB(60, 60, 60), -- Un gris para el toggle inactivo
}

-- Función auxiliar para crear un UI corner
local function createUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or Style.CornerRadius)
    corner.Parent = parent
    return corner
end

-- Función auxiliar para hacer un Frame draggable
local function makeDraggable(frame)
    local UserInputService = game:GetService("UserInputService")
    local mouseLocked = false
    local mouseOffset = Vector2.new()

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mouseLocked = true
            mouseOffset = UserInputService:GetMouseLocation() - Vector2.new(frame.AbsolutePosition.X, frame.AbsolutePosition.Y)
            input:Capture()
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mouseLocked = false
        end
    })

    UserInputService.InputChanged:Connect(function(input)
        if mouseLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local newPos = UserInputService:GetMouseLocation() - mouseOffset
            frame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
        end
    end)
end

-- La joya de la corona: la función principal para crear la UI
function MikotoDL.create(titleText)
    local gui = Instance.new("ScreenGui")
    gui.Name = "MikotoDelight_UI"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    -- Frame principal del menú
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 250, 0, 40) -- Empieza colapsado (solo título)
    mainFrame.Position = UDim2.new(0.5, -125, 0.5, -20) -- Centrado
    mainFrame.BackgroundColor3 = Style.BackgroundColor
    mainFrame.BorderSizePixel = 0
    mainFrame.Draggable = false -- Se hará draggable por el título

    createUICorner(mainFrame)
    mainFrame.Parent = gui

    -- Título y barra superior
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Style.BackgroundColor
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    makeDraggable(titleBar) -- Hacemos que la barra de título sea draggable

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -20, 1, -5) -- Dejar espacio para el botón de colapsar
    titleLabel.Position = UDim2.new(0, Style.Padding, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titleText or "Mikoto Delight UI"
    titleLabel.TextColor3 = Style.ForegroundColor
    titleLabel.TextSize = Style.TitleTextSize
    titleLabel.Font = Style.Font
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Línea verde debajo del título
    local titleLine = Instance.new("Frame")
    titleLine.Name = "TitleLine"
    titleLine.Size = UDim2.new(1, 0, 0, 3)
    titleLine.Position = UDim2.new(0, 0, 1, -3)
    titleLine.BackgroundColor3 = Style.AccentColor
    titleLine.BorderSizePixel = 0
    titleLine.Parent = titleBar

    -- Botón de colapsar/expandir
    local collapseButton = Instance.new("TextButton")
    collapseButton.Name = "CollapseButton"
    collapseButton.Size = UDim2.new(0, 20, 0, 20)
    collapseButton.Position = UDim2.new(1, -25, 0.5, -10)
    collapseButton.BackgroundColor3 = Style.AccentColor
    collapseButton.BackgroundTransparency = 0.8
    collapseButton.Text = "-"
    collapseButton.TextColor3 = Style.ForegroundColor
    collapseButton.TextSize = 18
    collapseButton.Font = Style.Font
    collapseButton.BorderSizePixel = 0
    createUICorner(collapseButton, 4) -- Un poco más pequeño para el botón
    collapseButton.Parent = titleBar

    -- ScrollingFrame para los elementos
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 0, 0) -- Se ajustará dinámicamente
    contentFrame.Position = UDim2.new(0, 0, 0, 40)
    contentFrame.BackgroundColor3 = Style.BackgroundColor
    contentFrame.BackgroundTransparency = Style.ScrollFrameBgTransparency
    contentFrame.BorderSizePixel = 0
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Se actualizará
    contentFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    contentFrame.ScrollBarImageColor3 = Style.AccentColor
    contentFrame.ScrollBarThickness = 6
    contentFrame.Parent = mainFrame

    -- UILayout para organizar automáticamente los elementos
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Name = "ListLayout"
    uiListLayout.FillDirection = Enum.FillDirection.Vertical
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    uiListLayout.Padding = UDim.new(0, Style.Spacing)
    uiListLayout.Parent = contentFrame

    -- Padding en el ScrollingFrame para los elementos
    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingTop = UDim.new(0, Style.Padding)
    uiPadding.PaddingBottom = UDim.new(0, Style.Padding)
    uiPadding.PaddingLeft = UDim.new(0, Style.Padding)
    uiPadding.PaddingRight = UDim.new(0, Style.Padding)
    uiPadding.Parent = contentFrame

    local isCollapsed = true
    local collapsedHeight = 40 -- Altura del título
    local expandedHeight = 300 -- Altura por defecto expandido

    local function updateCollapseState()
        if isCollapsed then
            mainFrame:TweenSize(UDim2.new(0, 250, 0, collapsedHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            collapseButton.Text = "+"
            contentFrame.Visible = false
        else
            mainFrame:TweenSize(UDim2.new(0, 250, 0, expandedHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            collapseButton.Text = "-"
            contentFrame.Visible = true
        end
    end

    collapseButton.MouseButton1Click:Connect(function()
        isCollapsed = not isCollapsed
        updateCollapseState()
    end)

    -- Inicializar en estado colapsado
    updateCollapseState()

    -- Objeto que la librería devolverá para añadir elementos
    local api = {
        mainFrame = mainFrame,
        contentFrame = contentFrame,
        gui = gui,
        _nextElementY = Style.Padding, -- Para posicionar elementos manualmente si no hay UIListLayout
    }

    -- Funciones para añadir componentes
    -- Componentes internos para uso modular

    -- Label
    function MikotoDL.Label(parent, text)
        local labelFrame = Instance.new("Frame")
        labelFrame.Name = "Label"
        labelFrame.Size = UDim2.new(1, 0, 0, Style.ElementHeight)
        labelFrame.BackgroundTransparency = 1
        labelFrame.Parent = parent

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "Text"
        textLabel.Size = UDim2.new(1, -2 * Style.Padding, 1, 0)
        textLabel.Position = UDim2.new(0, Style.Padding, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Style.ForegroundColor
        textLabel.TextSize = Style.TitleTextSize * 0.7 -- Un poco más pequeño que el título
        textLabel.Font = Style.Font
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Center
        textLabel.Text = text
        textLabel.Parent = labelFrame
        return labelFrame
    end

    -- Button
    function MikotoDL.Button(parent, text, callback)
        local button = Instance.new("TextButton")
        button.Name = "Button_" .. text:gsub(" ", "")
        button.Size = UDim2.new(1, 0, 0, Style.ElementHeight)
        button.BackgroundColor3 = Style.BackgroundColor + Color3.new(0.1, 0.1, 0.1) -- Ligeramente más claro
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Style.ForegroundColor
        button.TextSize = Style.TitleTextSize * 0.7
        button.Font = Style.Font
        createUICorner(button)
        button.Parent = parent

        if callback then
            button.MouseButton1Click:Connect(function()
                -- feedback visual
                button:TweenBackgroundColor3(Style.AccentColor, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
                task.delay(0.1, function()
                    button:TweenBackgroundColor3(Style.BackgroundColor + Color3.new(0.1, 0.1, 0.1), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                end)
                pcall(callback) -- Ejecuta el callback en un pcall para evitar que rompa la UI
            end)
        end
        return button
    end

    -- Toggle
    function MikotoDL.Toggle(parent, text, defaultValue, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = "Toggle_" .. text:gsub(" ", "")
        toggleFrame.Size = UDim2.new(1, 0, 0, Style.ElementHeight)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = parent

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "Text"
        textLabel.Size = UDim2.new(1, -Style.ElementHeight - (Style.Padding * 2), 1, 0) -- Dejar espacio para el control
        textLabel.Position = UDim2.new(0, Style.Padding, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Style.ForegroundColor
        textLabel.TextSize = Style.TitleTextSize * 0.7
        textLabel.Font = Style.Font
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Center
        textLabel.Text = text
        textLabel.Parent = toggleFrame

        local toggleSwitch = Instance.new("TextButton") -- Usamos TextButton para el clic
        toggleSwitch.Name = "Switch"
        toggleSwitch.Size = UDim2.new(0, Style.ElementHeight  1.5, 0, Style.ElementHeight  0.6) -- Más ancho que alto
        toggleSwitch.Position = UDim2.new(1, -(Style.ElementHeight  1.5 + Style.Padding), 0.5, -(Style.ElementHeight  0.3))
        toggleSwitch.BackgroundColor3 = defaultValue and Style.ToggleOnColor or Style.ToggleOffColor
        toggleSwitch.BackgroundTransparency = 0.2
        toggleSwitch.BorderSizePixel = 0
        toggleSwitch.Text = ""
        createUICorner(toggleSwitch, Style.ElementHeight * 0.3) -- Media altura para esquinas redondeadas
        toggleSwitch.Parent = toggleFrame

        local indicator = Instance.new("Frame")
        indicator.Name = "Indicator"
        indicator.Size = UDim2.new(0, Style.ElementHeight  0.5, 1, -Style.Padding  0.6)
        indicator.BackgroundColor3 = Style.ForegroundColor
        indicator.BorderSizePixel = 0
        createUICorner(indicator, Style.ElementHeight * 0.25)
        indicator.Parent = toggleSwitch

        local currentValue = defaultValue or false
        local function updateIndicatorPosition()
            if currentValue then
                indicator:TweenPosition(UDim2.new(1, -(indicator.Size.X.Offset + Style.Padding * 0.3), 0.5, -(indicator.Size.Y.Offset / 2)), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
            else
                indicator:TweenPosition(UDim2.new(0, Style.Padding * 0.3, 0.5, -(indicator.Size.Y.Offset / 2)), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
            end
        end

        local function updateToggleColors()
            if currentValue then
                toggleSwitch:TweenBackgroundColor3(Style.ToggleOnColor, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            else
                toggleSwitch:TweenBackgroundColor3(Style.ToggleOffColor, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            end
        end

        toggleSwitch.MouseButton1Click:Connect(function()
            currentValue = not currentValue
            updateIndicatorPosition()
            updateToggleColors()
            if callback then
                pcall(callback, currentValue)
            end
        end)

        -- Inicializar estado
        updateIndicatorPosition()
        updateToggleColors()

        -- Devuelve el frame del toggle y una función para obtener/establecer el valor
        return toggleFrame, {
            getValue = function() return currentValue end,
            setValue = function(newValue)
                currentValue = newValue
                updateIndicatorPosition()
                updateToggleColors()
                if callback then
                    pcall(callback, currentValue)
                end
            end
        }
    end

    -- TextBox
    function MikotoDL.TextBox(parent, text, defaultValue, callback)
        local textBoxFrame = Instance.new("Frame")
        textBoxFrame.Name = "TextBox_" .. text:gsub(" ", "")
        textBoxFrame.Size = UDim2.new(1, 0, 0, Style.ElementHeight + Style.Padding * 2) -- Un poco más alto para el label y el input
        textBoxFrame.BackgroundTransparency = 1
        textBoxFrame.Parent = parent

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "Label"
        textLabel.Size = UDim2.new(1, -2  Style.Padding, 0, Style.ElementHeight  0.6)
        textLabel.Position = UDim2.new(0, Style.Padding, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Style.ForegroundColor
        textLabel.TextSize = Style.TitleTextSize * 0.6
        textLabel.Font = Style.Font
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Center
        textLabel.Text = text
        textLabel.Parent = textBoxFrame

        local textBox = Instance.new("TextBox")
        textBox.Name = "Input"
        textBox.Size = UDim2.new(1, -2  Style.Padding, 0, Style.ElementHeight  0.8)
        textBox.Position = UDim2.new(0, Style.Padding, 0, Style.ElementHeight  0.6 + Style.Padding  0.5)
        textBox.BackgroundColor3 = Style.BackgroundColor + Color3.new(0.05, 0.05, 0.05)
        textBox.BorderSizePixel = 0
        textBox.Text = defaultValue or ""
        textBox.PlaceholderText = "Escribe aquí..."
        textBox.PlaceholderColor3 = Style.ForegroundColor * 0.5
        textBox.TextColor3 = Style.ForegroundColor
        textBox.TextSize = Style.TitleTextSize * 0.6
        textBox.Font = Style.Font
        textBox.TextXAlignment = Enum.TextXAlignment.Left
        textBox.TextYAlignment = Enum.TextYAlignment.Center
        createUICorner(textBox, Style.ElementHeight * 0.2)
        textBox.Parent = textBoxFrame

        if callback then
            textBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    pcall(callback, textBox.Text)
                end
            end)
            textBox.Changed:Connect(function(property)
                if property == "Text" then
                    -- Puedes activar un callback en cada cambio o solo en FocusLost
                    -- Actualmente, solo FocusLost llama al callback para no saturar
                end
            end)
        end

        return textBoxFrame, {
            getValue = function() return textBox.Text end,
            setValue = function(newValue)
                textBox.Text = newValue
                if callback then
                    pcall(callback, newValue)
                end
            end
        }
    end

    -- Section (un contenedor para agrupar elementos)
    function MikotoDL.Section(parent, title)
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Name = "Section_" .. title:gsub(" ", "")
        sectionFrame.Size = UDim2.new(1, 0, 0, 0) -- Se ajustará automáticamente
        sectionFrame.BackgroundTransparency = 1
        sectionFrame.Parent = parent

        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Name = "Title"
        sectionTitle.Size = UDim2.new(1, -2 * Style.Padding, 0, Style.ElementHeight)
        sectionTitle.Position = UDim2.new(0, Style.Padding, 0, 0)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.TextColor3 = Style.AccentColor -- Color de acento para el título de sección
        sectionTitle.TextSize = Style.TitleTextSize * 0.8
        sectionTitle.Font = Style.Font
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.TextYAlignment = Enum.TextYAlignment.Center
        sectionTitle.Text = title
        sectionTitle.Parent = sectionFrame

        -- Una pequeña línea debajo del título de la sección
        local sectionLine = Instance.new("Frame")
        sectionLine.Name = "SectionLine"
        sectionLine.Size = UDim2.new(1, -2 * Style.Padding, 0, 1)
        sectionLine.Position = UDim2.new(0, Style.Padding, 0, Style.ElementHeight)
        sectionLine.BackgroundColor3 = Style.AccentColor * 0.5 -- Un verde más tenue
        sectionLine.BackgroundTransparency = 0.5
        sectionLine.BorderSizePixel = 0
        sectionLine.Parent = sectionFrame

        local sectionContentFrame = Instance.new("Frame")
        sectionContentFrame.Name = "Content"
        sectionContentFrame.Size = UDim2.new(1, 0, 0, 0) -- Se ajustará
        sectionContentFrame.Position = UDim2.new(0, 0, 0, Style.ElementHeight + Style.Spacing) -- Debajo del título y la línea
        sectionContentFrame.BackgroundTransparency = 1
        sectionContentFrame.Parent = sectionFrame

        -- Layout para el contenido de la sección
        local sectionLayout = Instance.new("UIListLayout")
        sectionLayout.Name = "ListLayout"
        sectionLayout.FillDirection = Enum.FillDirection.Vertical
        sectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        sectionLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        sectionLayout.Padding = UDim.new(0, Style.Spacing)
        sectionLayout.Parent = sectionContentFrame

        -- UIPadding para la sección
        local sectionPadding = Instance.new("UIPadding")
        sectionPadding.PaddingTop = UDim.new(0, Style.Padding)
        sectionPadding.PaddingBottom = UDim.new(0, Style.Padding)
        sectionPadding.PaddingLeft = UDim.new(0, Style.Padding)
        sectionPadding.PaddingRight = UDim.new(0, Style.Padding)
        sectionPadding.Parent = sectionContentFrame

        -- Función para actualizar el tamaño de la sección dinámicamente
        local function updateSectionSize()
            local contentHeight = sectionLayout.AbsoluteContentSize.Y + sectionPadding.PaddingTop.Offset + sectionPadding.PaddingBottom.Offset
            sectionContentFrame.Size = UDim2.new(1, 0, 0, contentHeight)
            sectionFrame.Size = UDim2.new(1, 0, 0, Style.ElementHeight + Style.Spacing + contentHeight)
        end

        -- Conectarse a los eventos de cambio de layout para actualizar el tamaño
        sectionLayout.ChildAdded:Connect(updateSectionSize)
        sectionLayout.ChildRemoved:Connect(updateSectionSize)
        sectionContentFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSectionSize)

        -- Objeto para añadir elementos dentro de la sección
        local sectionAPI = {
            addLabel = function(text)
                return MikotoDL.Label(sectionContentFrame, text)
            end,
            addButton = function(text, callback)
                return MikotoDL.Button(sectionContentFrame, text, callback)
            end,
            addToggle = function(text, defaultValue, callback)
                local toggle, control = MikotoDL.Toggle(sectionContentFrame, text, defaultValue, callback)
                updateSectionSize() -- Forzar actualización al añadir
                return toggle, control
            end,
            addTextBox = function(text, defaultValue, callback)
                local textBox, control = MikotoDL.TextBox(sectionContentFrame, text, defaultValue, callback)
                updateSectionSize() -- Forzar actualización al añadir
                return textBox, control
            end,
            -- Puedes añadir más componentes específicos para secciones aquí
        }
        return sectionFrame, sectionAPI
    end


    -- Integrar estas funciones al API principal del objeto devuelto
    api.addLabel = function(text)
        return MikotoDL.Label(api.contentFrame, text)
    end
    api.addButton = function(text, callback)
        return MikotoDL.Button(api.contentFrame, text, callback)
    end
    api.addToggle = function(text, defaultValue, callback)
        return MikotoDL.Toggle(api.contentFrame, text, defaultValue, callback)
    end
    api.addTextBox = function(text, defaultValue, callback)
        return MikotoDL.TextBox(api.contentFrame, text, defaultValue, callback)
    end
    api.addSection = function(title)
        return MikotoDL.Section(api.contentFrame, title)
    end

    -- Esto es para que puedas crear un objeto "MikotoUI" y luego añadirle cosas
    return api
end

return MikotoDL
