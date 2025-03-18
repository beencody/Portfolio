local TweenService = game:GetService("TweenService")
local TweenInfo1 = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local TweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function animateText(titleLabel, rarityLabel, rolledNumber)
	titleLabel.Position = UDim2.fromScale(0.5, 0.35)
	titleLabel.TextColor3 = rolledNumber[3]
	titleLabel.Text = rolledNumber[1]
	titleLabel.FontFace = rolledNumber[4]
	rarityLabel.Text = `1 in {rolledNumber[2]} Chance`

	TweenService:Create(titleLabel, TweenInfo1, { Position = UDim2.fromScale(0.5, 0.5) }):Play()
	task.wait(0.2)
end

return {
	rollAnimation = function(animationFolder: Folder, rolledNumbers)
		local background = animationFolder:WaitForChild("Background")
		local title = animationFolder:WaitForChild("Title")
		local rarity = title:WaitForChild("Rarity")

		background.Visible = true
		title.Visible = true

		for _, rolledNumber in ipairs(rolledNumbers) do
			animateText(title, rarity, rolledNumber)
		end
	end,

	rollButtonAnimation = function(textButton)
		local animationFrame = textButton.AnimationFrame
		animationFrame.Size = UDim2.fromScale(1, 1)

		TweenService:Create(animationFrame, TweenInfo2, { Size = UDim2.new(0, 0, 1, 0) }):Play()
	end,
}
