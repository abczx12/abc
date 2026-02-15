local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Khanhdzaii/orionlib/refs/heads/main/orionlib"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

getgenv().AutoSummon = false
getgenv().AutoRandom = false
getgenv().AutoStore = false
getgenv().NoDelay = false

local DelayTime = 1

-- ========== CODE GIAO DIỆN (HÌNH NỀN, MÀU SẮC) ==========
local hubColorFile = "HubColor.json"
local textAndBorderColorFile = "TextAndBorderColor.json"
local savedHubColor = nil
local savedTextAndBorderColor = nil

-- Hàm lưu màu vào file
local function saveColor(color, path)
    local colorData = { r = color.R, g = color.G, b = color.B }
    local jsonData = HttpService:JSONEncode(colorData)
    writefile(path, jsonData)
end

-- Hàm tải màu từ file
local function loadColor(path, defaultColor)
    if isfile(path) then
        local jsonData = readfile(path)
        local colorData = HttpService:JSONDecode(jsonData)
        return Color3.new(colorData.r, colorData.g, colorData.b)
    else
        return defaultColor
    end
end

-- Hàm áp dụng màu nền cho Hub
local function applyHubColor(hubColor)
    if gethui():FindFirstChild("Orion") then
        for _, i in pairs(gethui():GetChildren()) do
            if i.Name == "Orion" then
                for _, v in pairs(i:GetDescendants()) do
                    if v.ClassName == "Frame" and v.BackgroundTransparency < 0.99 then
                        v.BackgroundColor3 = hubColor
                    end
                end
            end
        end
    end
end

-- Hàm áp dụng màu viền và chữ
local function applyTextAndBorderColor(color)
    if gethui():FindFirstChild("Orion") then
        for _, i in pairs(gethui():GetChildren()) do
            if i.Name == "Orion" then
                for _, v in pairs(i:GetDescendants()) do
                    if v.ClassName == "Frame" then
                        v.BorderColor3 = color
                    end
                    if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                        v.TextColor3 = color
                    end
                end
            end
        end
    end
end

-- Hàm áp dụng độ trong suốt của Hub
local function applyHubTransparency(transparency)
    if gethui():FindFirstChild("Orion") then
        for _, gui in pairs(gethui():GetChildren()) do
            if gui.Name == "Orion" then
                for _, frame in pairs(gui:GetDescendants()) do
                    if frame:IsA("Frame") and frame.BackgroundTransparency < 0.99 then
                        frame.BackgroundTransparency = transparency
                    end
                end
            end
        end
    end
end

-- ========== ID HÌNH NỀN MỚI (ĐÃ XÓA CŨ) ==========
local BackgroundImages = {
    "79464702411655",  -- Ảnh mới 1
    "78188111267182",  -- Ảnh mới 2
    "87324819549778"   -- Ảnh mới 3
}

-- Hàm chọn ngẫu nhiên ID hình nền
local function getRandomImageId()
    return BackgroundImages[math.random(1, #BackgroundImages)]
end

-- Hàm áp dụng hình nền
local function applyHubBackground(imageId, transparency)
    if gethui():FindFirstChild("Orion") then
        for _, gui in pairs(gethui():GetChildren()) do
            if gui.Name == "Orion" then
                local largestFrame = nil
                local maxSize = 0

                for _, frame in pairs(gui:GetDescendants()) do
                    if frame:IsA("Frame") and frame.BackgroundTransparency < 1 then
                        local frameSize = frame.AbsoluteSize.X * frame.AbsoluteSize.Y
                        if frameSize > maxSize then
                            maxSize = frameSize
                            largestFrame = frame
                        end
                    end
                end

                if largestFrame then
                    if largestFrame:FindFirstChild("HubBackground") then
                        largestFrame:FindFirstChild("HubBackground"):Destroy()
                    end

                    local background = Instance.new("ImageLabel")
                    background.Name = "HubBackground"
                    background.Parent = largestFrame
                    background.Size = UDim2.new(1, 0, 1, 0)
                    background.Position = UDim2.new(0, 0, 0, 0)
                    background.Image = "rbxassetid://" .. imageId
                    background.BackgroundTransparency = 1
                    background.ImageTransparency = transparency or 0.7
                    background.ScaleType = Enum.ScaleType.Stretch
                    background.ZIndex = 0
                end
            end
        end
    end
end

-- Hàm xóa hình nền
local function resetBackground()
    if gethui():FindFirstChild("Orion") then
        for _, gui in pairs(gethui():GetChildren()) do
            if gui.Name == "Orion" then
                for _, frame in pairs(gui:GetDescendants()) do
                    if frame:IsA("Frame") and frame:FindFirstChild("HubBackground") then
                        frame:FindFirstChild("HubBackground"):Destroy()
                    end
                end
            end
        end
    end
end

-- Hàm áp dụng độ trong suốt của hình nền
local function applyBackgroundTransparency(transparency)
    if gethui():FindFirstChild("Orion") then
        for _, gui in pairs(gethui():GetChildren()) do
            if gui.Name == "Orion" then
                for _, frame in pairs(gui:GetDescendants()) do
                    if frame:IsA("Frame") and frame:FindFirstChild("HubBackground") then
                        frame.HubBackground.ImageTransparency = transparency
                    end
                end
            end
        end
    end
end

-- Tải màu đã lưu
savedHubColor = loadColor(hubColorFile, Color3.fromRGB(30, 30, 30))
savedTextAndBorderColor = loadColor(textAndBorderColorFile, Color3.fromRGB(255, 255, 255))

-- ========== TẠO WINDOW CHÍNH ==========
local Window = OrionLib:MakeWindow({
    Name = "System Control",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = false
})

-- ========== TAB MAIN (CHỨC NĂNG CHÍNH) ==========
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddToggle({
    Name = "Auto Summon",
    Default = false,
    Callback = function(Value)
        getgenv().AutoSummon = Value
    end
})

task.spawn(function()
    while true do
        if getgenv().AutoSummon then
            pcall(function()
                ReplicatedStorage.System.Summon:FireServer("Sukuna")
            end)
            task.wait(getgenv().NoDelay and 0 or DelayTime)
        else
            task.wait(0.2)
        end
    end
end)

MainTab:AddToggle({
    Name = "Auto Random",
    Default = false,
    Callback = function(Value)
        getgenv().AutoRandom = Value
    end
})

task.spawn(function()
    while true do
        if getgenv().AutoRandom then
            pcall(function()
                ReplicatedStorage.System.RandomItem:FireServer(5)
            end)
            task.wait(getgenv().NoDelay and 0 or DelayTime)
        else
            task.wait(0.2)
        end
    end
end)

MainTab:AddToggle({
    Name = "Auto Store",
    Default = false,
    Callback = function(Value)
        getgenv().AutoStore = Value
    end
})

task.spawn(function()
    while true do
        if getgenv().AutoStore then
            for _,tool in pairs(Player.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    pcall(function()
                        ReplicatedStorage.System.Inv.Inventory:InvokeServer("Add", tool.Name)
                    end)
                end
            end
            task.wait(getgenv().NoDelay and 0 or 2)
        else
            task.wait(0.5)
        end
    end
end)

MainTab:AddToggle({
    Name = "No Delay",
    Default = false,
    Callback = function(Value)
        getgenv().NoDelay = Value
    end
})

-- ========== TAB GIAO DIỆN (HUB) ==========
local HubTab = Window:MakeTab({
    Name = "Hub Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Biến lưu trạng thái hình nền
local backgroundEnabled = false
local currentTransparency = 0.7
local hubTransparency = 0.3

-- Toggle bật/tắt hình nền (Dùng ảnh mới)
HubTab:AddToggle({
    Name = "Bật/Tắt Hình Nền",
    Default = false,
    Callback = function(isOn)
        backgroundEnabled = isOn
        if isOn then
            applyHubBackground(getRandomImageId(), currentTransparency)
        else
            resetBackground()
        end
    end
})

-- Nút chọn ảnh cụ thể (Thêm dropdown để chọn 3 ảnh mới)
HubTab:AddDropdown({
    Name = "Chọn Ảnh Nền",
    Options = {
        "79464702411655 - Ảnh 1",
        "78188111267182 - Ảnh 2",
        "87324819549778 - Ảnh 3"
    },
    Default = "79464702411655 - Ảnh 1",
    Callback = function(value)
        local selectedId = value:match("(%d+)")
        if selectedId then
            applyHubBackground(selectedId, currentTransparency)
            backgroundEnabled = true
        end
    end
})

-- Slider điều chỉnh độ trong suốt của Hub
HubTab:AddSlider({
    Name = "Độ Trong Suốt Hub",
    Min = 0.0,
    Max = 0.98,
    Default = hubTransparency,
    Increment = 0.1,
    Callback = function(value)
        hubTransparency = value
        applyHubTransparency(value)
    end
})

-- Slider điều chỉnh độ rõ của hình nền
HubTab:AddSlider({
    Name = "Độ Rõ Hình Nền",
    Min = 0.1,
    Max = 0.98,
    Default = currentTransparency,
    Increment = 0.1,
    Callback = function(value)
        currentTransparency = value
        if backgroundEnabled then
            applyBackgroundTransparency(value)
        end
    end
})

-- Color Picker đổi màu Hub
HubTab:AddColorpicker({
    Name = "Đổi Màu Hub",
    Default = savedHubColor,
    Callback = function(Value)
        savedHubColor = Value
        saveColor(Value, hubColorFile)
        applyHubColor(savedHubColor)
    end
})

-- Color Picker đổi màu chữ
HubTab:AddColorpicker({
    Name = "Đổi Màu Chữ",
    Default = savedTextAndBorderColor,
    Callback = function(Value)
        savedTextAndBorderColor = Value
        saveColor(Value, textAndBorderColorFile)
        applyTextAndBorderColor(savedTextAndBorderColor)
    end
})

-- Nút làm mới giao diện
HubTab:AddButton({
    Name = "Làm Mới Giao Diện",
    Callback = function()
        applyHubColor(savedHubColor)
        applyTextAndBorderColor(savedTextAndBorderColor)
        applyHubTransparency(hubTransparency)
        if backgroundEnabled then
            applyHubBackground(getRandomImageId(), currentTransparency)
        end
    end
})

-- ========== ÁP DỤNG MÀU KHI KHỞI ĐỘNG ==========
task.wait(1) -- Đợi OrionLib load xong
applyHubColor(savedHubColor)
applyTextAndBorderColor(savedTextAndBorderColor)
applyHubTransparency(hubTransparency)

-- ========== KHỞI TẠO ORIONLIB ==========
OrionLib:Init()