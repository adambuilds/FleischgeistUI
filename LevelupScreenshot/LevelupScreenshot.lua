LevelupScreenshot = {}
LevelupScreenshot.requested = false
LevelupScreenshot.Frame = CreateFrame("Frame")

LevelupScreenshot.Frame:SetScript("OnEvent", function(self, event, ...)
	LevelupScreenshot.OnEvent(event, ...)
end)

LevelupScreenshot.Frame:RegisterEvent("PLAYER_LEVEL_UP")
LevelupScreenshot.Frame:RegisterEvent("TIME_PLAYED_MSG")

function LevelupScreenshot.OnEvent(event, ...)
	if event == "PLAYER_LEVEL_UP" then
		LevelupScreenshot.requested = true
		print("Leveled up, requesting time played...")
		RequestTimePlayed()
	elseif event == "TIME_PLAYED_MSG" then
		if LevelupScreenshot.requested then
			LevelupScreenshot.requested = false
			-- Wait 2 seconds for the 'ding' visual to wear off, and to give /played some time to print
			C_Timer.After(2, function()
				Screenshot()
			end)
		end
	end
end
