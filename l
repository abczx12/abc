--[[
  IOSVIET UI NHỎ GỌN - KÉO THẢ ĐƯỢC
  ESP 7 màu + Destroy Mode + Base cao + Chờ target hồi sinh
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- ========== CẤU HÌNH ==========
local Config = {
    DestroyMode = false,
    ESPEnabled = true,
    SelectedPlayer = nil,
    UIEnabled = true,
}

-- ========== TÌM REMOTE ==========
local SavingEvent = ReplicatedStorage:WaitForChild("Save"):WaitForChild("SavingEvent")
local args = {1}

-- ========== BASE TRÊN CAO ==========
local HighBase = nil
local function CreateHighBase()
    if HighBase and HighBase.Parent then
        HighBase:Destroy()
    end
    HighBase = Instance.new("Part")
    HighBase.Name = "HighBase"
    HighBase.Size = Vector3.new(80, 1, 80)
    HighBase.Position = Vector3.new(0, 1500, 0)
    HighBase.Anchored = true
    HighBase.CanCollide = true
    HighBase.Transparency = 0.5
    HighBase.BrickColor = BrickColor.new("Bright red")
    HighBase.Parent = workspace
end

local function TeleportToBase()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(0, 1505, 0)
    end
end

-- ========== ESP 7 MÀU ==========
local espObjects = {}
local rainbowHue = 0

local function ClearESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Remove() end)
    end
    espObjects = {}
end

local function GetRainbowColor()
    rainbowHue = (rainbowHue + 0.01) % 1
    return Color3.fromHSV(rainbowHue, 1, 1)
end

local function UpdateESP()
    if not Config.ESPEnabled then
        ClearESP()
        return
    end
    
    ClearESP()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local root = char.HumanoidRootPart
                local head = char:FindFirstChild("Head") or root
                local humanoid = char.Humanoid
                local health = humanoid.Health
                local maxHealth = humanoid.MaxHealth
                local healthPercent = math.clamp(health / maxHealth, 0, 1)
                
                local bottomPos, bottomOn = Camera:WorldToScreenPoint(root.Position - Vector3.new(0, 2, 0))
                local topPos, topOn = Camera:WorldToScreenPoint(head.Position + Vector3.new(0, 1.5, 0))
                
                if bottomOn and topOn then
                    local height = math.abs(topPos.Y - bottomPos.Y)
                    local width = height * 0.6
                    local rainbowColor = GetRainbowColor()
                    
                    local box = Drawing.new("Square")
                    box.Position = Vector2.new(topPos.X - width/2, topPos.Y)
                    box.Size = Vector2.new(width, height)
                    box.Color = rainbowColor
                    box.Thickness = 2
                    box.Filled = false
                    box.Visible = true
                    table.insert(espObjects, box)
                    
                    local line = Drawing.new("Line")
                    line.From = center
                    line.To = Vector2.new(bottomPos.X, bottomPos.Y)
                    line.Color = rainbowColor
                    line.Thickness = 1.5
                    line.Visible = true
                    table.insert(espObjects, line)
                    
                    local healthColor = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                    local healthBar = Drawing.new("Line")
                    healthBar.From = Vector2.new(topPos.X - width/2, topPos.Y - 8)
                    healthBar.To = Vector2.new(topPos.X - width/2 + (width * healthPercent), topPos.Y - 8)
                    healthBar.Color = healthColor
                    healthBar.Thickness = 5
                    healthBar.Visible = true
                    table.insert(espObjects, healthBar)
                    
                    local nameText = Drawing.new("Text")
                    nameText.Position = Vector2.new(topPos.X, topPos.Y - 18)
                    nameText.Text = player.Name .. " [" .. math.floor(health) .. "]"
                    nameText.Color = Color3.fromRGB(255, 255, 255)
                    nameText.Size = 12
                    nameText.Center = true
                    nameText.Visible = true
                    table.insert(espObjects, nameText)
                end
            end
        end
    end
end

-- ========== LẤY VŨ KHÍ ==========
local function GetAllTools()
    local tools = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    if backpack then
        for _, v in pairs(backpack:GetChildren()) do
            if v:IsA("Tool") and v.Name ~= "Doge-Fruit" then
                table.insert(tools, v)
            end
        end
    end
    if char then
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") and v.Name ~= "Doge-Fruit" then
                table.insert(tools, v)
            end
        end
    end
    return tools
end

-- ========== SPAM SKILL ==========
local keys = {"Z", "X", "C", "V", "B", "N"}
local function SpamAllSkills()
    local tools = GetAllTools()
    for _, tool in pairs(tools) do
        for _, key in ipairs(keys) do
            pcall(function()
                if tool:FindFirstChild(key) then
                    local skill = tool[key]
                    if skill:FindFirstChild("Fire") then skill.Fire:FireServer() end
                    if skill:FindFirstChild("RemoteEvent") then skill.RemoteEvent:FireServer() end
                    pcall(function() skill:FireServer() end)
                end
            end)
        end
    end
end

-- ========== CHỜ TARGET HỒI SINH ==========
local function WaitForTargetRespawn(target)
    while Config.DestroyMode and target do
        if target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
            return true
        end
        task.wait(0.5)
    end
    return false
end

-- ========== DESTROY MODE ==========
local isDestroying = false

local function DestroyLoop()
    while isDestroying do
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not char or not backpack then
            task.wait(0.5)
            goto continue
        end
        
        local dogeFruit = backpack:FindFirstChild("Doge-Fruit") or char:FindFirstChild("Doge-Fruit")
        if not dogeFruit then
            pcall(function() SavingEvent:FireServer(unpack(args)) end)
            local waitTime = 0
            while not (backpack:FindFirstChild("Doge-Fruit") or char:FindFirstChild("Doge-Fruit")) and waitTime < 30 do
                task.wait(0.1)
                waitTime = waitTime + 1
            end
            task.wait(0.5)
            goto continue
        end
        
        local tools = GetAllTools()
        if #tools == 0 then
            task.wait(0.2)
            goto continue
        end
        
        local target = Config.SelectedPlayer
        if target then
            if target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
                pcall(function()
                    char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end)
                task.wait(0.05)
                SpamAllSkills()
                task.wait(0.05)
            else
                WaitForTargetRespawn(target)
                goto continue
            end
        end
        
        dogeFruit = backpack:FindFirstChild("Doge-Fruit") or char:FindFirstChild("Doge-Fruit")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if dogeFruit and hum then
            pcall(function() hum:EquipTool(dogeFruit) end)
            task.wait(0.1)
            local oldChar = LocalPlayer.Character
            TeleportToBase()
            task.wait(0.05)
            pcall(function() SavingEvent:FireServer(unpack(args)) end)
            task.wait(0.05)
            LocalPlayer.Character.Humanoid.Health = 0
            local timeout = 0
            while LocalPlayer.Character == oldChar and timeout < 30 do
                task.wait(0.1)
                timeout = timeout + 1
            end
            local waitToolTime = 0
            while waitToolTime < 50 do
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp and #bp:GetChildren() > 0 then break end
                task.wait(0.1)
                waitToolTime = waitToolTime + 1
            end
            task.wait(0.3)
            local newChar = LocalPlayer.Character
            if newChar and newChar:FindFirstChild("HumanoidRootPart") and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    newChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end)
            end
            task.wait(0.3)
        end
        ::continue::
    end
end

-- ========== UI NHỎ GỌN ==========
local function CreateMiniUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Sex Nigga"
    screenGui.ResetOnSpawn = false
    pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    if not screenGui.Parent then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main button (nút chính)
    local mainBtn = Instance.new("TextButton")
    mainBtn.Parent = screenGui
    mainBtn.Size = UDim2.new(0, 60, 0, 60)
    mainBtn.Position = UDim2.new(0.02, 0, 0.5, -30)
    mainBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    mainBtn.Text = "🔥"
    mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainBtn.TextSize = 30
    mainBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1, 0)
    
    -- Menu panel (kéo thả được)
    local menuPanel = Instance.new("Frame")
    menuPanel.Parent = screenGui
    menuPanel.Size = UDim2.new(0, 220, 0, 280)
    menuPanel.Position = UDim2.new(0.02, 70, 0.5, -140)
    menuPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    menuPanel.BackgroundTransparency = 0.15
    menuPanel.BorderSizePixel = 2
    menuPanel.BorderColor3 = Color3.fromRGB(255, 0, 0)
    menuPanel.Visible = false
    menuPanel.Active = true
    menuPanel.Draggable = true
    Instance.new("UICorner", menuPanel).CornerRadius = UDim.new(0, 10)
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Parent = menuPanel
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    titleBar.BorderSizePixel = 0
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)
    
    local titleText = Instance.new("TextLabel")
    titleText.Parent = titleBar
    titleText.Size = UDim2.new(1, -30, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "IOSVIET DESTROYER"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 12
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = titleBar
    closeBtn.Size = UDim2.new(0, 25, 1, 0)
    closeBtn.Position = UDim2.new(1, -25, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    
    -- Dropdown chọn player
    local playerBtn = Instance.new("TextButton")
    playerBtn.Parent = menuPanel
    playerBtn.Size = UDim2.new(0.9, 0, 0, 35)
    playerBtn.Position = UDim2.new(0.05, 0, 0, 40)
    playerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    playerBtn.Text = "🎯 CHỌN PLAYER"
    playerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerBtn.TextSize = 12
    Instance.new("UICorner", playerBtn).CornerRadius = UDim.new(0, 6)
    
    local playerList = Instance.new("ScrollingFrame")
    playerList.Parent = menuPanel
    playerList.Size = UDim2.new(0.9, 0, 0, 100)
    playerList.Position = UDim2.new(0.05, 0, 0, 80)
    playerList.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    playerList.BackgroundTransparency = 0.3
    playerList.Visible = false
    playerList.ScrollBarThickness = 4
    Instance.new("UICorner", playerList).CornerRadius = UDim.new(0, 6)
    
    local function RefreshPlayerList()
        for _, child in pairs(playerList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        local y = 5
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local pBtn = Instance.new("TextButton")
                pBtn.Parent = playerList
                pBtn.Size = UDim2.new(0.95, 0, 0, 30)
                pBtn.Position = UDim2.new(0.025, 0, 0, y)
                pBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                pBtn.Text = player.Name
                pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                pBtn.TextSize = 11
                Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 5)
                pBtn.MouseButton1Click:Connect(function()
                    Config.SelectedPlayer = player
                    playerBtn.Text = "✅ " .. player.Name
                    playerList.Visible = false
                end)
                y = y + 35
            end
        end
        playerList.CanvasSize = UDim2.new(0, 0, 0, y)
    end
    
    playerBtn.MouseButton1Click:Connect(function()
        RefreshPlayerList()
        playerList.Visible = not playerList.Visible
    end)
    
    -- Destroy Mode toggle
    local destroyBtn = Instance.new("TextButton")
    destroyBtn.Parent = menuPanel
    destroyBtn.Size = UDim2.new(0.9, 0, 0, 35)
    destroyBtn.Position = UDim2.new(0.05, 0, 0, 190)
    destroyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    destroyBtn.Text = "🔴 DESTROY: OFF"
    destroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    destroyBtn.TextSize = 12
    Instance.new("UICorner", destroyBtn).CornerRadius = UDim.new(0, 6)
    
    destroyBtn.MouseButton1Click:Connect(function()
        Config.DestroyMode = not Config.DestroyMode
        isDestroying = Config.DestroyMode
        if Config.DestroyMode then
            destroyBtn.Text = "🟢 DESTROY: ON"
            destroyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            mainBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            task.spawn(DestroyLoop)
        else
            destroyBtn.Text = "🔴 DESTROY: OFF"
            destroyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            mainBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    end)
    
    -- ESP toggle
    local espBtn = Instance.new("TextButton")
    espBtn.Parent = menuPanel
    espBtn.Size = UDim2.new(0.9, 0, 0, 30)
    espBtn.Position = UDim2.new(0.05, 0, 0, 235)
    espBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
    espBtn.Text = " ESP: ON"
    espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    espBtn.TextSize = 11
    Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 6)
    
    espBtn.MouseButton1Click:Connect(function()
        Config.ESPEnabled = not Config.ESPEnabled
        espBtn.Text = Config.ESPEnabled and "✅ ESP: ON" or "❌ ESP: OFF"
        espBtn.BackgroundColor3 = Config.ESPEnabled and Color3.fromRGB(60, 150, 60) or Color3.fromRGB(100, 60, 60)
    end)
    
    -- Target status
    local targetStatus = Instance.new("TextLabel")
    targetStatus.Parent = menuPanel
    targetStatus.Size = UDim2.new(0.9, 0, 0, 20)
    targetStatus.Position = UDim2.new(0.05, 0, 0, 165)
    targetStatus.BackgroundTransparency = 1
    targetStatus.Text = "⚡ Chưa chọn target"
    targetStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
    targetStatus.TextSize = 9
    
    -- Xử lý đóng/mở menu
    local menuVisible = false
    mainBtn.MouseButton1Click:Connect(function()
        menuVisible = not menuVisible
        menuPanel.Visible = menuVisible
        mainBtn.Text = menuVisible and "✕" or "🔥"
        mainBtn.BackgroundColor3 = menuVisible and Color3.fromRGB(50, 50, 50) or (Config.DestroyMode and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50))
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        menuVisible = false
        menuPanel.Visible = false
        mainBtn.Text = "🔥"
        mainBtn.BackgroundColor3 = Config.DestroyMode and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    end)
    
    -- Cập nhật target status
    task.spawn(function()
        while true do
            if Config.SelectedPlayer then
                if Config.SelectedPlayer.Character and Config.SelectedPlayer.Character:FindFirstChild("Humanoid") then
                    local hp = Config.SelectedPlayer.Character.Humanoid.Health
                    targetStatus.Text = "🎯 " .. Config.SelectedPlayer.Name .. " | " .. math.floor(hp) .. " HP"
                else
                    targetStatus.Text = "💀 " .. Config.SelectedPlayer.Name .. " | CHỜ HỒI SINH"
                end
            else
                targetStatus.Text = "⚡ Chưa chọn target"
            end
            task.wait(0.5)
        end
    end)
end

-- ========== KHỞI CHẠY ==========
CreateHighBase()
CreateMiniUI()

RunService.RenderStepped:Connect(function()
    pcall(UpdateESP)
end)

print("========================================")
print("  IOSVIET DESTROYER - NHỎ GỌN")
print("  Nút 🔥 ở góc trái để mở menu")
print("  Kéo thả menu được")
print("========================================")
