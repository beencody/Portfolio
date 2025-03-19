-- Services
local Players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local marketPlaceService = game:GetService("MarketplaceService")

local Player = Players.LocalPlayer
local steepleFolder = Player:FindFirstChild("Steeples")

-- Remote Events
local Remotes = replicatedStorage.Remotes

-- UI Elements
local indexBtn = script.Parent.index
local skipBtn = script.Parent.skip
local indexFrame = script.Parent.indexFrame
local scrollingFrame = indexFrame.ScrollingFrame
local percentageLabel = indexFrame.amt

-- Game Variables
local totalSteeples = 0
local currentTimer = 0

-- Display the label with the steeple names (developer/admin feature)
if Player.Name == "beencody" then
	script.Parent.label.Visible = true
end

-- Function to update the timer display
local function updateTimerDisplay(timeLeft)
	script.Parent.timerLabel.Text = tostring(timeLeft)
end

-- Function to sort steeples by difficulty
local function sortSteeplesByDifficulty(steeples)
	local difficultyOrder = {
		Easy = 1,
		Medium = 2,
		Hard = 3,
		Difficult = 4,
		Challenging = 5,
		Intense = 6,
		Remorseless = 7,
		Insane = 8
	}

	table.sort(steeples, function(a, b)
		return difficultyOrder[a.difficulty] < difficultyOrder[b.difficulty]
	end)
end

-- Function to update the percentage of guessed steeples
local function updatePercentage()
	if steepleFolder then
		local guessedSteeples = 0

		for _, steeple in pairs(steepleFolder:GetChildren()) do
			if steeple:IsA("IntValue") and steeple.Value > 0 then
				guessedSteeples += 1
			end
		end

		local percentage = (guessedSteeples / totalSteeples) * 100
		percentageLabel.Text = string.format("%.2f%%", percentage)
	end
end

-- Function to toggle the index frame
local function toggleIndexFrame()
	if indexFrame.Visible == false then
		indexFrame.Visible = true

		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local goal = {Position = UDim2.new(0.854, 0,0.669, 0)}

		local tween = tweenService:Create(indexFrame, tweenInfo, goal)
		tween:Play()
	else
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local goal = {Position = UDim2.new(1.854, 0,0.669, 0)}

		local tween = tweenService:Create(indexFrame, tweenInfo, goal)
		tween:Play()

		tween.Completed:Connect(function()
			indexFrame.Visible = false
		end)
	end	
end

indexBtn.MouseButton1Click:Connect(function()
	toggleIndexFrame()
end)

indexBtn.TouchTap:Connect(function()
	toggleIndexFrame()
end)

skipBtn.MouseButton1Click:Connect(function()
	Remotes.server:FireServer("SkipRound")
end)

Remotes.client.OnClientEvent:Connect(function(event, ...)
	local args = {...}

	if event == "StartRound" then
		-- Initialize round with given steeple details
		local initial, name, difficulty, timer = args[1], args[2], args[3], args[4]
		script.Parent.label.Text = name..", difficulty: "..difficulty
		
		for _, part in pairs(workspace.Zone.Steeple:FindFirstChildWhichIsA("Folder"):GetChildren()) do
			part.Anchored = true
			
			local origSize = part.Size			
			part.Size = Vector3.new(0, 0, 0)
			part.Transparency = 1
			
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local goal = {Size = origSize, Transparency = 0}

			local tween = tweenService:Create(part, tweenInfo, goal)
			tween:Play()
		end
		
	elseif event == "SkipRound" then
		-- Destroy all steeple parts after the round ends
		for _, part in pairs(workspace.Zone.Steeple:FindFirstChildWhichIsA("Folder"):GetChildren()) do
			if part:IsA("BasePart") then
				part.Anchored = false

				local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local goal = {Size = Vector3.new(0, 0, 0), Transparency = 1}

				local tween = tweenService:Create(part, tweenInfo, goal)
				tween:Play()
				tween.Completed:Connect(function()
					part:Destroy()
				end)
			end
		end	
	elseif event == "UpdateTimer" then
		-- Update countdown timer
		local timeLeft = args[1]
		currentTimer = timeLeft
		
		updateTimerDisplay(currentTimer)
	elseif event == "CorrectGuess" then
		-- Handles correct guess event
		updatePercentage()
		
		for _, part in pairs(workspace.Zone.Steeple:FindFirstChildWhichIsA("Folder"):GetChildren()) do
			part.Anchored = false
			
			local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local goal = {Size = Vector3.new(0, 0, 0), Transparency = 1}

			local tween = tweenService:Create(part, tweenInfo, goal)
			tween:Play()
			tween.Completed:Connect(function()
				part:Destroy()
			end)
		end
	elseif event == "EndRound" then
		-- Destroy all steeple parts after the round ends
		for _, part in pairs(workspace.Zone.Steeple:FindFirstChildWhichIsA("Folder"):GetChildren()) do
			if part:IsA("BasePart") then
				part.Anchored = false

				local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local goal = {Size = Vector3.new(0, 0, 0), Transparency = 1}

				local tween = tweenService:Create(part, tweenInfo, goal)
				tween:Play()
				tween.Completed:Connect(function()
					part:Destroy()
				end)
			end
		end	
	end
end)

Remotes.index.OnClientEvent:Connect(function(event, data)	
	if event == "AllSteeplesData" then
		sortSteeplesByDifficulty(data)
		
		totalSteeples = #data
		
		-- Creates the template and fills it with steeple details
		for _, steeple in ipairs(data) do			
			local template = script.prefab:Clone()
			template.Name = steeple.name
			template.initialLabel.Text = steeple.initial
			
			local difficultyColors = {
				Easy = Color3.fromRGB(0, 255, 0),
				Medium = Color3.fromRGB(255, 255, 0),
				Hard = Color3.fromRGB(255, 170, 0),
				Difficult = Color3.fromRGB(170, 0, 0),
				Challenging = Color3.fromRGB(97, 0, 0),
				Intense = Color3.fromRGB(45, 60, 70),
				Remorseless = Color3.fromRGB(123, 0, 123),
				Insane = Color3.fromRGB(0, 32, 96)
			}
			template.initialLabel.TextColor3 = difficultyColors[steeple.difficulty] or Color3.new(1, 1, 1)

			if steepleFolder:FindFirstChild(steeple.name) then
				template.caughtLabel.Text = tostring(steepleFolder:FindFirstChild(steeple.name).Value).." caught"
				
				steepleFolder:FindFirstChild(steeple.name).Changed:Connect(function()
					template.caughtLabel.Text = tostring(steepleFolder:FindFirstChild(steeple.name).Value).." caught"
				end)
			end
			
			template.Parent = scrollingFrame

			template.MouseEnter:Connect(function()
				template.initialLabel.Text = steeple.name
			end)
			template.MouseLeave:Connect(function()
				template.initialLabel.Text = steeple.initial
			end)
		end
		
		updatePercentage()
	end
end)
