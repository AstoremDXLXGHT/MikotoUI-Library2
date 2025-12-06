--[[
  DelightfulUI - By Mikoto Delight
  La librería de UI más cool y flexible para tus exploits en Roblox.
  ¡Úsala bajo tu propio riesgo y con la sabiduría que te caracteriza!
]]

local DelightfulUI = {}
local Services = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService")
}

local LocalPlayer = Services.Players.LocalPlayer
local PlayerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui") or nil

-- Si no hay PlayerGui, no podemos hacer mucho.
if not PlayerGui then
    warn("DelightfulUI: No se pudo encontrar PlayerGui. Asegúrate de que estés en un juego y sea un cliente.")
    return nil -- No podemos inicializar si no hay dónde poner la UI.
end

-- Helper para UDim2
local function createUDim2(xScale, xOffset, yScale, yOffset)
    return UDim2.new(xScale, xOffset, yScale, yOffset)
end

-- Helper para Color3
local function createColor3(r, g, b)
    return Color3.new(r, g, b)
end

-- Helper para Instance
local function createInstance(className, parent, name)
    local instance = Instance.new(className)
    instance.Name = name or className
    instance.Parent = parent
    return instance
end

-- Función base para añadir métodos comunes a todos los elementos UI
local function addCommonMethods(instance)
    instance.SetPosition = function(self, xScale, xOffset, yScale, yOffset)
        self.Position = createUDim2(xScale, xOffset, yScale, yOffset)
        return self
    end

    instance.SetSize = function(self, xScale, xOffset, yScale, yOffset)
        self.Size = createUDim2(xScale, xOffset, yScale, yOffset)
        return self
    end

    instance.SetBackgroundColor = function(self, r, g, b)
        self.BackgroundColor3 = createColor3(r, g, b)
        return self
    end

    instance.SetBorderColor = function(self, r, g, b)
        self.BorderColor3 = createColor3(r, g, b)
        return self
    end

    instance.SetTransparency = function(self, transparency)
        self.BackgroundTransparency = transparency
        return self
    end

    instance.SetBorderTransparency = function(self, transparency)
        self.BorderTransparency = transparency
        return self
    end
    
    instance.SetBorderSizePx = function(self, size)
        self.BorderSizePixel = size
        return self
    end

    instance.SetVisible = function(self, isVisible)
        self.Visible = isVisible
        return self
    end

    instance.Remove = function(self)
        self.Parent = nil
        self:Destroy()
    end
    
    return instance
end

-- Función para añadir métodos de texto
local function addTextMethods(instance)
    instance.SetText = function(self, text)
        self.Text = tostring(text)
        return self
    end

    instance.SetTextColor = function(self, r, g, b)
        self.TextColor3 = createColor3(r, g, b)
        return self
    end

    instance.SetTextSize = function(self, size)
        self.TextSize = size
        return self
    end

    instance.SetFont = function(self, font)
        self.Font = font
        return self
    end
    
    instance.SetTextTransparency = function(self, transparency)
        self.TextTransparency = transparency
        return self
    end

    instance.SetTextWrapped = function(self, wrap)
        self.TextWrapped = wrap
        return self
    end

    instance.SetTextXAlignment = function(self, alignment) -- Enum.TextXAlignment
        self.TextXAlignment = alignment
        return self
    end

    instance.SetTextYAlignment = function(self, alignment) -- Enum.TextYAlignment
        self.TextYAlignment = alignment
        return self
    end

    return instance
end

--- MÉTODOS DE CREACIÓN DE UI ---

-- DelightfulUI.newScreenGui(name)
function DelightfulUI.newScreenGui(name)
    local screenGui = createInstance("ScreenGui", PlayerGui, name or "DelightfulScreen")
    screenGui.IgnoreGuiInset = true -- Para que no tenga el espacio de la barra superior de Roblox
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    return addCommonMethods(screenGui)
end

-- DelightfulUI.newFrame(parent, name)
function DelightfulUI.newFrame(parent, name)
    local frame = createInstance("Frame", parent, name or "DelightfulFrame")
    frame.BackgroundColor3 = createColor3(0.15, 0.15, 0.15)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 1
    frame.BorderColor3 = createColor3(0.1, 0.1, 0.1)
    frame.Size = createUDim2(0.2, 0, 0.2, 0) -- Tamaño por defecto

    local finalFrame = addCommonMethods(frame)

    -- Método para hacer el Frame arrastrable
    local isDragging = false
    local dragStartPosition = Vector2.new(0, 0)
    local frameInitialPosition = UDim2.new(0,0,0,0)
    local connections = {}

    function finalFrame:MakeDraggable()
        if self:IsA("ScreenGui") then warn("DelightfulUI: MakeDraggable no funciona en ScreenGuis."); return self end

        local function onInputBegan(input, gameProcessedEvent)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent and self.Visible then
                local mousePosition = Services.UserInputService:GetMouseLocation()
                if (mousePosition.X >= self.AbsolutePosition.X and mousePosition.X <= self.AbsolutePosition.X + self.AbsoluteSize.X) and
                   (mousePosition.Y >= self.AbsolutePosition.Y and mousePosition.Y <= self.AbsolutePosition.Y + self.AbsoluteSize.Y) then
                    isDragging = true
                    dragStartPosition = mousePosition
                    frameInitialPosition = self.Position
                    self.Active = true -- Importante para recibir input
                end
            end
        end

        local function onInputChanged(input, gameProcessedEvent)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging and not gameProcessedEvent then
                local mousePosition = Services.UserInputService:GetMouseLocation()
                local delta = mousePosition - dragStartPosition
                
                local newX = frameInitialPosition.X.Offset + delta.X
                local newY = frameInitialPosition.Y.Offset + delta.Y
                
                self.Position = UDim2.new(0, newX, 0, newY)
            end
        end

        local function onInputEnded(input, gameProcessedEvent)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
                self.Active = false
            end
        end

        connections.inputBegan = Services.UserInputService.InputBegan:Connect(onInputBegan)
        connections.inputChanged = Services.UserInputService.InputChanged:Connect(onInputChanged)
        connections.inputEnded = Services.UserInputService.InputEnded:Connect(onInputEnded)
        
        -- Limpieza si el frame es destruido
        self.AncestryChanged:Connect(function()
            if not self.Parent then -- Si se ha desparentado o destruido
                for _, conn in pairs(connections) do
                    conn:Disconnect()
                end
                connections = {}
            end
        end)

        return self
    end

    return finalFrame
end

-- DelightfulUI.newTextLabel(parent, name)
function DelightfulUI.newTextLabel(parent, name)
    local label = createInstance("TextLabel", parent, name or "DelightfulLabel")
    label.Text = "Label"
    label.TextColor3 = createColor3(1, 1, 1)
    label.TextSize = 18
    label.Font = Enum.Font.SourceSans
    label.BackgroundTransparency = 1 -- Transparente por defecto
    label.Size = createUDim2(1, 0, 0.2, 0) -- Ancho completo, 20% de alto de su padre

    return addTextMethods(addCommonMethods(label))
end

-- DelightfulUI.newTextButton(parent, name)
function DelightfulUI.newTextButton(parent, name)
    local button = createInstance("TextButton", parent, name or "DelightfulButton")
    button.Text = "Button"
    button.TextColor3 = createColor3(1, 1, 1)
    button.TextSize = 18
    button.Font = Enum.Font.SourceSans
    button.BackgroundColor3 = createColor3(0.2, 0.4, 0.8) -- Azul por defecto
    button.BackgroundTransparency = 0
    button.BorderSizePixel = 1
    button.BorderColor3 = createColor3(0.1, 0.3, 0.7)
    button.Size = createUDim2(1, 0, 0.2, 0)

    local finalButton = addTextMethods(addCommonMethods(button))

    -- Evento OnClick
    function finalButton:OnClick(callback)
        self.MouseButton1Click:Connect(callback)
        return self
    end
    
    return finalButton
end

-- DelightfulUI.newTextBox(parent, name)
function DelightfulUI.newTextBox(parent, name)
    local textBox = createInstance("TextBox", parent, name or "DelightfulTextBox")
    textBox.Text = "Enter text..."
    textBox.PlaceholderText = "Type here..."
    textBox.TextColor3 = createColor3(1, 1, 1)
    textBox.TextSize = 16
    textBox.Font = Enum.Font.SourceSans
    textBox.BackgroundColor3 = createColor3(0.2, 0.2, 0.2)
    textBox.BackgroundTransparency = 0
    textBox.BorderSizePixel = 1
    textBox.BorderColor3 = createColor3(0.1, 0.1, 0.1)
    textBox.Size = createUDim2(1, 0, 0.2, 0)

    local finalTextBox = addTextMethods(addCommonMethods(textBox))
    
    -- Eventos específicos de TextBox
    function finalTextBox:OnFocusLost(callback)
        self.FocusLost:Connect(callback)
        return self
    end

    function finalTextBox:OnTextChanged(callback)
        self.Changed:Connect(function(property)
            if property == "Text" then
                callback(self.Text)
            end
        end)
        return self
    end

    return finalTextBox
end

-- Y aquí, Asto, es donde te entrego mi creación.
-- La librería encapsulada, lista para ser usada tras un loadstring.
return DelightfulUI
