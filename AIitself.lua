local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Состояние системы
local isAimbotActive = false
local isEspActive = false

-- === 1. СОЗДАНИЕ UI (Интерфейс управления) ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DroneTargetingSystemUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Главная панель
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 180)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -30, 0, 30)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.Text = "Система Наведения"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

-- Кнопка сворачивания
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -28, 0, 2.5)
minimizeBtn.Text = "_"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeBtn.Parent = mainFrame

-- Кнопка-квадратик (свернутый режим)
local minimizedFrame = Instance.new("TextButton")
minimizedFrame.Name = "MinimizedFrame"
minimizedFrame.Size = UDim2.new(0, 40, 0, 40)
minimizedFrame.Position = mainFrame.Position
minimizedFrame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
minimizedFrame.Text = "🎯"
minimizedFrame.TextSize = 20
minimizedFrame.Visible = false
minimizedFrame.Parent = screenGui

-- Кнопка Аимбота
local aimbotBtn = Instance.new("TextButton")
aimbotBtn.Size = UDim2.new(0.9, 0, 0, 40)
aimbotBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
aimbotBtn.Text = "Автонаведение: ВЫКЛ"
aimbotBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
aimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotBtn.Parent = mainFrame

-- Кнопка ESP
local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0.9, 0, 0, 40)
espBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
espBtn.Text = "Подсветка (ESP): ВЫКЛ"
espBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.Parent = mainFrame

-- === 2. МЕХАНИКА ТАСКАНИЯ UI (Dragging) ===
local function enableDragging(frame, dragHandle)
	local dragging = false
	local dragInput, dragStart, startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, 
				startPos.X.Offset + delta.X, 
				startPos.Y.Scale, 
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

enableDragging(mainFrame, mainFrame)
enableDragging(minimizedFrame, minimizedFrame)

-- Сворачивание и разворачивание
minimizeBtn.MouseButton1Click:Connect(function()
	minimizedFrame.Position = mainFrame.Position
	mainFrame.Visible = false
	minimizedFrame.Visible = true
end)

minimizedFrame.MouseButton1Click:Connect(function()
	mainFrame.Position = minimizedFrame.Position
	minimizedFrame.Visible = false
	mainFrame.Visible = true
end)

-- === 3. ЛОГИКА ПОИСКА И НАВЕДЕНИЯ ===

-- Поиск ближайшего дрона
local function getClosestDrone()
	local folder = workspace:FindFirstChild("SpawnedDrones")
	if not folder then return nil end

	local character = LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

	local playerPos = character.HumanoidRootPart.Position
	local closestDrone = nil
	local shortestDistance = math.huge

	for _, drone in ipairs(folder:GetChildren()) do
		local part = drone:IsA("BasePart") and drone or drone:FindFirstChildWhichIsA("BasePart")
		if part then
			local distance = (part.Position - playerPos).Magnitude
			if distance < shortestDistance then
				shortestDistance = distance
				closestDrone = part
			end
		end
	end

	return closestDrone
end

-- Включение/Выключение Аимбота
aimbotBtn.MouseButton1Click:Connect(function()
	isAimbotActive = not isAimbotActive
	if isAimbotActive then
		aimbotBtn.Text = "Автонаведение: ВКЛ"
		aimbotBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
	else
		aimbotBtn.Text = "Автонаведение: ВЫКЛ"
		aimbotBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	end
end)

-- Включение/Выключение ESP
espBtn.MouseButton1Click:Connect(function()
	isEspActive = not isEspActive
	if isEspActive then
		espBtn.Text = "Подсветка (ESP): ВКЛ"
		espBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
	else
		espBtn.Text = "Подсветка (ESP): ВЫКЛ"
		espBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	end
end)

-- === 4. ГЛАВНЫЙ ЦИКЛ ОБНОВЛЕНИЯ (RenderStepped) ===
RunService.RenderStepped:Connect(function()
	local folder = workspace:FindFirstChild("SpawnedDrones")
	
	-- Логика ESP (Красная подсветка)
	if folder then
		for _, drone in ipairs(folder:GetChildren()) do
			local highlight = drone:FindFirstChildOfClass("Highlight")
			
			if isEspActive then
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Name = "DroneHighlight"
					highlight.FillColor = Color3.fromRGB(255, 0, 0)
					highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					highlight.FillTransparency = 0.3
					highlight.OutlineTransparency = 0
					highlight.Parent = drone
				end
				highlight.Enabled = true
			else
				if highlight then
					highlight.Enabled = false
				end
			end
		end
	end

	-- Логика наведения камеры
	if isAimbotActive then
		local targetPart = getClosestDrone()
		if targetPart then
			-- Плавно направляем камеру на цель
			local currentCFrame = Camera.CFrame
			local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPart.Position)
			Camera.CFrame = currentCFrame:Lerp(targetCFrame, 0.2)
		end
	end
end)
