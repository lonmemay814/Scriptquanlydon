-- Script chạy phía client (LocalScript) trong StarterGui
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- Tạo DataStore để lưu dữ liệu
local orderDataStore = DataStoreService:GetDataStore("PlayerOrders")

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.Name = "OrderManagement"

-- Tạo khung chính (màu đen mờ, thu nhỏ)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 80) -- Kích thước nhỏ hơn, chỉ chiếm góc trên
frame.Position = UDim2.new(0, 10, 0, 10) -- Góc trên bên trái
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.Parent = gui

-- Nút đóng giao diện
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Parent = frame

-- Hàm che tên người dùng
local function maskUsername(username)
    if #username <= 3 then return username end
    local firstPart = string.sub(username, 1, 3)
    local lastChar = string.sub(username, -1)
    return firstPart .. "****" .. lastChar
end

-- Nhãn thông tin người chơi (Tên)
local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(0, 150, 0, 30)
nameLabel.Position = UDim2.new(0, 10, 0, 10)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "Tên: " .. maskUsername(player.Name)
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.TextScaled = true
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = frame

-- Nhãn số đơn (Đơn)
local orderCountLabel = Instance.new("TextLabel")
orderCountLabel.Size = UDim2.new(0, 150, 0, 30)
orderCountLabel.Position = UDim2.new(0, 10, 0, 40)
orderCountLabel.BackgroundTransparency = 1
orderCountLabel.Text = "Đơn: 0"
orderCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
orderCountLabel.TextScaled = true
orderCountLabel.TextXAlignment = Enum.TextXAlignment.Left
orderCountLabel.Parent = frame

-- Biến lưu số lượng đơn
local orderCount = 0

-- Hàm cập nhật thông tin
local function updatePlayerInfo()
    nameLabel.Text = "Tên: " .. maskUsername(player.Name)
    orderCountLabel.Text = "Đơn: " .. orderCount
end

-- Xử lý nút đóng
closeButton.MouseButton1Click:Connect(function()
    gui.Enabled = false -- Ẩn giao diện
end)

-- Tải dữ liệu khi người chơi tham gia
local function loadPlayerData()
    local success, data = pcall(function()
        return orderDataStore:GetAsync(player.UserId .. "-orders")
    end)
    if success and data then
        orderCount = data.orderCount or 0
    end
    updatePlayerInfo()
end

-- Lưu dữ liệu khi người chơi thoát
player.AncestryChanged:Connect(function()
    if player.Parent == nil then
        local success, err = pcall(function()
            orderDataStore:SetAsync(player.UserId .. "-orders", {
                orderCount = orderCount
            })
        end)
        if not success then
            warn("Lỗi khi lưu dữ liệu: " .. err)
        end
    end
end)

-- Tải dữ liệu ban đầu
loadPlayerData()