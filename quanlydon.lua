local HttpService = game:GetService("HttpService")
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local filePath = "BloxFruitOrderData.txt"

local SaveOrderData = ReplicatedStorage:FindFirstChild("SaveOrderData")
if not SaveOrderData then
    SaveOrderData = Instance.new("RemoteEvent")
    SaveOrderData.Name = "SaveOrderData"
    SaveOrderData.Parent = ReplicatedStorage
end

local function canSaveData()
    return (writefile and readfile and isfile) ~= nil    
end

local function saveLocalDataForPlayer(username, data)
    if not canSaveData() then
        warn("Executor không hỗ trợ lưu file!")
        return
    end
    
    local allData = {}

    if isfile(filePath) then
        local content = readfile(filePath)
        local success, parsed = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if success and typeof(parsed) == "table" then
            allData = parsed
        end
    end

    allData[username] = data
    local encoded = HttpService:JSONEncode(allData)
    writefile(filePath, encoded)
end

local function loadLocalDataForPlayer(username)
    if canSaveData() and isfile(filePath) then
        local content = readfile(filePath)
        local success, parsed = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if success and typeof(parsed) == "table" then
            return parsed[username] or "0"
        end
    end
    return "0"
end

local function hideName(name)
    local visibleLength = math.max(3, math.floor(#name * 0.5))
    local hiddenPart = string.rep("*", #name - visibleLength)
    return string.sub(name, 1, visibleLength) .. hiddenPart
end

-- GUI
local nameHub = Instance.new("ScreenGui")
nameHub.Name = "NameHub"
nameHub.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Parent = nameHub
mainFrame.Size = UDim2.new(0, 200, 0, 65)
mainFrame.Position = UDim2.new(0.5, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Active = true
mainFrame.Draggable = true

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0.15, 0)
uiCorner.Parent = mainFrame

local nameLabel = Instance.new("TextLabel")
nameLabel.Parent = mainFrame
nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
nameLabel.Position = UDim2.new(0, 0, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.TextScaled = true
nameLabel.Font = Enum.Font.GothamBold
nameLabel.Text = "Tên : " .. hideName(player.Name)
nameLabel.TextXAlignment = Enum.TextXAlignment.Left -- Căn trái

local jobTitle = Instance.new("TextLabel")
jobTitle.Parent = mainFrame
jobTitle.Size = UDim2.new(0.3, 0, 0.5, 0)
jobTitle.Position = UDim2.new(0, 0, 0.5, 0)
jobTitle.BackgroundTransparency = 1
jobTitle.TextColor3 = Color3.fromRGB(255, 223, 88)
jobTitle.TextScaled = true
jobTitle.Font = Enum.Font.GothamBold
jobTitle.Text = "Đơn :"
jobTitle.TextXAlignment = Enum.TextXAlignment.Left -- Căn trái

local jobBox = Instance.new("TextBox")
jobBox.Parent = mainFrame
jobBox.Size = UDim2.new(0.7, 0, 0.5, 0)
jobBox.Position = UDim2.new(0.3, 0, 0.5, 0)
jobBox.BackgroundTransparency = 1
jobBox.TextColor3 = Color3.fromRGB(255, 255, 255)
jobBox.TextScaled = true
jobBox.Font = Enum.Font.GothamBold
jobBox.Text = ""
jobBox.ClearTextOnFocus = false
jobBox.TextWrapped = true
jobBox.TextXAlignment = Enum.TextXAlignment.Left -- Căn trái cho ô nhập

jobBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and jobBox.Text ~= "" then
        jobBox.Text = jobBox.Text
    end
end)

jobBox.FocusLost:Connect(function()
    local orderData = jobBox.Text
    saveLocalDataForPlayer(player.Name, orderData)
    SaveOrderData:FireServer(orderData)
end)

SaveOrderData.OnClientEvent:Connect(function(orderData)
    jobBox.Text = orderData
end)

jobBox.Text = loadLocalDataForPlayer(player.Name)
SaveOrderData:FireServer("request")
