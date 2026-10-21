--[[
	StoryData
	All story text, stats, bosses, and endings for the Avatarmaxxing game.
	Plain Lua 5.1 syntax so the module loads in Roblox (Luau) and in standard Lua for tests.

	Usage (Roblox):
		local StoryData = require(game.ReplicatedStorage.Shared.StoryData)
		local endingId, info = StoryData.ResolveEnding("Sub5", playerStats, playerFlags)
		local ending = StoryData.Endings[endingId]
]]

local StoryData = {}

-- Chance the Sub 5 Noob survives the shortcut and still gets to Rebirth.
StoryData.SHORTCUT_REBIRTH_CHANCE = 0.03

-- Friends needed for the Top Blox bonus ending.
StoryData.REAL_FRIENDS_THRESHOLD = 50

StoryData.STAT_MAX = 100

---------------------------------------------------------------------------
-- Glossary: player-facing terms
---------------------------------------------------------------------------

StoryData.Glossary = {
	Avatarmaxxing = "Leveling your avatar's stats to Rebirth into a higher tier.",
	LTR = "Low Tier Robloxian.",
	MTR = "Mid Tier Robloxian.",
	HTR = "High Tier Robloxian.",
	Sub5Noob = "Sub 5 Noob. The bottom of the scale.",
	TopBloxLite = "Top Blox Lite. One step under the top.",
	TopBlox = "Top Blox. The top of the scale.",
	Bloxpill = "The belief that only your avatar's looks decide everything.",
	BloxpillEdit = "A short video edit pushing the Bloxpill.",
	Rebirth = "Moving up a tier for good.",
	Outshine = "Looking better than someone standing next to you.",
	HunterEyes = "Sharp, deep set eyes. Top Blox are born with them.",
	BrickSmash = "A forum shortcut for your face. A trap.",
	MysteryJuice = "A forum shortcut for your frame. A trap.",
	HyperScale = "The force that sends all the Clout to the top tier.",
	Rizz = "Your ability to talk to people and get noticed.",
	Clout = "Attention from the server.",
}

---------------------------------------------------------------------------
-- Stats
---------------------------------------------------------------------------

StoryData.Stats = {
	Studs = { DisplayName = "Studs", Description = "Height." },
	Hitbox = { DisplayName = "Hitbox", Description = "Shoulder and clavicle width." },
	AvatarRating = { DisplayName = "Avatar Rating", Description = "Looks." },
	Friends = { DisplayName = "Friends", Description = "People who like you for you." },
}

StoryData.FightStats = { "Studs", "Hitbox", "AvatarRating" }

-- Tier by average fight stat, checked top down.
StoryData.Tiers = {
	{ Id = "TopBlox", DisplayName = "Top Blox", MinAverage = 85 },
	{ Id = "TopBloxLite", DisplayName = "Top Blox Lite", MinAverage = 75 },
	{ Id = "HTR", DisplayName = "HTR", MinAverage = 65 },
	{ Id = "MTR", DisplayName = "MTR", MinAverage = 50 },
	{ Id = "LTR", DisplayName = "LTR", MinAverage = 30 },
	{ Id = "Sub5Noob", DisplayName = "Sub 5 Noob", MinAverage = 0 },
}

---------------------------------------------------------------------------
-- Storylines
---------------------------------------------------------------------------

StoryData.Lines = {
	LTR = {
		DisplayName = "LTR Line",
		Difficulty = "Normal",
		StartingStats = { Studs = 40, Hitbox = 35, AvatarRating = 40, Friends = 30 },
		Intro = {
			"You grew up as an LTR.",
			"You never got any rizz during school.",
			"You slowly accepted it.",
			"Each day it bothered you more.",
			"One night you were doomscrolling in bed and saw a Bloxpill edit.",
			"You learned the whole Bloxpill in one night.",
			"You tried to deny your avatar was the reason you got no rizz.",
			"Then you kept seeing Top Blox get all the Clout.",
			"You knew you had to Rebirth and end this.",
		},
		Choices = {
			{
				Prompt = "The Bloxpill edit ends. What now?",
				Options = {
					{ Text = "Start avatarmaxxing tomorrow.", Next = "Grind" },
					{ Text = "Close the app and sleep.", Next = "Grind", Stat = { Studs = 2 } },
				},
			},
		},
	},

	Sub5 = {
		DisplayName = "Sub 5 Noob Line",
		Difficulty = "Hard",
		StartingStats = { Studs = 25, Hitbox = 20, AvatarRating = 15, Friends = 10 },
		Intro = {
			"You have been a Sub 5 Noob your whole life.",
			"People bullied you for your avatar.",
			"Every time a girl showed you the smallest kindness, you fell for her.",
			"Soon you realized it meant nothing.",
			"You started searching for a cure.",
			"While searching, you found the Bloxpill forums.",
			"They told you only looks matter, all the time.",
			"They said your bone structure is cooked.",
			"They said the only way out is Brick Smash and Mystery Juice.",
			"You step onto the path to fight this unfair server.",
		},
		Choices = {
			{
				Prompt = "The forums link you to Brick Smash and Mystery Juice. What do you do?",
				Options = {
					{ Text = "Take the shortcut. Brick Smash.", Next = "Grind", Action = "BrickSmash" },
					{ Text = "Take the shortcut. Mystery Juice.", Next = "Grind", Action = "MysteryJuice" },
					{ Text = "Close the forums. Grind the slow way.", Next = "Grind" },
				},
			},
		},
	},

	TopBlox = {
		DisplayName = "Top Blox Line",
		Difficulty = "Story",
		StartingStats = { Studs = 75, Hitbox = 70, AvatarRating = 85, Friends = 0 },
		Intro = {
			"He was born with Hunter Eyes.",
			"He has been a model since he was a kid.",
			"He always gets what he wants.",
			"He has no friends.",
			"He never had a real childhood.",
			"People only used him for modeling.",
			"One day he decides to meet a girl.",
			"He says a normal thing. Not even a joke.",
			"She laughs.",
			"Now he knows HyperScale rules everyone, even the ones at the top.",
			"He walks into the boss realm to face his old modeling rivals.",
		},
		Choices = {
			{
				Prompt = "Before the fight, someone from your old school says hi.",
				Options = {
					{ Text = "Talk to them.", Next = "Grind", Stat = { Friends = 10 } },
					{ Text = "Ignore them. Focus on the fight.", Next = "Grind" },
				},
			},
		},
	},
}

StoryData.LineOrder = { "LTR", "Sub5", "TopBlox" }

---------------------------------------------------------------------------
-- Grind actions
---------------------------------------------------------------------------

StoryData.GrindActions = {
	Sleep = { DisplayName = "Sleep 9 Hours", Stat = { Studs = 2 } },
	Posture = { DisplayName = "Fix Posture", Stat = { Studs = 1 } },
	Gym = { DisplayName = "Gym", Stat = { Hitbox = 3 } },
	Skincare = { DisplayName = "Skincare", Stat = { AvatarRating = 2 } },
	Haircut = { DisplayName = "New Haircut", Stat = { AvatarRating = 3 } },
	Style = { DisplayName = "New Fit", Stat = { AvatarRating = 2 } },
	HangOut = { DisplayName = "Hang Out", Stat = { Friends = 5 } },

	-- Traps. Only offered on the Sub 5 Noob line.
	BrickSmash = {
		DisplayName = "Brick Smash",
		Stat = { AvatarRating = 25 },
		Trap = true,
		Flag = "BrickSmash",
		Lines = { Sub5 = true },
	},
	MysteryJuice = {
		DisplayName = "Mystery Juice",
		Stat = { Hitbox = 25 },
		Trap = true,
		Flag = "MysteryJuice",
		Lines = { Sub5 = true },
	},
}

---------------------------------------------------------------------------
-- Bosses, fought in order
---------------------------------------------------------------------------

StoryData.Bosses = {
	ShawnOPixel = {
		DisplayName = "Shawn O'Pixel",
		Title = "The Face of Every Ad",
		Requirements = { Studs = 60, Hitbox = 55, AvatarRating = 70 },
		Intro = "Shawn O'Pixel steps out of a billboard. \"You think you can Outshine me?\"",
	},
	JordanBloxett = {
		DisplayName = "Jordan Bloxett",
		Title = "The Runway King",
		Requirements = { Studs = 70, Hitbox = 65, AvatarRating = 80 },
		Intro = "Jordan Bloxett walks the runway toward you. The crowd goes silent.",
	},
	HyperScale = {
		DisplayName = "HyperScale",
		Title = "The Scale Itself",
		Requirements = { Studs = 80, Hitbox = 75, AvatarRating = 85 },
		Intro = "A giant scale rises from the floor. Every bit of Clout in the server sits on one side.",
	},
}

StoryData.BossOrder = { "ShawnOPixel", "JordanBloxett", "HyperScale" }

---------------------------------------------------------------------------
-- Endings
---------------------------------------------------------------------------

local survivors = math.floor(StoryData.SHORTCUT_REBIRTH_CHANCE * 100 + 0.5)

StoryData.Endings = {
	ScaleTipsBack = {
		Title = "The Scale Tips Back",
		Kind = "True",
		Text = {
			"Shawn O'Pixel falls. Jordan Bloxett falls.",
			"You face HyperScale and push.",
			"The scale tips back to normal.",
			"HyperScale stops existing.",
			"Clout spreads across the whole server. Everyone gets noticed.",
		},
	},
	RealFriends = {
		Title = "Real Friends",
		Kind = "Bonus",
		Text = {
			"HyperScale breaks, and the scale tips back to normal.",
			"For once nobody wants a photo.",
			"Your friends want to grab food.",
			"You finally get the childhood you missed.",
		},
	},
	LuckyRebirth = {
		Title = "Lucky Rebirth",
		Kind = "Rare",
		Text = {
			"You took the shortcut and somehow made it.",
			"You Rebirth and beat HyperScale.",
			"The scale tips back to normal.",
			string.format("Out of every 100 Noobs who took the shortcut, %d crashed. You were one of the %d.", 100 - survivors, survivors),
		},
	},
	BrickSmashed = {
		Title = "Brick Smashed",
		Kind = "Bad",
		Text = {
			"Your Avatar Rating spiked, then crashed at the boss gate.",
			"HyperScale laughs. The shortcut was part of its plan.",
			"HyperScale wins.",
		},
	},
	JuiceCrash = {
		Title = "Juice Crash",
		Kind = "Bad",
		Text = {
			"Your Hitbox spiked, then crashed mid fight.",
			"HyperScale tips further to the top.",
			"HyperScale wins.",
		},
	},
	NotEnoughStuds = {
		Title = "Not Enough Studs",
		Kind = "Lose",
		Text = {
			"Your stats were not high enough.",
			"Grind more and come back.",
		},
		Retry = true,
	},
}

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

function StoryData.NewStats(lineId)
	local line = StoryData.Lines[lineId]
	assert(line, "Unknown line: " .. tostring(lineId))
	local stats = {}
	for statId in pairs(StoryData.Stats) do
		stats[statId] = line.StartingStats[statId] or 0
	end
	return stats
end

function StoryData.ApplyAction(lineId, stats, flags, actionId)
	local action = StoryData.GrindActions[actionId]
	assert(action, "Unknown action: " .. tostring(actionId))
	if action.Lines and not action.Lines[lineId] then
		return false
	end
	for statId, amount in pairs(action.Stat) do
		stats[statId] = math.min((stats[statId] or 0) + amount, StoryData.STAT_MAX)
	end
	if action.Flag then
		flags[action.Flag] = true
	end
	return true
end

function StoryData.GetTier(stats)
	local total = 0
	for _, statId in ipairs(StoryData.FightStats) do
		total = total + (stats[statId] or 0)
	end
	local average = total / #StoryData.FightStats
	for _, tier in ipairs(StoryData.Tiers) do
		if average >= tier.MinAverage then
			return tier
		end
	end
end

-- Returns true, or false plus the first stat that fell short.
function StoryData.CanBeatBoss(stats, bossId)
	local boss = StoryData.Bosses[bossId]
	assert(boss, "Unknown boss: " .. tostring(bossId))
	for _, statId in ipairs(StoryData.FightStats) do
		if (stats[statId] or 0) < boss.Requirements[statId] then
			return false, statId
		end
	end
	return true
end

local function fightAll(stats)
	for _, bossId in ipairs(StoryData.BossOrder) do
		local won, missingStat = StoryData.CanBeatBoss(stats, bossId)
		if not won then
			return false, bossId, missingStat
		end
	end
	return true
end

-- rng is optional and returns a number in [0, 1). Defaults to math.random.
-- Returns the ending id and a table with details for the UI.
function StoryData.ResolveEnding(lineId, stats, flags, rng)
	flags = flags or {}
	rng = rng or math.random

	if flags.BrickSmash or flags.MysteryJuice then
		local lucky = lineId == "Sub5" and rng() < StoryData.SHORTCUT_REBIRTH_CHANCE
		if not lucky then
			return flags.BrickSmash and "BrickSmashed" or "JuiceCrash", {}
		end
		local won, bossId, missingStat = fightAll(stats)
		if not won then
			return "NotEnoughStuds", { LostTo = bossId, MissingStat = missingStat }
		end
		return "LuckyRebirth", {}
	end

	local won, bossId, missingStat = fightAll(stats)
	if not won then
		return "NotEnoughStuds", { LostTo = bossId, MissingStat = missingStat }
	end
	if lineId == "TopBlox" and (stats.Friends or 0) >= StoryData.REAL_FRIENDS_THRESHOLD then
		return "RealFriends", {}
	end
	return "ScaleTipsBack", {}
end

return StoryData
