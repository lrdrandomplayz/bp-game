--[[
	StoryData
	All story text, stats, chapters, characters, bosses, and endings for the Avatarmaxxing game.
	Plain Lua 5.1 syntax so the module loads in Roblox (Luau) and in standard Lua for tests.

	Usage (Roblox):
		local StoryData = require(game.ReplicatedStorage.Shared.StoryData)
		local run = StoryData.NewRun("Sub5")
		StoryData.ApplyChoice(run, 1, 2)
		StoryData.ApplyAction(run, "Sleep")                -- softmaxx
		StoryData.ApplyHardmaxx(run, "MeshSwap")           -- hardmaxx, chapter 3 on
		local won, missingStat = StoryData.ChallengeGate(run)
		-- once run.Chapter is 5 (the Boss Realm):
		local endingId, info = StoryData.ResolveEnding(run)
		local ending = StoryData.Endings[endingId]
]]

local StoryData = {}

-- Chance the Sub 5 Noob survives the shortcut and still gets to Rebirth.
StoryData.SHORTCUT_REBIRTH_CHANCE = 0.03

-- Friends needed for the Top Blox bonus ending.
StoryData.REAL_FRIENDS_THRESHOLD = 50

StoryData.STAT_MAX = 100

-- Softmaxxing: the most each fight stat can gain from grind actions over a run.
StoryData.SOFT_CAP = 20

-- Hardmaxxing: the most each fight stat can gain from the Slider Clinic, before scars.
StoryData.HARD_CAP = 50

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
	Mewing = "Holding good tongue posture for a sharper jaw.",
	BrickSmash = "A forum shortcut for your face. A trap.",
	MysteryJuice = "A forum shortcut for your frame. A trap.",
	HyperScale = "The force that sends all the Clout to the top tier.",
	Rizz = "Your ability to talk to people and get noticed.",
	Clout = "Attention from the server.",
	BLOXED = "The avatarmaxxing product brand sold at the BLOXED Store.",
	CoachKShamblox = "Avatarmaxxing YouTuber who teaches the legit routine.",
	Softmaxxing = "Slow, reliable grinding: sleep, skincare, gym, style. Capped at +20 per stat.",
	Hardmaxxing = "Fast, risky Slider Clinic procedures. Up to +50 per stat. Can glitch you for good.",
	SliderClinic = "Dr. Polygon's clinic. Height Slider, Width Slider, Mesh Swap.",
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

-- Fixed check order, so the "missing stat" a fight reports is stable.
StoryData.StatOrder = { "Studs", "Hitbox", "AvatarRating", "Friends" }
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
-- Characters. Scene speakers point at these ids.
---------------------------------------------------------------------------

StoryData.Characters = {
	Narrator = { DisplayName = "", Role = "Story narration." },
	You = { DisplayName = "You", Role = "The player." },

	Coach = { DisplayName = "Coach K Shamblox", Role = "Avatarmaxxing YouTuber. Calm voice, no doom. Teaches the legit routine.", Lines = "All" },
	Clerk = { DisplayName = "BLOXED Store Clerk", Role = "Runs the BLOXED Store. Knows every product by heart.", Lines = "All" },
	Polygon = { DisplayName = "Dr. Polygon", Role = "Runs the Slider Clinic. Fast results. No guarantees.", Lines = "All" },
	BrickPilled99 = { DisplayName = "BrickPilled99", Role = "Bloxpill forum mod. 40,000 posts, zero progress pics.", Lines = "LTR, Sub5" },

	Milo = { DisplayName = "Milo", Role = "Your best friend since second grade. Also an LTR.", Lines = "LTR" },
	Ava = { DisplayName = "Ava", Role = "Classmate. Borrowed your pencil once.", Lines = "LTR" },
	Larry = { DisplayName = "Lunch Table Larry", Role = "Runs the popular lunch table.", Lines = "LTR" },
	Tyler = { DisplayName = "Tyler", Role = "Top Blox Lite. Captain of everything. Hates competition.", Lines = "LTR" },

	Nana = { DisplayName = "Nana", Role = "Your grandma. Thinks you are the most handsome boy alive.", Lines = "Sub5" },
	Kai = { DisplayName = "Kai", Role = "A Noob who took the shortcut and crashed. Now grinds the slow way.", Lines = "Sub5" },
	Dre = { DisplayName = "Dre", Role = "Gym regular. 40, built like a vending machine, nicest guy there.", Lines = "Sub5" },
	Brock = { DisplayName = "Brock", Role = "The hallway bully.", Lines = "Sub5" },
	Salesman = { DisplayName = "The Shortcut Salesman", Role = "Long coat. Sells Mystery Juice at the bus stop.", Lines = "Sub5" },

	Vera = { DisplayName = "Vera", Role = "Your agent since you were in diapers.", Lines = "TopBlox" },
	Jamie = { DisplayName = "Jamie", Role = "The only kid who asked you to play. Still asks.", Lines = "TopBlox" },
	Lena = { DisplayName = "Lena", Role = "Works at the coffee shop near the studio. The girl who laughed.", Lines = "TopBlox" },
	Dax = { DisplayName = "Dax Velour", Role = "Your old runway rival. The agency's new face.", Lines = "TopBlox" },
}

---------------------------------------------------------------------------
-- Grind actions
---------------------------------------------------------------------------

StoryData.GrindActions = {
	-- Softmaxxing: small, reliable gains. Fight stats stop at SOFT_CAP.
	Sleep = { DisplayName = "Sleep 9 Hours", Stat = { Studs = 1 } },
	Posture = { DisplayName = "Fix Posture", Stat = { Studs = 1 } },
	Stretch = { DisplayName = "Stretch", Stat = { Studs = 1 } },
	Gym = { DisplayName = "Gym", Stat = { Hitbox = 2 } },
	Skincare = { DisplayName = "Skincare", Stat = { AvatarRating = 1 } },
	Haircut = { DisplayName = "New Haircut", Stat = { AvatarRating = 2 } },
	Style = { DisplayName = "New Fit", Stat = { AvatarRating = 1 } },
	Mewing = { DisplayName = "Mewing", Stat = { AvatarRating = 1 } },
	DrinkWater = { DisplayName = "Drink Water", Stat = { AvatarRating = 1 } },
	HangOut = { DisplayName = "Hang Out", Stat = { Friends = 5 } },

	-- Traps. Never unlocked for grinding. Only story choices on the Sub 5 Noob line trigger them.
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
-- Hardmaxxing: Dr. Polygon's Slider Clinic. Unlocks in chapter 3.
-- Each visit is one action and one roll. Gains stop at the stat's hardmaxx cap.
---------------------------------------------------------------------------

StoryData.Procedures = {
	HeightSlider = { DisplayName = "Height Slider", Stat = "Studs" },
	WidthSlider = { DisplayName = "Width Slider", Stat = "Hitbox" },
	MeshSwap = { DisplayName = "Mesh Swap", Stat = "AvatarRating" },
}

StoryData.ProcedureOrder = { "HeightSlider", "WidthSlider", "MeshSwap" }

-- Checked in order. Chances add up to 1.
StoryData.HardmaxxOutcomes = {
	{ Id = "Jackpot", Chance = 0.30, Gain = 15, Text = "The slider locks in perfectly. Huge gain." },
	{ Id = "Clean", Chance = 0.35, Gain = 10, Text = "Clean result. Solid gain." },
	{ Id = "Flop", Chance = 0.25, Gain = 0, Text = "Nothing changed. Dr. Polygon shrugs." },
	{ Id = "Glitch", Chance = 0.10, Gain = -5, Scar = 10, Text = "The mesh glitches. You lose 5, and this stat's hardmaxx cap drops by 10 for good." },
}

---------------------------------------------------------------------------
-- BLOXED items. Gate rewards. Bonus adds to an action's stat gain.
---------------------------------------------------------------------------

StoryData.Items = {
	SleepMask = { DisplayName = "BLOXED Sleep Mask", Bonus = { Sleep = 1 }, Description = "+1 Studs on Sleep 9 Hours." },
	Protein = { DisplayName = "BLOXED Protein", Bonus = { Gym = 1 }, Description = "+1 Hitbox on Gym." },
	FaceWash = { DisplayName = "BLOXED Face Wash", Bonus = { Skincare = 1 }, Description = "+1 Avatar Rating on Skincare." },
	HairClay = { DisplayName = "BLOXED Hair Clay", Bonus = { Haircut = 1, Style = 1 }, Description = "+1 Avatar Rating on New Haircut and New Fit." },
	Crown = { DisplayName = "BLOXED Crown", Bonus = {}, Description = "Cosmetic. Proof you made it to the Boss Realm." },
}

---------------------------------------------------------------------------
-- Mini bosses. Gates at the end of chapters 1 to 4. Losing means grind and retry.
---------------------------------------------------------------------------

StoryData.MiniBosses = {
	-- LTR
	LunchTableLarry = {
		DisplayName = "Lunch Table Larry",
		Requirements = { Studs = 42, AvatarRating = 44, Friends = 35 },
		Intro = "Larry stands up. \"Prove you belong at this table.\"",
		WinText = "Larry shrugs. \"Okay. You're not that bad.\" Milo grins at you.",
		LoseText = "Larry laughs. The whole table laughs with him.",
	},
	MirrorYouLTR = {
		DisplayName = "Mirror You",
		Requirements = { Hitbox = 45, AvatarRating = 52, Friends = 45 },
		Intro = "Your reflection stares back. \"You really think this will work?\"",
		WinText = "Your reflection nods. For the first time, you believe it.",
		LoseText = "Your reflection shakes its head. You turn off the light.",
	},
	BrickPilled99LTR = {
		DisplayName = "Forum Mod BrickPilled99",
		Requirements = { Studs = 55, Hitbox = 55, AvatarRating = 62 },
		Intro = "BrickPilled99 logs in. \"Prove it's not over.\"",
		WinText = "You post your day 60 pic. BrickPilled99 bans you for spreading hope.",
		LoseText = "The replies pile up. You log off.",
	},
	TylerRumble = {
		DisplayName = "Tyler, Top Blox Lite",
		Requirements = { Studs = 64, Hitbox = 62, AvatarRating = 74 },
		Intro = "Tyler steps into the ring. \"Let's see that Rebirth.\"",
		WinText = "Tyler stares for a long second. \"Respect.\" He holds out a hand.",
		LoseText = "Tyler Outshines you. The crowd cheers for him.",
	},

	-- Sub 5 Noob
	HallwayBully = {
		DisplayName = "Brock the Hallway Bully",
		Requirements = { Studs = 30, AvatarRating = 24, Friends = 15 },
		Intro = "Brock shoves your shoulder. \"You gonna do something?\"",
		WinText = "You don't flinch. Brock walks off. The whole hallway saw it.",
		LoseText = "You hit the lockers. Someone records it.",
	},
	BrickPilled99Sub5 = {
		DisplayName = "Forum Mod BrickPilled99",
		Requirements = { Hitbox = 30, AvatarRating = 30 },
		Intro = "BrickPilled99 tags you in a thread. \"this noob thinks he can grind out of sub 5 lmao\"",
		WinText = "You post your first week of progress. Nobody can call it fake.",
		LoseText = "You read every reply. You don't sleep.",
	},
	MirrorYouSub5 = {
		DisplayName = "Mirror You",
		Requirements = { Studs = 45, Hitbox = 45, AvatarRating = 50, Friends = 30 },
		Intro = "Your reflection talks in BrickPilled99's voice. \"still sub 5. always sub 5.\"",
		WinText = "Your reflection blinks. Then it smiles back.",
		LoseText = "You look away first.",
	},
	ShortcutSalesman = {
		DisplayName = "The Shortcut Salesman",
		Requirements = { Studs = 58, Hitbox = 55, AvatarRating = 66 },
		Intro = "The Salesman blocks your path. \"Nobody grinds their way out. Prove me wrong.\"",
		WinText = "The Salesman looks you up and down, then walks off to find someone else.",
		LoseText = "\"See? You need me.\" He slips a card into your pocket.",
	},

	-- Top Blox
	PaparazziSwarm = {
		DisplayName = "Paparazzi Swarm",
		Requirements = { Studs = 77, AvatarRating = 87 },
		Intro = "Flashbulbs everywhere. \"Look here! Give us the Hunter Eyes!\"",
		WinText = "You walk through the flashes without missing a step.",
		LoseText = "You trip on a cable. It's on every feed by dinner.",
	},
	AgencyBossVera = {
		DisplayName = "Agency Boss Vera",
		Requirements = { Hitbox = 73, Friends = 15 },
		Intro = "Vera slams the contract on the table. \"You walk out, you lose everything.\"",
		WinText = "You put the pen down. \"Then I lose everything.\" Vera goes quiet for the first time.",
		LoseText = "You sign. Again.",
	},
	MirrorYouLonely = {
		DisplayName = "Mirror You (Lonely)",
		Requirements = { AvatarRating = 88, Friends = 35 },
		Intro = "Your reflection poses like a billboard. \"Without the cameras, who are you?\"",
		WinText = "Your reflection drops the pose. You both laugh.",
		LoseText = "You pose back out of habit. The room feels huge.",
	},
	DaxVelour = {
		DisplayName = "Dax Velour, Old Rival Model",
		Requirements = { Studs = 80, Hitbox = 75, AvatarRating = 88 },
		Intro = "Dax hits the runway first. Flawless. \"Your turn.\"",
		WinText = "You walk. The crowd forgets Dax is there.",
		LoseText = "Dax Outshines you. The crowd chants his name.",
	},
}

---------------------------------------------------------------------------
-- Storylines: 5 chapters each
---------------------------------------------------------------------------

local function say(speaker, text)
	return { Speaker = speaker, Text = text }
end

local function narrate(text)
	return say("Narrator", text)
end

-- Grind actions each chapter unlocks, the same on every line.
local UNLOCKS = {
	{ "Sleep", "Posture", "DrinkWater", "HangOut" },
	{ "Skincare", "Mewing", "Gym" },
	{ "Haircut", "Style", "Stretch", "HeightSlider", "WidthSlider", "MeshSwap" },
	{},
	{},
}

-- BLOXED items each gate grants, the same on every line.
local REWARDS = {
	{ "SleepMask" },
	{ "Protein" },
	{ "FaceWash" },
	{ "HairClay", "Crown" },
}

StoryData.Lines = {
	LTR = {
		DisplayName = "LTR Line",
		Difficulty = "Normal",
		StartingStats = { Studs = 40, Hitbox = 35, AvatarRating = 40, Friends = 30 },
		Chapters = {
			{
				Id = "Origin",
				Title = "Back Row",
				Gate = "LunchTableLarry",
				Scenes = {
					narrate("You grew up as an LTR. Not ugly. Not noticed either."),
					narrate("In every class photo, you end up in the back row."),
					say("Milo", "Bro, you coming to lunch or what?"),
					narrate("Milo has been your best friend since second grade. He is an LTR too."),
					narrate("At the popular table, Lunch Table Larry tells a joke. Everyone laughs."),
					narrate("You tell the same joke the next day. Silence."),
					narrate("You never get any rizz during school."),
					say("Ava", "Hey, can I borrow your pencil? Thanks."),
					narrate("She never gives it back. She never talks to you again."),
					narrate("You slowly accept it."),
				},
				Choices = {
					{
						Prompt = "Larry points at the end of his table. \"Scoot over, LTR. That seat's taken.\"",
						Options = {
							{ Text = "Sit with Milo instead.", Stat = { Friends = 5 }, Speaker = "Milo", Reply = "Knew you would." },
							{ Text = "Sit at the popular table anyway.", Speaker = "Larry", Reply = "Bold. Nobody asked though." },
						},
					},
				},
			},
			{
				Id = "WakeUp",
				Title = "The Bloxpill Night",
				Gate = "MirrorYouLTR",
				Scenes = {
					narrate("Each day it bothers you more."),
					narrate("Ava starts dating a Top Blox from the grade above."),
					narrate("One night you are doomscrolling in bed."),
					narrate("A Bloxpill edit fills your screen. Slow phonk. Jawlines. Hunter Eyes."),
					narrate("You learn the whole Bloxpill in one night."),
					say("You", "So it was my avatar the whole time?"),
					narrate("You try to deny it. Then you see Top Blox get all the Clout, every day, everywhere."),
					narrate("At 3 AM the algorithm shows you a different video."),
					say("Coach", "Stop watching edits. Start a routine. Sleep, skincare, gym. Every day."),
					narrate("Coach K Shamblox. Millions of subs. Calm voice. No doom."),
					say("Coach", "The Bloxpill wants you to quit. A routine wants you to show up."),
					say("Coach", "This is softmaxxing. Slow. Reliable. It has a ceiling, but it never backfires."),
					narrate("You know you have to Rebirth and end this."),
				},
				Choices = {
					{
						Prompt = "Autoplay loads the next video. Which one do you watch?",
						Options = {
							{ Text = "Another Bloxpill edit.", Speaker = "Narrator", Reply = "The edit ends. You feel worse." },
							{ Text = "Coach K Shamblox's full routine.", Stat = { AvatarRating = 2 }, Speaker = "Coach", Reply = "Day one starts now." },
						},
					},
					{
						Prompt = "Milo texts at 3:12 AM: \"u up? cant sleep either lol\"",
						Options = {
							{ Text = "Call him and talk it out.", Stat = { Friends = 5 }, Speaker = "Milo", Reply = "Bro, same. Everybody feels like that. Let's fix it together." },
							{ Text = "Leave him on read.", Speaker = "Narrator", Reply = "The screen goes dark." },
						},
					},
				},
			},
			{
				Id = "Grind",
				Title = "Day One to Day Sixty",
				Gate = "BrickPilled99LTR",
				Scenes = {
					narrate("Day 1. You wake up at 7. Water. Skincare. Gym."),
					narrate("Day 14. Nothing changes. You want to quit."),
					say("Milo", "You've been weird lately. Good weird. What's going on?"),
					narrate("Day 30. Your jaw looks sharper. Your shirts fit different."),
					say("Clerk", "Welcome to the BLOXED Store. Face wash, hair clay, protein. All BLOXED."),
					narrate("You save your allowance for BLOXED Hair Clay."),
					narrate("That night you post a progress pic on the forums."),
					say("BrickPilled99", "lol cope. bone structure is fixed. it's over for you."),
					narrate("Forum Mod BrickPilled99 has 40,000 posts and zero progress pics."),
					narrate("Day 50. Your progress slows down. Some days the mirror shows nothing new."),
					narrate("A flyer on the bus: DR. POLYGON'S SLIDER CLINIC. SKIP THE GRIND."),
					say("Coach", "Softmaxxing has a ceiling. Hardmaxxing breaks the ceiling. Sometimes it breaks you."),
					say("Polygon", "Height Slider, Width Slider, Mesh Swap. Fast results. No guarantees."),
				},
				Choices = {
					{
						Prompt = "Milo keeps asking. Do you tell him about the grind?",
						Options = {
							{ Text = "Tell him everything.", Stat = { Friends = 10 }, Speaker = "Milo", Reply = "Bet. I'm joining. Gym at 6?" },
							{ Text = "Keep it secret.", Speaker = "Milo", Reply = "Okay. Let me know if you need me." },
						},
					},
				},
			},
			{
				Id = "Climb",
				Title = "The Rebirth Rumble",
				Gate = "TylerRumble",
				Scenes = {
					narrate("Day 90. People start saying hi in the hallway."),
					say("Ava", "Did you get taller? You look different."),
					narrate("You don't fall for it. You say thanks and keep walking."),
					say("Tyler", "Yo. You're the LTR who glowed up, right?"),
					narrate("Tyler is a Top Blox Lite. Captain of everything. He doesn't like competition."),
					say("Tyler", "Rebirth Rumble, Friday. Winner gets the Clout. Loser goes back to the back row."),
					say("Milo", "You're ready. I've seen you train."),
				},
				Choices = {
					{
						Prompt = "The Rumble is in five days.",
						Options = {
							{ Text = "Train with Milo all week.", Stat = { Hitbox = 3, Friends = 5 }, Speaker = "Milo", Reply = "Let's work." },
							{ Text = "Scroll Tyler's profile all night.", Stat = { Studs = -1 }, Speaker = "Narrator", Reply = "You fall asleep at 4 AM." },
						},
					},
				},
			},
			{
				Id = "BossRealm",
				Title = "The Runway in the Sky",
				BossRealm = true,
				Scenes = {
					narrate("After the Rumble, the gym lights flicker."),
					narrate("A door opens where a wall used to be. Behind it, a runway in the sky."),
					say("Coach", "This is where the Clout goes. HyperScale lives at the end of that runway."),
					say("Milo", "I'm coming with you. Somebody has to cheer."),
					narrate("Shawn O'Pixel waits at the first light. Jordan Bloxett waits at the second."),
					narrate("At the end, the giant scale. Every bit of Clout sits on one side."),
					say("You", "Time to tip it back."),
				},
				Choices = {},
			},
		},
	},

	Sub5 = {
		DisplayName = "Sub 5 Noob Line",
		Difficulty = "Hard",
		StartingStats = { Studs = 25, Hitbox = 20, AvatarRating = 30, Friends = 10 },
		Chapters = {
			{
				Id = "Origin",
				Title = "Default Avatar",
				Gate = "HallwayBully",
				Scenes = {
					narrate("You have been a Sub 5 Noob your whole life."),
					narrate("In kindergarten, a kid called you \"default avatar.\" It stuck."),
					say("Nana", "Eat your dinner. You're the most handsome boy I know."),
					narrate("Nana says it every night. You stopped believing it in fourth grade."),
					narrate("People bully you for your avatar. In the hallway. In the group chat. In PE."),
					narrate("A girl in art class smiles and says your drawing is nice."),
					narrate("You think about her for six months."),
					narrate("She was being nice. That was all."),
					narrate("Every time a girl shows you the smallest kindness, you fall for her. Every time, it means nothing."),
					say("Brock", "Move, Noob. This hallway is for real avatars."),
				},
				Choices = {
					{
						Prompt = "Brock blocks the hallway.",
						Options = {
							{ Text = "Walk around him.", Speaker = "Brock", Reply = "Yeah. That's what I thought." },
							{ Text = "Stand up straight and look him in the eye.", Stat = { Studs = 1 }, Speaker = "Brock", Reply = "...Whatever, weirdo." },
						},
					},
					{
						Prompt = "Nana asks how school was.",
						Options = {
							{ Text = "Tell her the truth.", Stat = { Friends = 5 }, Speaker = "Nana", Reply = "Then we'll fix it. Together. Starting with a good night's sleep." },
							{ Text = "Say it was fine.", Speaker = "Nana", Reply = "Okay, sweetheart." },
						},
					},
				},
			},
			{
				Id = "WakeUp",
				Title = "The Forums at 2 AM",
				Gate = "BrickPilled99Sub5",
				Scenes = {
					narrate("You start searching for a cure. \"How to fix face.\" \"How to grow taller.\" \"Why am I like this.\""),
					narrate("At 2 AM, you find the Bloxpill forums."),
					say("BrickPilled99", "only looks matter. all the time. accept it."),
					say("BrickPilled99", "your bone structure is cooked. only way out is brick smash and mystery juice."),
					narrate("The thread has 900 replies. Most of them agree."),
					narrate("One reply is different. Username: kai_was_here."),
					say("Kai", "don't. i did the shortcut. ask me how it went."),
					narrate("You open his profile. His last progress pic is from a year ago. Then nothing."),
					say("Coach", "Your face isn't cooked. Your routine is. Sleep, skin, gym. Show up."),
					say("Coach", "That's softmaxxing. Slow, but it never backfires."),
					narrate("The video sits in the sidebar, next to the forum link."),
				},
				Choices = {
					{
						Prompt = "The forum links glow on your screen. What do you do?",
						Options = {
							{ Text = "Take the shortcut. Brick Smash.", Action = "BrickSmash", Speaker = "BrickPilled99", Reply = "finally. welcome to the real ones." },
							{ Text = "Message Kai back.", Stat = { Friends = 5 }, Speaker = "Kai", Reply = "glad you asked. don't do it. grind with me instead." },
							{ Text = "Close the forums. Watch Coach K Shamblox.", Stat = { AvatarRating = 2 }, Speaker = "Coach", Reply = "Day one starts now." },
						},
					},
				},
			},
			{
				Id = "Grind",
				Title = "Elbows In",
				Gate = "MirrorYouSub5",
				Scenes = {
					narrate("Day 1. Your arms shake on the first push up."),
					say("Dre", "First time? Keep your elbows in. I'm Dre. I'm here every day at 6."),
					narrate("Dre is 40, built like a vending machine, and the nicest guy at the gym."),
					narrate("Day 20. Brock still calls you Noob. You still show up."),
					say("Kai", "bro your skin looks better. for real."),
					narrate("Kai crashed after the shortcut. Now he grinds the slow way too."),
					say("Nana", "You look happy. That's the most handsome I've seen you."),
					say("Clerk", "BLOXED Face Wash is half off for first timers."),
					say("Kai", "softmaxx got me back to where i was. it won't get me past it."),
					say("Kai", "the slider clinic is legit. not like the bus stop guy. but it can still glitch you."),
					say("Polygon", "Height Slider, Width Slider, Mesh Swap. Fast results. No guarantees."),
					narrate("Day 45. You walk past a mirror and stop."),
				},
				Choices = {
					{
						Prompt = "Dre invites you to train with his 6 AM crew.",
						Options = {
							{ Text = "Join the crew.", Stat = { Friends = 10, Hitbox = 2 }, Speaker = "Dre", Reply = "Welcome. We lift, we eat, we talk trash." },
							{ Text = "Train alone.", Speaker = "Dre", Reply = "Door's always open." },
						},
					},
				},
			},
			{
				Id = "Climb",
				Title = "The Bus Stop",
				Gate = "ShortcutSalesman",
				Scenes = {
					narrate("Day 100. Kids at school stop calling you Noob. Some don't recognize you."),
					say("Brock", "...Bro, did you switch schools and come back?"),
					narrate("At the bus stop, a man in a long coat waves you over."),
					say("Salesman", "Psst. Mystery Juice. Fast Hitbox. One bottle and you skip months."),
					say("Kai", "that's the guy. that's the exact guy."),
				},
				Choices = {
					{
						Prompt = "The Shortcut Salesman holds out a bottle.",
						Options = {
							{ Text = "Take the Mystery Juice.", Action = "MysteryJuice", Speaker = "Salesman", Reply = "Smart kid. No refunds." },
							{ Text = "Walk away with Kai.", Stat = { Friends = 5 }, Speaker = "Kai", Reply = "proud of you. fr." },
						},
					},
				},
			},
			{
				Id = "BossRealm",
				Title = "Not Tonight",
				BossRealm = true,
				Scenes = {
					narrate("That night, the forum loads by itself. One thread. No replies. A link."),
					narrate("You click it. Your room turns into a runway in the sky."),
					say("BrickPilled99", "you're not supposed to be here. this realm is for top blox."),
					say("Coach", "Ignore the mod. The realm is for anyone who shows up."),
					say("Dre", "Elbows in. Chin up. You got this."),
					say("Nana", "Make Nana proud."),
					narrate("Shawn O'Pixel. Jordan Bloxett. Then the giant scale."),
					say("You", "I was Sub 5 my whole life. Not tonight."),
				},
				Choices = {},
			},
		},
	},

	TopBlox = {
		DisplayName = "Top Blox Line",
		Difficulty = "Story",
		StartingStats = { Studs = 75, Hitbox = 70, AvatarRating = 85, Friends = 0 },
		Chapters = {
			{
				Id = "Origin",
				Title = "Born for the Billboard",
				Gate = "PaparazziSwarm",
				Scenes = {
					narrate("He was born with Hunter Eyes. The nurse said he'd be famous."),
					narrate("At age 4, he booked his first ad. At age 7, a billboard."),
					say("Vera", "Smile. No, the other smile. Again."),
					narrate("Vera is his agent. She has managed him since diapers."),
					narrate("He always gets what he wants. New shoes, new phone, new house."),
					narrate("He never gets a birthday party. Birthdays are shoot days."),
					say("Jamie", "Want to play after school?"),
					narrate("Jamie from second grade. The only kid who asked."),
					say("Vera", "He's busy. He's always busy."),
					narrate("Outside the school gate, the cameras wait."),
				},
				Choices = {
					{
						Prompt = "Jamie asks again the next day.",
						Options = {
							{ Text = "Say yes behind Vera's back.", Stat = { Friends = 10 }, Speaker = "Jamie", Reply = "Sweet! Bring your bike!" },
							{ Text = "Say you're busy.", Speaker = "Jamie", Reply = "Okay. Maybe next time." },
						},
					},
				},
			},
			{
				Id = "WakeUp",
				Title = "Oat Latte",
				Gate = "AgencyBossVera",
				Scenes = {
					narrate("Fifteen years later. Top Blox. Number one on every board."),
					narrate("9 million followers. Zero people to text."),
					narrate("One day he decides to meet a girl. Not at a shoot. In real life."),
					narrate("Her name is Lena. She works at the coffee shop near the studio."),
					say("You", "Hi. Could I get an oat latte? It's cold today."),
					narrate("A normal thing. Not even a joke."),
					say("Lena", "Oh my gosh, you're so funny."),
					narrate("She laughs at nothing. Her friend takes a photo."),
					narrate("That night he gets it. She didn't laugh at what he said. She laughed at his Hunter Eyes."),
					narrate("HyperScale rules everyone. Even the ones at the top."),
					say("Coach", "Looks get you attention. A life gets you people."),
					say("Coach", "And if you keep training, softmaxx. Slow and safe."),
					say("Vera", "Shoot tomorrow at 5 AM. Cancel whatever you have."),
				},
				Choices = {
					{
						Prompt = "Vera books a shoot over Jamie's birthday.",
						Options = {
							{ Text = "Go to Jamie's birthday.", Stat = { Friends = 10 }, Speaker = "Jamie", Reply = "You actually came?! No way." },
							{ Text = "Go to the shoot.", Stat = { AvatarRating = 2 }, Speaker = "Vera", Reply = "Good. That's my Top Blox." },
						},
					},
				},
			},
			{
				Id = "Grind",
				Title = "An Empty Calendar",
				Gate = "MirrorYouLonely",
				-- Leaving the agency costs him its stylists and trainers.
				OnEnterStats = { Hitbox = -12, AvatarRating = -15 },
				Scenes = {
					narrate("No more 5 AM shoots. For the first time, his calendar is empty."),
					narrate("No stylist. No trainer. No skincare team. In the mirror, he looks normal for the first time."),
					narrate("He doesn't know how to have a normal day."),
					say("Jamie", "Step one, pizza. Step two, games until 2 AM. Step three, repeat."),
					say("Coach", "Keep the routine. Gym, sleep, skin. Not for the camera. For you."),
					say("Clerk", "You're THE Top Blox? BLOXED Face Wash is on the house."),
					say("You", "I'll pay. Like everyone else."),
					say("Vera", "Dr. Polygon can fix that drop in a week. Height Slider, Mesh Swap. Fast."),
					say("Polygon", "Fast results. No guarantees. Even for Top Blox."),
					narrate("Jamie brings his friends. They don't care about the followers. They care that he's terrible at kart racing."),
					narrate("Late at night, home alone, the mirror finds him."),
				},
				Choices = {
					{
						Prompt = "Jamie's friends invite you to game night every Friday.",
						Options = {
							{ Text = "Go every Friday.", Stat = { Friends = 10 }, Speaker = "Jamie", Reply = "Told you they'd like you." },
							{ Text = "Go once.", Stat = { Friends = 5 }, Speaker = "Jamie", Reply = "Cool. Door's open." },
						},
					},
				},
			},
			{
				Id = "Climb",
				Title = "Replaced",
				Gate = "DaxVelour",
				Scenes = {
					narrate("A text from an unknown number. \"The agency replaced you.\""),
					narrate("His replacement is Dax Velour, his old rival from the runway days."),
					say("Dax", "Heard you went soft. Pizza and friends? You're done."),
					say("Lena", "Hey. I'm sorry I laughed. I didn't even hear what you said."),
					say("Dax", "Runway Showdown, Saturday. Prove you still have it."),
				},
				Choices = {
					{
						Prompt = "Lena apologizes.",
						Options = {
							{ Text = "Accept it. Order a latte.", Stat = { Friends = 5 }, Speaker = "Lena", Reply = "Oat latte. On me this time." },
							{ Text = "Walk out.", Speaker = "Lena", Reply = "...Fair." },
						},
					},
				},
			},
			{
				Id = "BossRealm",
				Title = "The Heavy Side",
				BossRealm = true,
				Scenes = {
					narrate("After the show, the runway keeps going. Past the lights. Into the sky."),
					narrate("At the end, two faces he knows from a hundred shoots. Shawn O'Pixel. Jordan Bloxett."),
					say("Vera", "Go back. Up there, nobody wins."),
					say("Jamie", "We're right here. Go."),
					narrate("Behind them, the giant scale. He has always sat on the heavy side."),
					say("You", "Time to tip it back. For everyone."),
				},
				Choices = {},
			},
		},
	},
}

StoryData.LineOrder = { "LTR", "Sub5", "TopBlox" }

for _, line in pairs(StoryData.Lines) do
	for index, chapter in ipairs(line.Chapters) do
		chapter.Unlocks = UNLOCKS[index]
		chapter.Rewards = REWARDS[index] or {}
	end
end

---------------------------------------------------------------------------
-- Final bosses, fought in order in chapter 5
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
			"Jamie texts: \"pizza?\"",
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
	Glitched = {
		Title = "Glitched",
		Kind = "Lose",
		Text = {
			"The Slider Clinic glitched you past repair.",
			"No amount of grinding reaches the bosses now.",
			"HyperScale wins this time. Start a new run.",
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
-- Run state
---------------------------------------------------------------------------

local function addStats(run, statGains, extra)
	for statId, amount in pairs(statGains) do
		local value = (run.Stats[statId] or 0) + amount + (extra or 0)
		run.Stats[statId] = math.max(0, math.min(value, StoryData.STAT_MAX))
	end
end

local function enterChapter(run)
	local chapter = StoryData.Lines[run.Line].Chapters[run.Chapter]
	for _, actionId in ipairs(chapter.Unlocks) do
		run.Unlocked[actionId] = true
	end
	if chapter.OnEnterStats then
		addStats(run, chapter.OnEnterStats)
	end
end

local function itemBonus(run, actionId)
	local bonus = 0
	for itemId in pairs(run.Items) do
		bonus = bonus + (StoryData.Items[itemId].Bonus[actionId] or 0)
	end
	return bonus
end

function StoryData.NewRun(lineId)
	local line = StoryData.Lines[lineId]
	assert(line, "Unknown line: " .. tostring(lineId))
	local run = {
		Line = lineId,
		Chapter = 1,
		Stats = {},
		Flags = {},
		Items = {},
		Unlocked = {},
		ChoicesMade = {},
		SoftGain = {},
		HardGain = {},
		HardCap = {},
		Scars = {},
	}
	for statId in pairs(StoryData.Stats) do
		run.Stats[statId] = line.StartingStats[statId] or 0
	end
	for _, statId in ipairs(StoryData.FightStats) do
		run.SoftGain[statId] = 0
		run.HardGain[statId] = 0
		run.HardCap[statId] = StoryData.HARD_CAP
		run.Scars[statId] = 0
	end
	enterChapter(run)
	return run
end

function StoryData.GetChapter(run)
	return StoryData.Lines[run.Line].Chapters[run.Chapter]
end

-- Softmaxx once. Fight stat gains stop at SOFT_CAP. Friends has no cap.
-- Returns true, or false plus "Locked" or "SoftCapped".
function StoryData.ApplyAction(run, actionId)
	local action = StoryData.GrindActions[actionId]
	assert(action, "Unknown action: " .. tostring(actionId))
	if action.Trap or not run.Unlocked[actionId] then
		return false, "Locked"
	end
	local gains = {}
	local gained = false
	for statId, amount in pairs(action.Stat) do
		amount = amount + itemBonus(run, actionId)
		if run.SoftGain[statId] then
			amount = math.max(0, math.min(amount, StoryData.SOFT_CAP - run.SoftGain[statId]))
			run.SoftGain[statId] = run.SoftGain[statId] + amount
		end
		gains[statId] = amount
		gained = gained or amount > 0
	end
	if not gained then
		return false, "SoftCapped"
	end
	addStats(run, gains)
	return true
end

-- Hardmaxx once at the Slider Clinic. rng is optional and returns a number in [0, 1).
-- Returns the outcome id and the stat change, or nil plus "Locked" or "HardCapped".
function StoryData.ApplyHardmaxx(run, procedureId, rng)
	local procedure = StoryData.Procedures[procedureId]
	assert(procedure, "Unknown procedure: " .. tostring(procedureId))
	if not run.Unlocked[procedureId] then
		return nil, "Locked"
	end
	local statId = procedure.Stat
	local room = run.HardCap[statId] - run.HardGain[statId]
	if room <= 0 then
		return nil, "HardCapped"
	end

	local roll = (rng or math.random)()
	local outcome = StoryData.HardmaxxOutcomes[#StoryData.HardmaxxOutcomes]
	local total = 0
	for _, candidate in ipairs(StoryData.HardmaxxOutcomes) do
		total = total + candidate.Chance
		if roll < total then
			outcome = candidate
			break
		end
	end

	local change = outcome.Gain
	if change > 0 then
		change = math.min(change, room)
		run.HardGain[statId] = run.HardGain[statId] + change
	end
	if outcome.Scar then
		run.HardCap[statId] = math.max(run.HardGain[statId], run.HardCap[statId] - outcome.Scar)
		run.Scars[statId] = run.Scars[statId] + 1
	end
	local before = run.Stats[statId]
	addStats(run, { [statId] = change })
	return outcome.Id, run.Stats[statId] - before
end

-- Pick an option in the current chapter. Each choice counts once.
-- Returns the option, so the UI can show its Reply, or nil if not allowed.
function StoryData.ApplyChoice(run, choiceIndex, optionIndex)
	local chapter = StoryData.GetChapter(run)
	local choice = chapter.Choices[choiceIndex]
	local option = choice and choice.Options[optionIndex]
	local key = run.Chapter .. ":" .. choiceIndex
	if not option or run.ChoicesMade[key] then
		return nil
	end
	run.ChoicesMade[key] = optionIndex
	if option.Stat then
		addStats(run, option.Stat)
	end
	if option.Action then
		local trap = StoryData.GrindActions[option.Action]
		if trap.Lines == nil or trap.Lines[run.Line] then
			addStats(run, trap.Stat)
			if trap.Flag then
				run.Flags[trap.Flag] = true
			end
		end
	end
	return option
end

-- Returns true, or false plus the first stat that fell short.
function StoryData.MeetsRequirements(stats, requirements)
	for _, statId in ipairs(StoryData.StatOrder) do
		local needed = requirements[statId]
		if needed and (stats[statId] or 0) < needed then
			return false, statId
		end
	end
	return true
end

function StoryData.CanBeatBoss(stats, bossId)
	local boss = StoryData.Bosses[bossId]
	assert(boss, "Unknown boss: " .. tostring(bossId))
	return StoryData.MeetsRequirements(stats, boss.Requirements)
end

-- Fight the current chapter's mini boss. A win grants the rewards and opens the next chapter.
-- Returns won, missingStat.
function StoryData.ChallengeGate(run)
	local chapter = StoryData.GetChapter(run)
	assert(chapter.Gate, "This chapter has no gate. Use ResolveEnding in the Boss Realm.")
	local won, missingStat = StoryData.MeetsRequirements(run.Stats, StoryData.MiniBosses[chapter.Gate].Requirements)
	if not won then
		return false, missingStat
	end
	for _, itemId in ipairs(chapter.Rewards) do
		run.Items[itemId] = true
	end
	run.Chapter = run.Chapter + 1
	enterChapter(run)
	return true
end

-- Highest value a stat could still reach this run: soft room, hard room,
-- the best stat bonus left in each unpicked choice, and future chapter events.
-- An upper bound, so it never calls a winnable run lost.
function StoryData.MaxReachable(run, statId)
	if not run.SoftGain[statId] then
		return StoryData.STAT_MAX
	end
	local value = run.Stats[statId]
		+ (StoryData.SOFT_CAP - run.SoftGain[statId])
		+ (run.HardCap[statId] - run.HardGain[statId])
	local chapters = StoryData.Lines[run.Line].Chapters
	for index = run.Chapter, #chapters do
		local chapter = chapters[index]
		if index > run.Chapter and chapter.OnEnterStats then
			value = value + (chapter.OnEnterStats[statId] or 0)
		end
		for choiceIndex, choice in ipairs(chapter.Choices) do
			if not run.ChoicesMade[index .. ":" .. choiceIndex] then
				local best = 0
				for _, option in ipairs(choice.Options) do
					local amount = not option.Action and option.Stat and option.Stat[statId] or 0
					best = math.max(best, amount)
				end
				value = value + best
			end
		end
	end
	return math.min(value, StoryData.STAT_MAX)
end

-- False plus the stat when no play can reach the remaining gates and the final bosses.
-- Show the Glitched ending when this turns false.
function StoryData.CanStillWin(run)
	local requirements = {}
	local chapters = StoryData.Lines[run.Line].Chapters
	for index = run.Chapter, #chapters do
		local gate = chapters[index].Gate
		if gate then
			table.insert(requirements, StoryData.MiniBosses[gate].Requirements)
		end
	end
	for _, bossId in ipairs(StoryData.BossOrder) do
		table.insert(requirements, StoryData.Bosses[bossId].Requirements)
	end
	for _, statId in ipairs(StoryData.StatOrder) do
		local reachable = StoryData.MaxReachable(run, statId)
		for _, needed in ipairs(requirements) do
			if needed[statId] and reachable < needed[statId] then
				return false, statId
			end
		end
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

local function fightAll(stats)
	for _, bossId in ipairs(StoryData.BossOrder) do
		local won, missingStat = StoryData.CanBeatBoss(stats, bossId)
		if not won then
			return false, bossId, missingStat
		end
	end
	return true
end

-- Fight the Boss Realm. rng is optional and returns a number in [0, 1). Defaults to math.random.
-- Returns the ending id and a table with details for the UI.
function StoryData.ResolveEnding(run, rng)
	rng = rng or math.random
	local flags = run.Flags

	if flags.BrickSmash or flags.MysteryJuice then
		local lucky = run.Line == "Sub5" and rng() < StoryData.SHORTCUT_REBIRTH_CHANCE
		if not lucky then
			return flags.BrickSmash and "BrickSmashed" or "JuiceCrash", {}
		end
		local won, bossId, missingStat = fightAll(run.Stats)
		if not won then
			return "NotEnoughStuds", { LostTo = bossId, MissingStat = missingStat }
		end
		return "LuckyRebirth", {}
	end

	local won, bossId, missingStat = fightAll(run.Stats)
	if not won then
		return "NotEnoughStuds", { LostTo = bossId, MissingStat = missingStat }
	end
	if run.Line == "TopBlox" and (run.Stats.Friends or 0) >= StoryData.REAL_FRIENDS_THRESHOLD then
		return "RealFriends", {}
	end
	return "ScaleTipsBack", {}
end

return StoryData
