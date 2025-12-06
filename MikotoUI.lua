--[[
  Mikoto Delight UI Library
  Desarrollado por Mikoto Delight - Tu scripter y exploiter de confianza.

  Uso:
  local MikotoDelight = require(path.to.this.script)
  local UI = MikotoDelight.CreateLib("Mi Fabuloso Menu")

  local Tab1 = UI:NewSection("Configuracion General")
  Tab1:NewToggle("Modo Dios", "Activa la invencibilidad para el jugador", function(state)
      print("Modo Dios:", state)
      -- game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50 -- Ejemplo de uso
  end, true)

  Tab1:NewButton("Teletransportar", "Teletransporta al jugador a una ubicacion", function()
      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
  end)

  local Tab2 = UI:NewSection("Opciones Visuales")
  Tab2:NewSlider("Campo de Vision (FOV)", "Ajusta el campo de vision de la camara", 70, 120, 90, function(value)
      workspace.CurrentCamera.FieldOfView = value
  end)

  Tab2:NewTextBox("Nombre de Usuario", "Introduce tu nombre de usuario", function(text)
      print("Texto ingresado:", text)
  end, "MikotoFan")

  Tab2:NewLabel("¡Bienvenido a Mikoto Delight!")

  local DropdownTest = Tab2:NewDropdown("Seleccionar Arma", "Elige tu arma favorita", {"Espada", "Arco", "Daga", "Hacha"}, "Espada", function(selection)
      print("Arma seleccionada:", selection)
  end)

  Tab2:NewKeybind("Activar Super Salto", "Pulsa la tecla para super salto", "Q", function()
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = 150
  end)

  Tab2:NewColorPicker("Color de Habilidad", "Elige el color para tu habilidad", Color3.fromRGB(0,255,0), function(color)
      print("Color elegido:", color)
  end)

  -- Para guardar/cargar la configuracion:
  -- MikotoDelight.Save()
  -- MikotoDelight.Load()

  -- Para destruir el menu:
  -- UI.Destroy()
]]

-- Servicios de Roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") -- Para guardar/cargar ajustes

-- Tabla principal de la librería
local Mikoto = {}
local Utility = {}
local Objects = {} -- Almacena referencias a objetos UI para actualizaciones dinámicas de tema
local Settings = {} -- Almacena el estado de los elementos persistentes

-- Tema por defecto (negro, texto blanco, acento verde)
local currentTheme = {
    Background = Color3.fromRGB(30, 30, 30),
    Header = Color3.fromRGB(25, 25, 25), -- Ligeramente más oscuro para el encabezado
    Accent = Color3.fromRGB(0, 200, 0),  -- Línea verde y elementos activos
    TextColor = Color3.fromRGB(255, 255, 255),
    ElementBackground = Color3.fromRGB(40, 40, 40), -- Fondo para botones, toggles, etc.
    ElementHover = Color3.fromRGB(50, 50, 50),     -- Estado de hover para elementos
    InputBackground = Color3.fromRGB(35, 35, 35), -- Fondo para TextBoxes
    BorderColor = Color3.fromRGB(60, 60, 60),      -- Color de borde sutil
    TooltipBackground = Color3.fromRGB(20, 20, 20),
    TooltipTextColor = Color3.fromRGB(200, 200, 200),
}

local currentLibName = "" -- Almacena el nombre de la instancia actual de la librería

-- Funciones de Utilidad
function Utility:TweenObject(obj, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(duration or 0.2, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
    TweenService:Create(obj, tweenInfo, properties):Play()
end

function Utility:DraggingEnabled(frame, parent)
    parent = parent or frame
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position

            -- Desconectar InputChanged si el usuario suelta el botón
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    -- Mover el frame mientras se arrastra
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- Gestión de Ajustes
local settingsFileName = "MikotoDelight_Settings.json"
local function saveSettings()
    local success, err = pcall(function()
        writefile(settingsFileName, HttpService:JSONEncode(Settings))
    end)
    if not success then
        warn("Mikoto Delight: Fallo al guardar ajustes:", err)
    end
end

local function loadSettings()
    local success, content = pcall(function()
        return readfile(settingsFileName)
    end)
    if success and content then
        local decoded, err = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if decoded then
            Settings = decoded
        else
            warn("Mikoto Delight: Fallo al decodificar ajustes, creando nuevos:", err)
            Settings = {}
            saveSettings()
        end
    else
        -- El archivo no existe o no se pudo leer, se crean nuevos ajustes
        Settings = {}
        saveSettings()
    end
end
loadSettings() -- Cargar ajustes al inicializar la librería

function Mikoto.Save()
    saveSettings()
end

function Mikoto.Load()
    loadSettings()
end

-- Función para aplicar tema a un elemento UI
local function applyTheme(element, property, colorValue)
    if Objects[element] == nil then
        Objects[element] = {}
    end
    Objects[element][property] = colorValue
    element[property] = colorValue
end

-- Creación de la Librería Principal
function Mikoto.CreateLib(name, initialPosition)
    name = name or "Mikoto Delight UI"
    initialPosition = initialPosition or UDim2.new(0.3, 0, 0.3, 0)
    currentLibName = name -- Establecer el nombre de la librería actual

    -- Limpiar cualquier UI existente con el mismo nombre
    for _, child in ipairs(game.CoreGui:GetChildren()) do
        if child:IsA("ScreenGui") and child.Name == name then
            child:Destroy()
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = name
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.Size = UDim2.new(0, 300, 0, 400) -- Tamaño compacto por defecto
    MainFrame.Position = initialPosition
    MainFrame.BackgroundColor3 = currentTheme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    applyTheme(MainFrame, "BackgroundColor3", currentTheme.Background)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local HeaderFrame = Instance.new("Frame")
    HeaderFrame.Name = "HeaderFrame"
    HeaderFrame.Parent = MainFrame
    HeaderFrame.Size = UDim2.new(1, 0, 0, 35)
    HeaderFrame.Position = UDim2.new(0, 0, 0, 0)
    HeaderFrame.BackgroundColor3 = currentTheme.Header
    HeaderFrame.BorderSizePixel = 0
    applyTheme(HeaderFrame, "BackgroundColor3", currentTheme.Header)
    Utility:DraggingEnabled(HeaderFrame, MainFrame) -- Hacer el encabezado arrastrable

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = HeaderFrame
    TitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0.05, 0, 0, 0)
    TitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = name
    TitleLabel.Font = Enum.Font.GothamBold -- Fuente moderna y legible
    TitleLabel.TextSize = 24 -- Ajustado para la legibilidad del título
    TitleLabel.TextColor3 = currentTheme.TextColor
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    applyTheme(TitleLabel, "TextColor3", currentTheme.TextColor)

    local TitleLine = Instance.new("Frame")
    TitleLine.Name = "TitleLine"
    TitleLine.Parent = HeaderFrame
    TitleLine.Size = UDim2.new(0.9, 0, 0, 2)
    TitleLine.Position = UDim2.new(0.05, 0, 1, -2) -- Justo debajo del texto del título
    TitleLine.BackgroundColor3 = currentTheme.Accent
    TitleLine.BorderSizePixel = 0
    applyTheme(TitleLine, "BackgroundColor3", currentTheme.Accent)

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = HeaderFrame
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 2.5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Rojo para cerrar
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 20
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.BorderSizePixel = 0

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton

    CloseButton.MouseButton1Click:Connect(function()
        Utility:TweenObject(MainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.AbsolutePosition.X + (MainFrame.AbsoluteSize.X / 2),
                                MainFrame.Position.Y.Scale, MainFrame.AbsolutePosition.Y + (MainFrame.AbsoluteSize.Y / 2))
        }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        task.wait(0.2)
        ScreenGui:Destroy()
    end)

    local ContentScrollingFrame = Instance.new("ScrollingFrame")
    ContentScrollingFrame.Name = "Content"
    ContentScrollingFrame.Parent = MainFrame
    ContentScrollingFrame.Size = UDim2.new(1, 0, 1, -HeaderFrame.Size.Y.Offset)
    ContentScrollingFrame.Position = UDim2.new(0, 0, 0, HeaderFrame.Size.Y.Offset)
    ContentScrollingFrame.BackgroundColor3 = currentTheme.Background
    ContentScrollingFrame.BackgroundTransparency = 1
    ContentScrollingFrame.BorderSizePixel = 0
    ContentScrollingFrame.ScrollBarThickness = 6
    ContentScrollingFrame.ScrollBarImageColor3 = currentTheme.Accent
    applyTheme(ContentScrollingFrame, "BackgroundColor3", currentTheme.Background)
    applyTheme(ContentScrollingFrame, "ScrollBarImageColor3", currentTheme.Accent)


    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Name = "ContentLayout"
    UIListLayout.Parent = ContentScrollingFrame
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Función para actualizar CanvasSize dinámicamente
    local function updateCanvasSize()
        -- Permitir que UIListLayout calcule el tamaño primero, luego ajustar
        task.wait()
        local contentSize = UIListLayout.AbsoluteContentSize
        ContentScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y)
    end
    -- Conectar a ChildAdded/Removed y a la propiedad AbsoluteContentSize del layout
    ContentScrollingFrame.ChildAdded:Connect(updateCanvasSize)
    ContentScrollingFrame.ChildRemoved:Connect(updateCanvasSize)
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    task.wait() -- Permitir que la UI se renderice inicialmente
    updateCanvasSize()

    -- Frame para Tooltips (en la parte inferior, inicialmente oculto)
    local TooltipFrame = Instance.new("Frame")
    TooltipFrame.Name = "TooltipFrame"
    TooltipFrame.Parent = MainFrame
    TooltipFrame.Size = UDim2.new(1, 0, 0, 25)
    TooltipFrame.Position = UDim2.new(0, 0, 1, 0) -- Oculto debajo
    TooltipFrame.BackgroundColor3 = currentTheme.TooltipBackground
    TooltipFrame.BorderSizePixel = 0
    TooltipFrame.Visible = false
    applyTheme(TooltipFrame, "BackgroundColor3", currentTheme.TooltipBackground)

    local TooltipText = Instance.new("TextLabel")
    TooltipText.Name = "TooltipText"
    TooltipText.Parent = TooltipFrame
    TooltipText.Size = UDim2.new(1, -10, 1, 0)
    TooltipText.Position = UDim2.new(0, 5, 0, 0)
    TooltipText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TooltipText.BackgroundTransparency = 1
    TooltipText.Text = ""
    TooltipText.Font = Enum.Font.SourceSans
    TooltipText.TextSize = 13
    TooltipText.TextColor3 = currentTheme.TooltipTextColor
    TooltipText.TextXAlignment = Enum.TextXAlignment.Left
    applyTheme(TooltipText, "TextColor3", currentTheme.TooltipTextColor)

    local function showTooltip(text)
        TooltipText.Text = text
        TooltipFrame.Visible = true
        Utility:TweenObject(TooltipFrame, {Position = UDim2.new(0, 0, 1, -TooltipFrame.Size.Y.Offset)}, 0.15)
    end

    local function hideTooltip()
        Utility:TweenObject(TooltipFrame, {Position = UDim2.new(0, 0, 1, 0)}, 0.15)
        task.wait(0.15)
        TooltipFrame.Visible = false
    end

    -- Bucle de actualización del tema (RunService.Heartbeat para eficiencia)
    local themeUpdateConnection
    if themeUpdateConnection then themeUpdateConnection:Disconnect() end
    themeUpdateConnection = RunService.Heartbeat:Connect(function()
        MainFrame.BackgroundColor3 = currentTheme.Background
        HeaderFrame.BackgroundColor3 = currentTheme.Header
        TitleLabel.TextColor3 = currentTheme.TextColor
        TitleLine.BackgroundColor3 = currentTheme.Accent
        ContentScrollingFrame.BackgroundColor3 = currentTheme.Background
        ContentScrollingFrame.ScrollBarImageColor3 = currentTheme.Accent
        TooltipFrame.BackgroundColor3 = currentTheme.TooltipBackground
        TooltipText.TextColor3 = currentTheme.TooltipTextColor

        -- Iterar sobre los objetos registrados para actualizar sus propiedades
        for element, properties in pairs(Objects) do
            if element.Parent then -- Verificar si el elemento aún existe
                for prop, value in pairs(properties) do
                    -- Si el valor es una referencia a Color3 del tema
                    if typeof(value) == "Color3" then
                        element[prop] = value
                    end
                end
            else
                -- Eliminar del registro Objects si el elemento ha sido destruido
                Objects[element] = nil
            end
        end
    end)


    -- Objeto que contendrá las secciones
    local PageObject = {}

    -- Crear una nueva sección
    function PageObject:NewSection(sectionName, startExpanded)
        sectionName = sectionName or "Nueva Sección"
        startExpanded = startExpanded ~= false -- Por defecto, expandida

        local SectionFrame = Instance.new("Frame")
        SectionFrame.Name = "Section_" .. sectionName:gsub(" ", "_")
        SectionFrame.Parent = ContentScrollingFrame
        SectionFrame.Size = UDim2.new(0.95, 0, 0, 30) -- Tamaño por defecto para el encabezado
        SectionFrame.BackgroundColor3 = currentTheme.ElementBackground
        SectionFrame.BorderSizePixel = 0
        SectionFrame.ClipsDescendants = true
        applyTheme(SectionFrame, "BackgroundColor3", currentTheme.ElementBackground)

        local SectionCorner = Instance.new("UICorner")
        SectionCorner.CornerRadius = UDim.new(0, 6)
        SectionCorner.Parent = SectionFrame

        local SectionHeader = Instance.new("TextButton")
        SectionHeader.Name = "Header"
        SectionHeader.Parent = SectionFrame
        SectionHeader.Size = UDim2.new(1, 0, 0, 30)
        SectionHeader.Position = UDim2.new(0, 0, 0, 0)
        SectionHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SectionHeader.BackgroundTransparency = 1
        SectionHeader.Text = sectionName
        SectionHeader.Font = Enum.Font.GothamSemibold
        SectionHeader.TextSize = 16
        SectionHeader.TextColor3 = currentTheme.TextColor
        SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
        SectionHeader.TextPadding = EdgeInsets.new(10, 0, 0, 0)
        applyTheme(SectionHeader, "TextColor3", currentTheme.TextColor)

        local ToggleArrow = Instance.new("ImageLabel")
        ToggleArrow.Name = "ToggleArrow"
        ToggleArrow.Parent = SectionHeader
        ToggleArrow.Size = UDim2.new(0, 20, 0, 20)
        ToggleArrow.Position = UDim2.new(1, -30, 0.5, -10)
        ToggleArrow.BackgroundTransparency = 1
        ToggleArrow.Image = "rbxassetid://3926305904" -- Un icono de flecha genérico
        ToggleArrow.ImageColor3 = currentTheme.Accent
        ToggleArrow.ImageRectOffset = Vector2.new(4, 988) -- Flecha hacia abajo (ajustar según el asset)
        ToggleArrow.ImageRectSize = Vector2.new(24, 24)
        ToggleArrow.Rotation = startExpanded and 0 or 270 -- Abajo para expandido, izquierda para colapsado
        applyTheme(ToggleArrow, "ImageColor3", currentTheme.Accent)

        local ElementsFrame = Instance.new("Frame")
        ElementsFrame.Name = "Elements"
        ElementsFrame.Parent = SectionFrame
        ElementsFrame.Size = UDim2.new(1, 0, 0, 0) -- La altura será gestionada por UIListLayout
        ElementsFrame.Position = UDim2.new(0, 0, 0, SectionHeader.Size.Y.Offset)
        ElementsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ElementsFrame.BackgroundTransparency = 1
        ElementsFrame.BorderSizePixel = 0
        ElementsFrame.ClipsDescendants = true

        local ElementsLayout = Instance.new("UIListLayout")
        ElementsLayout.Name = "ElementsLayout"
        ElementsLayout.Parent = ElementsFrame
        ElementsLayout.FillDirection = Enum.FillDirection.Vertical
        ElementsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ElementsLayout.Padding = UDim.new(0, 5)
        ElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local function updateSectionSize()
            local contentHeight = ElementsLayout.AbsoluteContentSize.Y
            if contentHeight < 0 then contentHeight = 0 end -- Evitar valores negativos
            Utility:TweenObject(ElementsFrame, {Size = UDim2.new(1, 0, 0, contentHeight)}, 0.15)
            Utility:TweenObject(SectionFrame, {Size = UDim2.new(0.95, 0, 0, SectionHeader.Size.Y.Offset + contentHeight)}, 0.15)
            updateCanvasSize() -- Actualizar el frame de desplazamiento principal
        end
        ElementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionSize)
        ElementsFrame.ChildAdded:Connect(function() task.wait() updateSectionSize() end)
        ElementsFrame.ChildRemoved:Connect(function() task.wait() updateSectionSize() end)

        local isExpanded = startExpanded
        local function toggleSection()
            isExpanded = not isExpanded
            if isExpanded then
                Utility:TweenObject(ElementsFrame, {Visible = true}, 0.1) -- Hacer visible antes de expandir
                Utility:TweenObject(ToggleArrow, {Rotation = 0}, 0.15)
                updateSectionSize()
            else
                Utility:TweenObject(ElementsFrame, {Size = UDim2.new(1,0,0,0)}, 0.15)
                Utility:TweenObject(SectionFrame, {Size = UDim2.new(0.95, 0, 0, SectionHeader.Size.Y.Offset)}, 0.15)
                Utility:TweenObject(ToggleArrow, {Rotation = 270}, 0.15)
                task.wait(0.15)
                Utility:TweenObject(ElementsFrame, {Visible = false}, 0.1)
                updateCanvasSize()
            end
        end
        SectionHeader.MouseButton1Click:Connect(toggleSection)
        if not startExpanded then
            ElementsFrame.Size = UDim2.new(1,0,0,0) -- Empezar colapsado
            ElementsFrame.Visible = false
            SectionFrame.Size = UDim2.new(0.95, 0, 0, SectionHeader.Size.Y.Offset)
        end
        task.wait() updateSectionSize() -- Establecer el tamaño inicial

        local Elements = {}
        Elements.Parent = ElementsFrame -- Para facilitar el acceso al padre

        -- Función genérica para crear un contenedor de elemento
        local function createElementContainer(elementName, tipText)
            local ElementContainer = Instance.new("Frame")
            ElementContainer.Name = elementName:gsub(" ", "_") .. "_Container"
            ElementContainer.Parent = ElementsFrame
            ElementContainer.Size = UDim2.new(1, -10, 0, 30) -- Ajustado para padding
            ElementContainer.BackgroundColor3 = currentTheme.ElementBackground
            ElementContainer.BorderSizePixel = 0
            applyTheme(ElementContainer, "BackgroundColor3", currentTheme.ElementBackground)

            local ElementCorner = Instance.new("UICorner")
            ElementCorner.CornerRadius = UDim.new(0, 5)
            ElementCorner.Parent = ElementContainer

            -- Efecto de Hover y Tooltip
            local hovering = false
            ElementContainer.MouseEnter:Connect(function()
                if not hovering then
                    hovering = true
                    Utility:TweenObject(ElementContainer, {BackgroundColor3 = currentTheme.ElementHover}, 0.1)
                    if tipText then showTooltip(tipText) end
                end
            end)
            ElementContainer.MouseLeave:Connect(function()
                if hovering then
                    hovering = false
                    Utility:TweenObject(ElementContainer, {BackgroundColor3 = currentTheme.ElementBackground}, 0.1)
                    if tipText then hideTooltip() end
                end
            end)

            return ElementContainer
        end

        -- Button
        function Elements:NewButton(buttonName, tip, callback)
            local ButtonContainer = createElementContainer(buttonName, tip)
            ButtonContainer.Size = UDim2.new(1, -10, 0, 30) -- Tamaño fijo

            local Button = Instance.new("TextButton")
            Button.Name = "Button_" .. buttonName:gsub(" ", "_")
            Button.Parent = ButtonContainer
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.Position = UDim2.new(0,0,0,0)
            Button.BackgroundColor3 = Color3.fromRGB(255,255,255)
            Button.BackgroundTransparency = 1
            Button.Text = buttonName
            Button.Font = Enum.Font.SourceSansSemibold
            Button.TextSize = 14
            Button.TextColor3 = currentTheme.TextColor
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.TextPadding = EdgeInsets.new(10,0,0,0)
            applyTheme(Button, "TextColor3", currentTheme.TextColor)

            Button.MouseButton1Click:Connect(function()
                if callback then pcall(callback) end
                -- Animación simple de click
                local clone = Instance.new("Frame")
                clone.Size = UDim2.new(0, 0, 0, 0)
                clone.Position = UDim2.new(0.5, 0, 0.5, 0)
                clone.AnchorPoint = Vector2.new(0.5, 0.5)
                clone.BackgroundColor3 = currentTheme.Accent
                clone.BackgroundTransparency = 0.8
                clone.Parent = Button
                local cCorner = Instance.new("UICorner")
                cCorner.CornerRadius = UDim.new(0.5,0)
                cCorner.Parent = clone
                Utility:TweenObject(clone, {Size = UDim2.new(0, Button.AbsoluteSize.X  1.5, 0, Button.AbsoluteSize.X  1.5), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                task.delay(0.3, function() clone:Destroy() end)
            end)

            return Button
        end

        -- Toggle
        function Elements:NewToggle(toggleName, tip, callback, defaultValue)
            local ToggleContainer = createElementContainer(toggleName, tip)
            ToggleContainer.Size = UDim2.new(1, -10, 0, 30)

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "ToggleLabel"
            ToggleLabel.Parent = ToggleContainer
            ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
            ToggleLabel.Position = UDim2.new(0,0,0,0)
            ToggleLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = toggleName
            ToggleLabel.Font = Enum.Font.SourceSansSemibold
            ToggleLabel.TextSize = 14
            ToggleLabel.TextColor3 = currentTheme.TextColor
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.TextPadding = EdgeInsets.new(10,0,0,0)
            applyTheme(ToggleLabel, "TextColor3", currentTheme.TextColor)

            local ToggleSwitch = Instance.new("ImageButton")
            ToggleSwitch.Name = "ToggleSwitch"
            ToggleSwitch.Parent = ToggleContainer
            ToggleSwitch.Size = UDim2.new(0, 40, 0, 20)
            ToggleSwitch.Position = UDim2.new(1, -50, 0.5, -10)
            ToggleSwitch.BackgroundColor3 = Color3.fromRGB(255,255,255)
            ToggleSwitch.BackgroundTransparency = 1
            ToggleSwitch.Image = "rbxassetid://3926309567" -- Imagen genérica de switch
            ToggleSwitch.ImageRectSize = Vector2.new(48, 48) -- Asumiendo un sprite cuadrado para diferentes estados

            local toggleState = defaultValue or Settings[currentLibName .. "_" .. toggleName] or false
            local toggleEnabledRect = Vector2.new(784, 420) -- Ejemplo para estado 'encendido'
            local toggleDisabledRect = Vector2.new(628, 420) -- Ejemplo para estado 'apagado'

            ToggleSwitch.ImageRectOffset = toggleState and toggleEnabledRect or toggleDisabledRect
            ToggleSwitch.ImageColor3 = toggleState and currentTheme.Accent or currentTheme.BorderColor
            applyTheme(ToggleSwitch, "ImageColor3", toggleState and currentTheme.Accent or currentTheme.BorderColor)

            local function updateToggleState(state)
                toggleState = state
                ToggleSwitch.ImageRectOffset = toggleState and toggleEnabledRect or toggleDisabledRect
                Utility:TweenObject(ToggleSwitch, {ImageColor3 = toggleState and currentTheme.Accent or currentTheme.BorderColor}, 0.1)
                Settings[currentLibName .. "_" .. toggleName] = toggleState
                saveSettings()
                if callback then pcall(callback, toggleState) end
            end

            ToggleSwitch.MouseButton1Click:Connect(function()
                updateToggleState(not toggleState)
            end)

            -- Disparar el callback inicial
            task.spawn(function()
                if callback then pcall(callback, toggleState) end
            end)

            local toggleFunctions = {
                GetState = function() return toggleState end,
                SetState = updateToggleState
            }
            return toggleFunctions
        end

        -- TextBox
        function Elements:NewTextBox(textBoxName, tip, callback, defaultValue, isMultiLine)
            local TextBoxContainer = createElementContainer(textBoxName, tip)
            TextBoxContainer.Size = UDim2.new(1, -10, 0, 50) -- Más alto para textbox

            local TextBoxLabel = Instance.new("TextLabel")
            TextBoxLabel.Name = "TextBoxLabel"
            TextBoxLabel.Parent = TextBoxContainer
            TextBoxLabel.Size = UDim2.new(0.9, 0, 0, 15)
            TextBoxLabel.Position = UDim2.new(0, 5, 0, 2)
            TextBoxLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
            TextBoxLabel.BackgroundTransparency = 1
            TextBoxLabel.Text = textBoxName
            TextBoxLabel.Font = Enum.Font.SourceSansSemibold
            TextBoxLabel.TextSize = 14
            TextBoxLabel.TextColor3 = currentTheme.TextColor
            TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
            applyTheme(TextBoxLabel, "TextColor3", currentTheme.TextColor)

            local TextBox = Instance.new("TextBox")
            TextBox.Name = "Input"
            TextBox.Parent = TextBoxContainer
            TextBox.Size = UDim2.new(1, -10, 0, 25)
            TextBox.Position = UDim2.new(0, 5, 0, 20)
            TextBox.BackgroundColor3 = currentTheme.InputBackground
            TextBox.BorderSizePixel = 0
            TextBox.PlaceholderText = "Escribe aquí..."
            TextBox.Text = defaultValue or Settings[currentLibName .. "_" .. textBoxName] or ""
            TextBox.Font = Enum.Font.SourceSans
            TextBox.TextSize = 14
            TextBox.TextColor3 = currentTheme.TextColor
            TextBox.TextXAlignment = Enum.TextXAlignment.Left
            TextBox.TextYAlignment = Enum.TextYAlignment.Center
            TextBox.ClearTextOnFocus = false
            TextBox.MultiLine = isMultiLine or false
            applyTheme(TextBox, "BackgroundColor3", currentTheme.InputBackground)
            applyTheme(TextBox, "TextColor3", currentTheme.TextColor)

            local TextBoxCorner = Instance.new("UICorner")
            TextBoxCorner.CornerRadius = UDim.new(0, 4)
            TextBoxCorner.Parent = TextBox

            TextBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    Settings[currentLibName .. "_" .. textBoxName] = TextBox.Text
                    saveSettings()
                    if callback then pcall(callback, TextBox.Text) end
                end
            end)
            TextBox.TextEdited:Connect(function()
                Settings[currentLibName .. "_" .. textBoxName] = TextBox.Text
                saveSettings()
                if callback then pcall(callback, TextBox.Text) end
            end)

            local textBoxFunctions = {
                GetText = function() return TextBox.Text end,
                SetText = function(text)
                    TextBox.Text = tostring(text)
                    Settings[currentLibName .. "_" .. textBoxName] = TextBox.Text
                    saveSettings()
                end
            }
            return textBoxFunctions
        end

        -- Label
        function Elements:NewLabel(labelText)
            local LabelContainer = createElementContainer(labelText, nil)
            LabelContainer.Size = UDim2.new(1, -10, 0, 25)
            LabelContainer.BackgroundColor3 = currentTheme.Header -- Las etiquetas pueden tener un fondo ligeramente diferente
            applyTheme(LabelContainer, "BackgroundColor3", currentTheme.Header) -- Asegurarse que el contenedor herede

            local Label = Instance.new("TextLabel")
            Label.Name = "Label_" .. labelText:gsub(" ", "_")
            Label.Parent = LabelContainer
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.Position = UDim2.new(0,0,0,0)
            Label.BackgroundColor3 = Color3.fromRGB(255,255,255)
            Label.BackgroundTransparency = 1
            Label.Text = labelText
            Label.Font = Enum.Font.SourceSansSemibold
            Label.TextSize = 14
            Label.TextColor3 = currentTheme.TextColor
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextPadding = EdgeInsets.new(10,0,0,0)
            applyTheme(Label, "TextColor3", currentTheme.TextColor)

            local labelFunctions = {
                UpdateText = function(newText) Label.Text = newText end,
                GetText = function() return Label.Text end
            }
            return labelFunctions
        end

        -- Slider
        function Elements:NewSlider(sliderName, tip, min, max, defaultValue, callback)
            local SliderContainer = createElementContainer(sliderName, tip)
            SliderContainer.Size = UDim2.new(1, -10, 0, 45) -- Más alto para el slider

            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "SliderLabel"
            SliderLabel.Parent = SliderContainer
            SliderLabel.Size = UDim2.new(0.6, 0, 0, 15)
            SliderLabel.Position = UDim2.new(0, 5, 0, 2)
            SliderLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = sliderName
            SliderLabel.Font = Enum.Font.SourceSansSemibold
            SliderLabel.TextSize = 14
            SliderLabel.TextColor3 = currentTheme.TextColor
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            applyTheme(SliderLabel, "TextColor3", currentTheme.TextColor)

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Name = "ValueLabel"
            ValueLabel.Parent = SliderContainer
            ValueLabel.Size = UDim2.new(0.3, 0, 0, 15)
            ValueLabel.Position = UDim2.new(0.65, 0, 0, 2)
            ValueLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(defaultValue or min)
            ValueLabel.Font = Enum.Font.SourceSansSemibold
            ValueLabel.TextSize = 14
            ValueLabel.TextColor3 = currentTheme.TextColor
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            applyTheme(ValueLabel, "TextColor3", currentTheme.TextColor)

            local SliderTrack = Instance.new("Frame")
            SliderTrack.Name = "SliderTrack"
            SliderTrack.Parent = SliderContainer
            SliderTrack.Size = UDim2.new(1, -10, 0, 6)
            SliderTrack.Position = UDim2.new(0, 5, 0, 25)
            SliderTrack.BackgroundColor3 = currentTheme.InputBackground
            SliderTrack.BorderSizePixel = 0
            applyTheme(SliderTrack, "BackgroundColor3", currentTheme.InputBackground)

            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(0, 3)
            TrackCorner.Parent = SliderTrack

            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "SliderFill"
            SliderFill.Parent = SliderTrack
            SliderFill.Size = UDim2.new(0, 0, 1, 0)
            SliderFill.BackgroundColor3 = currentTheme.Accent
            SliderFill.BorderSizePixel = 0
            applyTheme(SliderFill, "BackgroundColor3", currentTheme.Accent)

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(0, 3)
            FillCorner.Parent = SliderFill

            local currentValue = defaultValue or Settings[currentLibName .. "_" .. sliderName] or min
            local mouse = Players.LocalPlayer:GetMouse()
            local isDragging = false

            local function updateSlider(mouseX)
                local relativeX = mouseX - SliderTrack.AbsolutePosition.X
                local percent = math.clamp(relativeX / SliderTrack.AbsoluteSize.X, 0, 1)
                local value = min + (percent * (max - min))
                currentValue = math.floor(value + 0.5) -- Redondear al entero más cercano

                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                ValueLabel.Text = tostring(currentValue)
                Settings[currentLibName .. "_" .. sliderName] = currentValue
                saveSettings()
                if callback then pcall(callback, currentValue) end
            end

            SliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    updateSlider(input.Position.X)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
                    updateSlider(input.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)

            -- Configuración de estado inicial
            local initialPercent = (currentValue - min) / (max - min)
            SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
            ValueLabel.Text = tostring(currentValue)
            task.spawn(function()
                if callback then pcall(callback, currentValue) end
            end)

            local sliderFunctions = {
                GetValue = function() return currentValue end,
                SetValue = function(value)
                    currentValue = math.clamp(math.floor(value + 0.5), min, max)
                    local percent = (currentValue - min) / (max - min)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    ValueLabel.Text = tostring(currentValue)
                    Settings[currentLibName .. "_" .. sliderName] = currentValue
                    saveSettings()
                end
            }
            return sliderFunctions
        end

        -- Dropdown
        function Elements:NewDropdown(dropdownName, tip, options, defaultValue, callback)
            local DropdownContainer = createElementContainer(dropdownName, tip)
            DropdownContainer.Size = UDim2.new(1, -10, 0, 30) -- Tamaño inicial para dropdown cerrado
            DropdownContainer.ClipsDescendants = false -- Permitir que las opciones sean visibles fuera

            local DropdownHeader = Instance.new("TextButton")
            DropdownHeader.Name = "DropdownHeader"
            DropdownHeader.Parent = DropdownContainer
            DropdownHeader.Size = UDim2.new(1, 0, 1, 0)
            DropdownHeader.BackgroundColor3 = Color3.fromRGB(255,255,255)
            DropdownHeader.BackgroundTransparency = 1
            DropdownHeader.Text = dropdownName .. ": " .. (defaultValue or options[1] or "Seleccionar...")
            DropdownHeader.Font = Enum.Font.SourceSansSemibold
            DropdownHeader.TextSize = 14
            DropdownHeader.TextColor3 = currentTheme.TextColor
            DropdownHeader.TextXAlignment = Enum.TextXAlignment.Left
            DropdownHeader.TextPadding = EdgeInsets.new(10,0,0,0)
            applyTheme(DropdownHeader, "TextColor3", currentTheme.TextColor)

            local ArrowIcon = Instance.new("ImageLabel")
            ArrowIcon.Name = "ArrowIcon"
            ArrowIcon.Parent = DropdownHeader
            ArrowIcon.Size = UDim2.new(0, 20, 0, 20)
            ArrowIcon.Position = UDim2.new(1, -30, 0.5, -10)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = "rbxassetid://3926305904" -- Icono de flecha genérico
            ArrowIcon.ImageColor3 = currentTheme.Accent
            ArrowIcon.ImageRectOffset = Vector2.new(4, 988) -- Flecha hacia abajo
            ArrowIcon.ImageRectSize = Vector2.new(24, 24)
            applyTheme(ArrowIcon, "ImageColor3", currentTheme.Accent)

            local OptionsFrame = Instance.new("Frame")
            OptionsFrame.Name = "OptionsFrame"
            OptionsFrame.Parent = DropdownContainer
            OptionsFrame.Size = UDim2.new(1, 0, 0, 0) -- Comienza colapsado
            OptionsFrame.Position = UDim2.new(0, 0, 1, 5) -- Debajo del encabezado con un pequeño espacio
            OptionsFrame.BackgroundColor3 = currentTheme.ElementBackground
            OptionsFrame.BorderSizePixel = 0
            OptionsFrame.ClipsDescendants = true
            OptionsFrame.Visible = false
            applyTheme(OptionsFrame, "BackgroundColor3", currentTheme.ElementBackground)

            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.Name = "OptionsLayout"
            OptionsLayout.Parent = OptionsFrame
            OptionsLayout.FillDirection = Enum.FillDirection.Vertical
            OptionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            OptionsLayout.Padding = UDim.new(0, 3)
            OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local isOpen = false
            local currentSelection = defaultValue or Settings[currentLibName .. "_" .. dropdownName] or options[1]

            local function updateSelection(selection)
                currentSelection = selection
                DropdownHeader.Text = dropdownName .. ": " .. selection
                Settings[currentLibName .. "_" .. dropdownName] = currentSelection
                saveSettings()
                if callback then pcall(callback, currentSelection) end
            end

            local function populateOptions(opts)
                for _,child in ipairs(OptionsFrame:GetChildren()) do
                    if child:IsA("TextButton") and child.Name:find("Option_") then
                        child:Destroy()
                    end
                end
                for _, optionText in ipairs(opts) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Name = "Option_" .. optionText:gsub(" ", "_")
                    OptionButton.Parent = OptionsFrame
                    OptionButton.Size = UDim2.new(1, -6, 0, 25)
                    OptionButton.BackgroundColor3 = currentTheme.ElementBackground
                    OptionButton.Text = optionText
                    OptionButton.Font = Enum.Font.SourceSans
                    OptionButton.TextSize = 14
                    OptionButton.TextColor3 = currentTheme.TextColor
                    OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                    OptionButton.TextPadding = EdgeInsets.new(5,0,0,0)
                    OptionButton.AutoButtonColor = false
                    applyTheme(OptionButton, "BackgroundColor3", currentTheme.ElementBackground)
                    applyTheme(OptionButton, "TextColor3", currentTheme.TextColor)

                    local OptionCorner = Instance.new("UICorner")
                    OptionCorner.CornerRadius = UDim.new(0, 4)
                    OptionCorner.Parent = OptionButton

                    local optionHovering = false
                    OptionButton.MouseEnter:Connect(function()
                        if not optionHovering then
                            optionHovering = true
                            Utility:TweenObject(OptionButton, {BackgroundColor3 = currentTheme.ElementHover}, 0.1)
                        end
                    end)
                    OptionButton.MouseLeave:Connect(function()
                        if optionHovering then
                            optionHovering = false
                            Utility:TweenObject(OptionButton, {BackgroundColor3 = currentTheme.ElementBackground}, 0.1)
                        end
                    end)

                    OptionButton.MouseButton1Click:Connect(function()
                        updateSelection(optionText)
                        DropdownHeader.MouseButton1Click:Fire() -- Cerrar dropdown después de la selección
                    end)
                end
            end
            populateOptions(options) -- Poblar opciones iniciales

            OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if isOpen then
                    Utility:TweenObject(OptionsFrame, {Size = UDim2.new(1, 0, 0, OptionsLayout.AbsoluteContentSize.Y)}, 0.15)
                end
            end)

            DropdownHeader.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    OptionsFrame.Visible = true
                    Utility:TweenObject(ArrowIcon, {Rotation = 180}, 0.15) -- Flecha hacia arriba
                    Utility:TweenObject(OptionsFrame, {Size = UDim2.new(1, 0, 0, OptionsLayout.AbsoluteContentSize.Y)}, 0.15)
                    Utility:TweenObject(DropdownContainer, {Size = UDim2.new(1, -10, 0, 30 + OptionsLayout.AbsoluteContentSize.Y + 5)}, 0.15) -- Encabezado + Opciones + Espacio
                    task.wait(0.15) updateSectionSize() -- Recalcular tamaño de la sección
                else
                    Utility:TweenObject(ArrowIcon, {Rotation = 0}, 0.15) -- Flecha hacia abajo
                    Utility:TweenObject(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                    Utility:TweenObject(DropdownContainer, {Size = UDim2.new(1, -10, 0, 30)}, 0.15)
                    task.wait(0.15)
                    OptionsFrame.Visible = false
                    updateSectionSize()
                end
            end)

            updateSelection(currentSelection) -- Establecer texto inicial y disparar callback

            local dropdownFunctions = {
                GetSelection = function() return currentSelection end,
                SetSelection = function(selection)
                    if table.find(options, selection) then
                        updateSelection(selection)
                    else
                        warn("Mikoto Delight: Selección inválida para dropdown:", selection)
                    end
                end,
                RefreshOptions = function(newOptions)
                    options = newOptions
                    populateOptions(newOptions)
                    -- Re-seleccionar la opción actual si aún existe
                    if not table.find(newOptions, currentSelection) then
                        updateSelection(newOptions[1] or "Seleccionar...")
                    end
                    -- Forzar actualización del layout
                    OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
                    DropdownHeader.MouseButton1Click:Fire() -- Cerrar y reabrir para reajustar tamaño
                    DropdownHeader.MouseButton1Click:Fire()
                end
            }
            return dropdownFunctions
        end

        -- Keybind
        function Elements:NewKeybind(keybindName, tip, defaultKey, callback)
            local KeybindContainer = createElementContainer(keybindName, tip)
            KeybindContainer.Size = UDim2.new(1, -10, 0, 30)

            local KeybindLabel = Instance.new("TextLabel")
            KeybindLabel.Name = "KeybindLabel"
            KeybindLabel.Parent = KeybindContainer
            KeybindLabel.Size = UDim2.new(0.6, 0, 1, 0)
            KeybindLabel.Position = UDim2.new(0,0,0,0)
            KeybindLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
            KeybindLabel.BackgroundTransparency = 1
            KeybindLabel.Text = keybindName
            KeybindLabel.Font = Enum.Font.SourceSansSemibold
            KeybindLabel.TextSize = 14
            KeybindLabel.TextColor3 = currentTheme.TextColor
            KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeybindLabel.TextPadding = EdgeInsets.new(10,0,0,0)
            applyTheme(KeybindLabel, "TextColor3", currentTheme.TextColor)

            local KeyDisplayButton = Instance.new("TextButton")
            KeyDisplayButton.Name = "KeyDisplay"
            KeyDisplayButton.Parent = KeybindContainer
            KeyDisplayButton.Size = UDim2.new(0, 70, 0, 20)
            KeyDisplayButton.Position = UDim2.new(1, -80, 0.5, -10)
            KeyDisplayButton.BackgroundColor3 = currentTheme.InputBackground
            KeyDisplayButton.BorderSizePixel = 0
            KeyDisplayButton.Font = Enum.Font.SourceSansSemibold
            KeyDisplayButton.TextSize = 14
            KeyDisplayButton.TextColor3 = currentTheme.Accent
            KeyDisplayButton.Text = defaultKey or Settings[currentLibName .. "_" .. keybindName] or "None"
            applyTheme(KeyDisplayButton, "BackgroundColor3", currentTheme.InputBackground)
            applyTheme(KeyDisplayButton, "TextColor3", currentTheme.Accent)

            local KeyDisplayCorner = Instance.new("UICorner")
            KeyDisplayCorner.CornerRadius = UDim.new(0, 4)
            KeyDisplayCorner.Parent = KeyDisplayButton

            local currentKey = Enum.KeyCode[defaultKey] or Enum.KeyCode[Settings[currentLibName .. "_" .. keybindName]] or Enum.KeyCode.Unknown
            local isListening = false

            KeyDisplayButton.MouseButton1Click:Connect(function()
                if not isListening then
                    isListening = true
                    KeyDisplayButton.Text = "..."
                    local inputBeganConnection
                    inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
                        if not gameProcessedEvent and input.KeyCode.Name ~= "Unknown" then
                            local newKeyName = input.KeyCode.Name
                            currentKey = input.KeyCode
                            KeyDisplayButton.Text = newKeyName
                            Settings[currentLibName .. "_" .. keybindName] = newKeyName
                            saveSettings()
                            isListening = false
                            inputBeganConnection:Disconnect()
                        end
                    end)
                end
            end)

            local keybindConnection
            keybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
                if not gameProcessedEvent and input.KeyCode == currentKey then
                    if callback then pcall(callback) end
                end
            end)

            local keybindFunctions = {
                GetKey = function() return currentKey end,
                SetKey = function(keyName)
                    local newKey = Enum.KeyCode[keyName]
                    if newKey then
                        currentKey = newKey
                        KeyDisplayButton.Text = keyName
                        Settings[currentLibName .. "_" .. keybindName] = keyName
                        saveSettings()
                    else
                        warn("Mikoto Delight: KeyCode inválido para keybind:", keyName)
                    end
                end,
                -- Desconectar el listener del keybind si el elemento UI es destruido
                __gc = function()
                    if keybindConnection then keybindConnection:Disconnect() end
                end
            }
            return keybindFunctions
        end

        -- ColorPicker
        function Elements:NewColorPicker(pickerName, tip, defaultColor, callback)
            local ColorPickerContainer = createElementContainer(pickerName, tip)
            ColorPickerContainer.Size = UDim2.new(1, -10, 0, 30) -- Tamaño inicial para el encabezado
            ColorPickerContainer.ClipsDescendants = false -- Para el efecto de despliegue

            local ColorPickerHeader = Instance.new("TextButton")
            ColorPickerHeader.Name = "ColorPickerHeader"
            ColorPickerHeader.Parent = ColorPickerContainer
            ColorPickerHeader.Size = UDim2.new(1, 0, 0, 30)
            ColorPickerHeader.BackgroundColor3 = Color3.fromRGB(255,255,255)
            ColorPickerHeader.BackgroundTransparency = 1
            ColorPickerHeader.Text = pickerName
            ColorPickerHeader.Font = Enum.Font.SourceSansSemibold
            ColorPickerHeader.TextSize = 14
            ColorPickerHeader.TextColor3 = currentTheme.TextColor
            ColorPickerHeader.TextXAlignment = Enum.TextXAlignment.Left
            ColorPickerHeader.TextPadding = EdgeInsets.new(10,0,0,0)
            applyTheme(ColorPickerHeader, "TextColor3", currentTheme.TextColor)

            local CurrentColorDisplay = Instance.new("Frame")
            CurrentColorDisplay.Name = "CurrentColor"
            CurrentColorDisplay.Parent = ColorPickerHeader
            CurrentColorDisplay.Size = UDim2.new(0, 20, 0, 20)
            CurrentColorDisplay.Position = UDim2.new(1, -30, 0.5, -10)
            CurrentColorDisplay.BackgroundColor3 = defaultColor or Settings[currentLibName .. "_" .. pickerName] or Color3.fromRGB(255,255,255)
            CurrentColorDisplay.BorderSizePixel = 1
            CurrentColorDisplay.BorderColor3 = currentTheme.BorderColor
            applyTheme(CurrentColorDisplay, "BorderColor3", currentTheme.BorderColor)

            local ColorDisplayCorner = Instance.new("UICorner")
            ColorDisplayCorner.CornerRadius = UDim.new(0, 4)
            ColorDisplayCorner.Parent = CurrentColorDisplay

            local ColorPaletteFrame = Instance.new("Frame")
            ColorPaletteFrame.Name = "ColorPalette"
            ColorPaletteFrame.Parent = ColorPickerContainer
            ColorPaletteFrame.Size = UDim2.new(1, -10, 0, 110) -- Tamaño principal de la paleta
            ColorPaletteFrame.Position = UDim2.new(0, 5, 0, 35) -- Debajo del encabezado
            ColorPaletteFrame.BackgroundColor3 = currentTheme.InputBackground
            ColorPaletteFrame.BorderSizePixel = 0
            ColorPaletteFrame.Visible = false -- Comienza colapsado
            applyTheme(ColorPaletteFrame, "BackgroundColor3", currentTheme.InputBackground)

            local PaletteCorner = Instance.new("UICorner")
            PaletteCorner.CornerRadius = UDim.new(0, 6)
            PaletteCorner.Parent = ColorPaletteFrame

            -- Selector de Tono/Saturación
            local HueSatPicker = Instance.new("ImageButton")
            HueSatPicker.Name = "HueSatPicker"
            HueSatPicker.Parent = ColorPaletteFrame
            HueSatPicker.Size = UDim2.new(0, 180, 0, 90) -- Tamaño de ejemplo
            HueSatPicker.Position = UDim2.new(0, 5, 0.5, -45)
            HueSatPicker.Image = "rbxassetid://6523286724" -- Imagen genérica de gradiente H/S
            HueSatPicker.BackgroundTransparency = 1

            local HueSatCursor = Instance.new("ImageLabel")
            HueSatCursor.Name = "HueSatCursor"
            HueSatCursor.Parent = HueSatPicker
            HueSatCursor.Size = UDim2.new(0, 14, 0, 14)
            HueSatCursor.BackgroundTransparency = 1
            HueSatCursor.Image = "rbxassetid://3926309567" -- Icono de círculo
            HueSatCursor.ImageRectOffset = Vector2.new(628, 420) -- Ejemplo de círculo cuadrado
            HueSatCursor.ImageRectSize = Vector2.new(48, 48)
            HueSatCursor.AnchorPoint = Vector2.new(0.5, 0.5)
            HueSatCursor.ImageColor3 = Color3.fromRGB(255, 255, 255) -- Cursor siempre blanco

            -- Selector de Valor/Luminosidad
            local ValuePicker = Instance.new("ImageButton")
            ValuePicker.Name = "ValuePicker"
            ValuePicker.Parent = ColorPaletteFrame
            ValuePicker.Size = UDim2.new(0, 18, 0, 90) -- Franja estrecha
            ValuePicker.Position = UDim2.new(0, 190, 0.5, -45)
            ValuePicker.Image = "rbxassetid://6523291212" -- Imagen genérica de gradiente de valor
            ValuePicker.BackgroundTransparency = 1

            local ValueCursor = Instance.new("ImageLabel")
            ValueCursor.Name = "ValueCursor"
            ValueCursor.Parent = ValuePicker
            ValueCursor.Size = UDim2.new(0, 14, 0, 14)
            ValueCursor.BackgroundTransparency = 1
            ValueCursor.Image = "rbxassetid://3926309567" -- Icono de círculo
            ValueCursor.ImageRectOffset = Vector2.new(628, 420)
            ValueCursor.ImageRectSize = Vector2.new(48, 48)
            ValueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
            ValueCursor.Position = UDim2.new(0.5, 0, 0.5, 0)
            ValueCursor.ImageColor3 = Color3.fromRGB(255, 255, 255) -- Cursor siempre blanco

            local h, s, v = Color3.toHSV(CurrentColorDisplay.BackgroundColor3)
            HueSatCursor.Position = UDim2.new(h, 0, s, 0)
            ValueCursor.Position = UDim2.new(0.5, 0, 1-v, 0) -- V es inverso para la posición

            local mouse = Players.LocalPlayer:GetMouse()
            local isHueSatDragging = false
            local isValueDragging = false

            local function updateColor()
                local newColor = Color3.fromHSV(h, s, v)
                CurrentColorDisplay.BackgroundColor3 = newColor
                Settings[currentLibName .. "_" .. pickerName] = newColor
                saveSettings()
                if callback then pcall(callback, newColor) end
            end

            HueSatPicker.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isHueSatDragging = true
                    -- input.Use() -- Prevenir la interacción con la UI de Studio si es necesario
                end
            end)
            ValuePicker.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isValueDragging = true
                    -- input.Use()
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if isHueSatDragging then
                        local x = math.clamp((mouse.X - HueSatPicker.AbsolutePosition.X) / HueSatPicker.AbsoluteSize.X, 0, 1)
                        local y = math.clamp((mouse.Y - HueSatPicker.AbsolutePosition.Y) / HueSatPicker.AbsoluteSize.Y, 0, 1)
                        h = x
                        s = y
                        HueSatCursor.Position = UDim2.new(h, 0, s, 0)
                        updateColor()
                    elseif isValueDragging then
                        local y = math.clamp((mouse.Y - ValuePicker.AbsolutePosition.Y) / ValuePicker.AbsoluteSize.Y, 0, 1)
                        v = 1 - y -- Invertir para que coincida visualmente
                        ValueCursor.Position = UDim2.new(0.5, 0, y, 0)
                        updateColor()
                    end
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isHueSatDragging = false
                    isValueDragging = false
                end
            end)

            local isPaletteOpen = false
            ColorPickerHeader.MouseButton1Click:Connect(function()
                isPaletteOpen = not isPaletteOpen
                if isPaletteOpen then
                    ColorPaletteFrame.Visible = true
                    Utility:TweenObject(ColorPickerContainer, {Size = UDim2.new(1, -10, 0, 30 + ColorPaletteFrame.Size.Y.Offset + 10)}, 0.15) -- Encabezado + Paleta + Espacio
                    task.wait(0.15) updateSectionSize()
                else
                    Utility:TweenObject(ColorPickerContainer, {Size = UDim2.new(1, -10, 0, 30)}, 0.15)
                    task.wait(0.15)
                    ColorPaletteFrame.Visible = false
                    updateSectionSize()
                end
            end)

            local colorPickerFunctions = {
                GetColor = function() return CurrentColorDisplay.BackgroundColor3 end,
                SetColor = function(newColor)
                    CurrentColorDisplay.BackgroundColor3 = newColor
                    h, s, v = Color3.toHSV(newColor)
                    HueSatCursor.Position = UDim2.new(h, 0, s, 0)
                    ValueCursor.Position = UDim2.new(0.5, 0, 1-v, 0)
                    Settings[currentLibName .. "_" .. pickerName] = newColor
                    saveSettings()
                    if callback then pcall(callback, newColor) end
                end,
            }
            return colorPickerFunctions
        end

        return Elements -- Devolver el objeto Elements para añadir controles a la sección
    end
    
    -- Función para destruir la interfaz gráfica
    PageObject.Destroy = function()
        if ScreenGui then
            ScreenGui:Destroy()
            if themeUpdateConnection then
                themeUpdateConnection:Disconnect()
            end
        end
    end

    return PageObject -- Devolver el objeto PageObject para añadir secciones
end

return Mikoto
