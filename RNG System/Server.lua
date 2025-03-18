local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local SelectChance = require(Modules.SelectChance)
local ChanceList = require(Modules.ChanceList)

local Auras = ReplicatedStorage:WaitForChild("Auras")

Remotes.RollFunction.OnServerInvoke = function(player)
	local rollResults = {}
	local rollCount = player.QuickRoll.Value and 3 or 7

	for _ = 1, rollCount do
		table.insert(rollResults, SelectChance.getRandomIndex(ChanceList))
	end

	local lastRoll = rollResults[rollCount]
	if lastRoll[2] >= 1 then
		-- send server message == "[SERVER:] " .. player.Name .. " rolled a 1 in " .. lastRoll[2] .. " Chance", " [" .. lastRoll[1] .. "]", lastRoll[5]))
	end

	player.leaderstats.Rolls.Value += 1
	return rollResults
end

Remotes.QuickRoll.OnServerEvent:Connect(function(player, value)
	player.QuickRoll.Value = value
end)

Remotes.AutoRoll.OnServerEvent:Connect(function(player, value)
	player.AutoRoll.Value = value
end)

Remotes.UpdateServerInventory.OnServerEvent:Connect(function(player, event, label)
	for _, chance in pairs(player.Inventory.OwnedChances:GetChildren()) do
		if chance.Name == label.Name then
			chance.Value = true
			return
		end
	end
end)
