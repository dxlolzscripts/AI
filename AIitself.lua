local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local API_KEY = "AQ.Ab8RN6IUqAHJLHwCsmTx0S7dSZAA5JsRKoB2Q_pahlHYIuz8Sw"
local API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" .. API_KEY

local sg = Instance.new("ScreenGui")
sg.Name = "GeminiPro_v3"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.Parent = player:WaitForChild("PlayerGui")

local mainBg = Instance.new("Frame")
mainBg.Size = UDim2.new(1, 0, 1, 0)
mainBg.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
mainBg.BackgroundTransparency = 0.4
mainBg.Visible = true
mainBg.Parent = sg

local win = Instance.new("Frame")
win.Size = UDim2.new(0, 580, 0, 420)
win.Position = UDim2.new(0.5, -290, 0.5, -210)
win.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
win.BorderSizePixel = 0
win.Active = true
win.Draggable = true
win.Parent = mainBg
local winCorner = Instance.new("UICorner", win)
winCorner.CornerRadius = UDim.new(0, 15)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 40)
top.BackgroundTransparency = 1
top.Parent = win

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.Text = "Architect AI Pro"
title.TextColor3 = Color3.fromRGB(200, 210, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamMedium
title.Parent = top

local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0, 30, 0, 30)
mini.Position = UDim2.new(1, -40, 0, 5)
mini.Text = "_"
mini.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mini.TextColor3 = Color3.new(1,1,1)
mini.Parent = top
Instance.new("UICorner", mini)

local scroller = Instance.new("ScrollingFrame")
scroller.Size = UDim2.new(1, -30, 1, -120)
scroller.Position = UDim2.new(0, 15, 0, 50)
scroller.BackgroundTransparency = 1
scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroller.ScrollBarThickness = 3
scroller.Parent = win
local layout = Instance.new("UIListLayout", scroller)
layout.Padding = UDim.new(0, 8)

local function log(txt, col)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, 0, 0, 0)
	t.AutomaticSize = Enum.AutomaticSize.Y
	t.Text = txt
	t.TextColor3 = col or Color3.new(1,1,1)
	t.BackgroundTransparency = 1
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextWrapped = true
	t.RichText = true
	t.Font = Enum.Font.Gotham
	t.Parent = scroller
	scroller.CanvasPosition = Vector2.new(0, 99999)
end

local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(1, -30, 0, 45)
inputFrame.Position = UDim2.new(0, 15, 1, -60)
inputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
inputFrame.Parent = win
Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 12)

local mediaBtn = Instance.new("TextButton")
mediaBtn.Size = UDim2.new(0, 35, 1, 0)
mediaBtn.Position = UDim2.new(0, 0, 0, 0)
mediaBtn.Text = "+"
mediaBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
mediaBtn.BackgroundTransparency = 1
mediaBtn.TextSize = 20
mediaBtn.Parent = inputFrame

local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -85, 1, 0)
box.Position = UDim2.new(0, 40, 0, 0)
box.BackgroundTransparency = 1
box.Text = ""
box.PlaceholderText = "Введите команду или ссылку на фото..."
box.TextColor3 = Color3.new(1,1,1)
box.TextXAlignment = Enum.TextXAlignment.Left
box.Parent = inputFrame

local send = Instance.new("TextButton")
send.Size = UDim2.new(0, 35, 0, 35)
send.Position = UDim2.new(1, -40, 0.5, -17)
send.BackgroundColor3 = Color3.fromRGB(80, 100, 255)
send.Text = "↑"
send.TextColor3 = Color3.new(1,1,1)
send.TextSize = 18
send.Parent = inputFrame
Instance.new("UICorner", send).CornerRadius = UDim.new(0, 10)

local open = Instance.new("TextButton")
open.Size = UDim2.new(0, 50, 0, 50)
open.Position = UDim2.new(0, 20, 0, 20)
open.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
open.Text = "✨"
open.Visible = false
open.Parent = sg
Instance.new("UICorner", open).CornerRadius = UDim.new(0, 12)

mini.MouseButton1Click:Connect(function() mainBg.Visible = false; open.Visible = true end)
open.MouseButton1Click:Connect(function() mainBg.Visible = true; open.Visible = false end)

local function ask(p)
	log("<b>Вы:</b> " .. p, Color3.fromRGB(180, 200, 255))
	local payload = { contents = {{ parts = {{ text = "You are a building AI. If user provides a link, analyze it. Write ONLY Luau code for: " .. p }} }} }
	local success, res = pcall(function()
		return HttpService:PostAsync(API_URL, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
	end)
	if success then
		local d = HttpService:JSONDecode(res)
		local c = d.candidates[1].content.parts[1].text
		local clean = c:gsub("
http://googleusercontent.com/immersive_entry_chip/1

Твой обновленный билд готов! Теперь он выглядит как настоящий профессиональный инструмент. Напиши, если хочешь добавить что-то еще.

