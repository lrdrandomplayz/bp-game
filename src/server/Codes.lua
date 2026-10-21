--[[
	Codes
	Redeemable codes. Server only: keep this in ServerScriptService or ServerStorage,
	never ReplicatedStorage, or exploiters can read codes you haven't released yet.

	Keys are the code in uppercase with no spaces. Players can type any case.
	Reward keys allowed: SkipRestCredits, ScarRepairTokens.
	Each code works once per player. StoryData.RedeemCode checks and applies them.
]]

return {
	SKIPREST = {
		Reward = { SkipRestCredits = 1 },
		Message = "Free Skip Rest added. Tap the Energy bar to use it.",
		Enabled = true,
	},

	-- Template for a limited code. ExpiresAt is Unix time (os.time()).
	-- RUNWAY2026 = {
	-- 	Reward = { ScarRepairTokens = 1 },
	-- 	Message = "Free Scar Repair added.",
	-- 	Enabled = true,
	-- 	ExpiresAt = 1798761600,
	-- },
}
