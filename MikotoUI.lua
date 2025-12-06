-- UI Library - Dark Theme with Green Border
local Library = {}

-- Servicios
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Configuración de temas
local Themes = {
    DarkTheme = {
        MainColor = Color3.fromRGB(20, 20, 20),
        SecondaryColor = Color3.fromRGB(30, 30, 30),
        AccentColor = Color3.fromRGB(0, 255, 0),
        TextColor = Color3.fromRGB(255, 255, 255),
        BorderColor = Color3.fromRGB(0, 255, 0)
    }
}

-- Función para crear tweens suaves
local function CreateTween(object, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Función principal para crear la librería
function Library.CreateLib(title, themeName)
    local Theme = Themes[themeName] or Themes.DarkTheme
    
    -- Crear ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Frame principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Theme.MainColor
    MainFrame.BorderColor3 = Theme.BorderColor
    MainFrame.BorderSizePixel = 2
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Theme.SecondaryColor
    Title.BorderColor3 = Theme.BorderColor
    Title.BorderSizePixel = 2
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Theme.TextColor
    Title.TextSize = 18
    
    -- Botón de cerrar
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = Title
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Container para tabs
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = Theme.SecondaryColor
    TabContainer.BorderColor3 = Theme.BorderColor
    TabContainer.BorderSizePixel = 2
    TabContainer.Position = UDim2.new(0, 10, 0, 50)
    TabContainer.Size = UDim2.new(0, 120, 1, -60)
    
    -- Container para contenido
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundColor3 = Theme.SecondaryColor
    ContentContainer.BorderColor3 = Theme.BorderColor
    ContentContainer.BorderSizePixel = 2
    ContentContainer.Position = UDim2.new(0, 140, 0, 50)
    ContentContainer.Size = UDim2.new(1, -150, 1, -60)
    
    -- ScrollingFrame para tabs
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Parent = TabContainer
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.Size = UDim2.new(1, 0, 1, 0)
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.ScrollBarThickness = 4
    TabScroll.ScrollBarImageColor3 = Theme.AccentColor
    
    -- UIListLayout para tabs
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabScroll
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
    end)
    
    local Window = {}
    Window.Tabs = {}
    
    function Window:NewTab(tabName)
        local Tab = {}
        
        -- Botón de tab
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName
        TabButton.Parent = TabScroll
        TabButton.BackgroundColor3 = Theme.MainColor
        TabButton.BorderColor3 = Theme.BorderColor
        TabButton.BorderSizePixel = 1
        TabButton.Size = UDim2.new(1, -10, 0, 35)
        TabButton.Font = Enum.Font.Gotham
        TabButton.Text = tabName
        TabButton.TextColor3 = Theme.TextColor
        TabButton.TextSize = 14
        
        -- Container del tab
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabName .. "Content"
        TabContent.Parent = ContentContainer
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Theme.AccentColor
        TabContent.Visible = false
        
        -- UIListLayout para contenido
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = TabContent
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 5)
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Hacer visible el primer tab
        if #Window.Tabs == 0 then
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Theme.AccentColor
        end
        
        TabButton.MouseButton1Click:Connect(function()
            -- Ocultar todos los tabs
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Theme.MainColor
            end
            -- Mostrar este tab
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Theme.AccentColor
        end)
        
        Tab.Content = TabContent
        Tab.Button = TabButton
        table.insert(Window.Tabs, Tab)
        
        function Tab:NewSection(sectionName)
            local Section = {}
            
            -- Frame de sección
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = sectionName
            SectionFrame.Parent = TabContent
            SectionFrame.BackgroundColor3 = Theme.MainColor
            SectionFrame.BorderColor3 = Theme.BorderColor
            SectionFrame.BorderSizePixel = 1
            SectionFrame.Size = UDim2.new(1, -10, 0, 0)
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            
            -- Título de sección
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionFrame
            SectionTitle.BackgroundColor3 = Theme.SecondaryColor
            SectionTitle.BorderColor3 = Theme.BorderColor
            SectionTitle.BorderSizePixel = 1
            SectionTitle.Size = UDim2.new(1, 0, 0, 30)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = sectionName
            SectionTitle.TextColor3 = Theme.AccentColor
            SectionTitle.TextSize = 14
            
            -- Container de elementos
            local ElementContainer = Instance.new("Frame")
            ElementContainer.Name = "ElementContainer"
            ElementContainer.Parent = SectionFrame
            ElementContainer.BackgroundTransparency = 1
            ElementContainer.Position = UDim2.new(0, 0, 0, 35)
            ElementContainer.Size = UDim2.new(1, 0, 0, 0)
            ElementContainer.AutomaticSize = Enum.AutomaticSize.Y
            
            local ElementLayout = Instance.new("UIListLayout")
            ElementLayout.Parent = ElementContainer
            ElementLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementLayout.Padding = UDim.new(0, 5)
            
            -- Padding
            local Padding = Instance.new("UIPadding")
            Padding.Parent = ElementContainer
            Padding.PaddingTop = UDim.new(0, 5)
            Padding.PaddingBottom = UDim.new(0, 5)
            Padding.PaddingLeft = UDim.new(0, 5)
            Padding.PaddingRight = UDim.new(0, 5)
            
            function Section:NewButton(buttonText, buttonInfo, callback)
                local Button = Instance.new("TextButton")
                Button.Name = buttonText
                Button.Parent = ElementContainer
                Button.BackgroundColor3 = Theme.SecondaryColor
                Button.BorderColor3 = Theme.BorderColor
                Button.BorderSizePixel = 1
                Button.Size = UDim2.new(1, -10, 0, 35)
                Button.Font = Enum.Font.Gotham
                Button.Text = buttonText
                Button.TextColor3 = Theme.TextColor
                Button.TextSize = 13
                
                Button.MouseEnter:Connect(function()
                    CreateTween(Button, {BackgroundColor3 = Theme.AccentColor})
                end)
                
                Button.MouseLeave:Connect(function()
                    CreateTween(Button, {BackgroundColor3 = Theme.SecondaryColor})
                end)
                
                Button.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)
            end
            
            function Section:NewToggle(toggleText, toggleInfo, default, callback)
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = toggleText
                ToggleFrame.Parent = ElementContainer
                ToggleFrame.BackgroundColor3 = Theme.SecondaryColor
                ToggleFrame.BorderColor3 = Theme.BorderColor
                ToggleFrame.BorderSizePixel = 1
                ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Parent = ToggleFrame
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
                ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.Text = toggleText
                ToggleLabel.TextColor3 = Theme.TextColor
                ToggleLabel.TextSize = 13
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Parent = ToggleFrame
                ToggleButton.BackgroundColor3 = default and Theme.AccentColor or Theme.MainColor
                ToggleButton.BorderColor3 = Theme.BorderColor
                ToggleButton.BorderSizePixel = 1
                ToggleButton.Position = UDim2.new(1, -35, 0.5, -12)
                ToggleButton.Size = UDim2.new(0, 30, 0, 24)
                ToggleButton.Text = ""
                
                local ToggleIndicator = Instance.new("Frame")
                ToggleIndicator.Parent = ToggleButton
                ToggleIndicator.BackgroundColor3 = Theme.TextColor
                ToggleIndicator.BorderSizePixel = 0
                ToggleIndicator.Position = default and UDim2.new(0, 16, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
                ToggleIndicator.Size = UDim2.new(0, 10, 0, 16)
                
                local toggled = default
                
                ToggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    CreateTween(ToggleButton, {BackgroundColor3 = toggled and Theme.AccentColor or Theme.MainColor})
                    CreateTween(ToggleIndicator, {Position = toggled and UDim2.new(0, 16, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)})
                    pcall(callback, toggled)
                end)
            end
            
            function Section:NewLabel(labelText)
                local Label = Instance.new("TextLabel")
                Label.Name = labelText
                Label.Parent = ElementContainer
                Label.BackgroundColor3 = Theme.SecondaryColor
                Label.BorderColor3 = Theme.BorderColor
                Label.BorderSizePixel = 1
                Label.Size = UDim2.new(1, -10, 0, 30)
                Label.Font = Enum.Font.Gotham
                Label.Text = labelText
                Label.TextColor3 = Theme.TextColor
                Label.TextSize = 13
            end
            
            function Section:NewTextBox(placeholderText, callback)
                local TextBox = Instance.new("TextBox")
                TextBox.Name = placeholderText
                TextBox.Parent = ElementContainer
                TextBox.BackgroundColor3 = Theme.SecondaryColor
                TextBox.BorderColor3 = Theme.BorderColor
                TextBox.BorderSizePixel = 1
                TextBox.Size = UDim2.new(1, -10, 0, 35)
                TextBox.Font = Enum.Font.Gotham
                TextBox.PlaceholderText = placeholderText
                TextBox.Text = ""
                TextBox.TextColor3 = Theme.TextColor
                TextBox.TextSize = 13
                TextBox.ClearTextOnFocus = false
                
                TextBox.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        pcall(callback, TextBox.Text)
                    end
                end)
            end
            
            return Section
        end
        
        return Tab
    end
    
    return Window
end

return Library
