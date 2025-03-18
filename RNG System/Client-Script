local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local AnimationModule = require(script:WaitForChild("AnimationModule"))
local CameraShaker = require(Modules:WaitForChild("CameraShaker"))
local rolledNumber = Remotes.RollFunction:InvokeServer()

local Camera = workspace.Camera

local ScreenUI = script.Parent
local Bottom = ScreenUI:WaitForChild("Bottom")
local Button = Bottom.List.Button
local AcceptButton = ScreenUI.Accept
local SkipButton = ScreenUI.Skip
local QuickRollButton = Bottom.List.QuickRollButton
local AutoRollButton = Bottom.List.AutoRollButton

local StarUI = script.Parent.Parent.SpecialEffect
local StarBackground = StarUI.Background
local Star = StarUI.Star

local ZOOMED_FOV = 45
local NORMAL_FOV = 75

local debounce = false
local quickRoll = false
local autoRoll = false

local function showSpecialEffect()
	StarBackground.Visible = true
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shake)
		Camera.CFrame = Camera.CFrame * shake
	end)

	Star.Visible = true
	TweenService:Create(Star, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 1600, ImageTransparency = 0}):Play()

	task.wait(3)
	camShake:Start()
	camShake:Shake(CameraShaker.Presets.Explosion)

	Star.Visible = false
	StarBackground.Visible = false    
	Star.Rotation = 0
	Star.ImageTransparency = 1
end

Button.MouseButton1Click:Connect(function()
	if debounce then return end
	debounce = true

	TweenService:Create(Camera, TweenInfo.new(.2), {FieldOfView = ZOOMED_FOV}):Play()
	SkipButton.Visible, AcceptButton.Visible = false, false

	
	AnimationModule.rollAnimation(ScreenUI.Animations, rolledNumber)
	AnimationModule.rollButtonAnimation(Button)

	if player.QuickRoll.Value then
		if rolledNumber[3][2] >= 16 then showSpecialEffect() end
	else
		if rolledNumber[7][2] >= 16 then showSpecialEffect() end
	end

	QuickRollButton.Visible, Button.Visible = false, false
	SkipButton.Visible, AcceptButton.Visible = true, true
end)

QuickRollButton.MouseButton1Click:Connect(function()
	if player.AutoRoll.Value then return end

	quickRoll = not quickRoll
	Remotes.QuickRoll:FireServer(quickRoll)
	QuickRollButton.TextLabel.Text = "Quick Roll: " .. (quickRoll and "ON" or "OFF")
end)

AcceptButton.MouseButton1Click:Connect(function()
	for _, v in pairs(player.Inventory.OwnedChances:GetChildren()) do
		if v.Name == (player.QuickRoll.Value and rolledNumber[3][1] or rolledNumber[7][1]) then
			Remotes.UpdateServerInventory:FireServer("Accept", v)
		end
	end

	SkipButton.Visible, AcceptButton.Visible = false, false
	ScreenUI.Animations.Background.Visible, ScreenUI.Animations.Title.Visible = false, false
	TweenService:Create(Camera, TweenInfo.new(.2), {FieldOfView = NORMAL_FOV}):Play()
	QuickRollButton.Visible, Button.Visible, debounce = true, true, false
end)

SkipButton.MouseButton1Click:Connect(function()
	for _, v in pairs(player.Inventory:GetChildren()) do
		if v.Name == (player.QuickRoll.Value and rolledNumber[2][1] or rolledNumber[7][1]) then
			Remotes.UpdateServerInventory:FireServer("Skip", v)
		end
	end

	SkipButton.Visible, AcceptButton.Visible = false, false
	ScreenUI.Animations.Background.Visible, ScreenUI.Animations.Title.Visible = false, false
	TweenService:Create(Camera, TweenInfo.new(.2), {FieldOfView = NORMAL_FOV}):Play()
	QuickRollButton.Visible, Button.Visible, debounce = true, true, false
end)

AutoRollButton.MouseButton1Click:Connect(function()
	if player.QuickRoll.Value then return end

	autoRoll = not autoRoll
	quickRoll = false

	Remotes.AutoRoll:FireServer(autoRoll)
	AutoRollButton.TextLabel.Text = "Auto Roll: " .. (autoRoll and "ON" or "OFF")

	if autoRoll then
		repeat
			task.wait(1.5)
			if debounce then continue end
			debounce = true

			TweenService:Create(Camera, TweenInfo.new(.2), {FieldOfView = ZOOMED_FOV}):Play()
			AcceptButton.Visible, SkipButton.Visible = false, false

			local rolledNumber = Remotes.RollFunction:InvokeServer()
			AnimationModule.rollButtonAnimation(Button)
			AnimationModule.rollAnimation(ScreenUI.Animations, rolledNumber)

			if rolledNumber and rolledNumber[3][2] >= 16 then showSpecialEffect() end

			QuickRollButton.Visible, AutoRollButton.Visible, Button.Visible = false, false, false
			SkipButton.Visible, AcceptButton.Visible = true, true
			debounce = false
		until not autoRoll
	end
end)

player.AutoRoll:GetPropertyChangedSignal("Value"):Connect(function()
	AutoRollButton.TextLabel.Text = "Auto Roll: " .. (player.AutoRoll.Value and "ON" or "OFF")
end)

player.QuickRoll:GetPropertyChangedSignal("Value"):Connect(function()
	QuickRollButton.TextLabel.Text = "Quick Roll: " .. (player.QuickRoll.Value and "ON" or "OFF")
end)

Remotes.ServerMessage.OnClientEvent:Connect(function(message)
	TextChatService.TextChannel.RBXGeneral:DisplaySystemMessage(message)
end)
