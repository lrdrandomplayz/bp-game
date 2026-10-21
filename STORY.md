# Avatarmaxxing: Defeat HyperScale

Story, stats, bosses, and endings. The game data lives in `src/shared/StoryData.lua`. Change numbers and text there.

## Glossary

The "Original" column is a dev note only. Player-facing text uses the in-game term.

| Original | In-game |
|---|---|
| Looksmaxxing | Avatarmaxxing |
| LTN / MTN / HTN | LTR / MTR / HTR (Low, Mid, High Tier Robloxian) |
| Sub 5 | Sub 5 Noob |
| Chad / Chadlite | Top Blox / Top Blox Lite |
| Blackpill / BP edit | Bloxpill / Bloxpill edit |
| Ascend | Rebirth |
| Mog | Outshine |
| Hunter eyes | Hunter Eyes |
| Bonesmashing (trap) | Brick Smash |
| Steroids (trap) | Mystery Juice |
| Hypergamy | HyperScale |
| Game / getting girls | Rizz. Attention meter is called Clout. |
| Height / Width / Looks | Studs / Hitbox / Avatar Rating |
| Real models (bosses) | Shawn O'Pixel, Jordan Bloxett |

The bosses use parody names. Roblox removes experiences using real people's names and likeness.

## Stats

| Stat | Meaning | Legit grind |
|---|---|---|
| Studs | Height | Sleep 9 Hours (+2), Fix Posture (+1) |
| Hitbox | Clavicle and shoulder width | Gym (+3) |
| Avatar Rating | Looks | Skincare (+2), New Haircut (+3), New Fit (+2) |
| Friends | People who like you for you | Hang Out (+5) |

All stats cap at 100. Studs, Hitbox, and Avatar Rating decide boss fights. Friends unlocks the Top Blox bonus ending.

Tier comes from the average of Studs, Hitbox, and Avatar Rating:

| Average | Tier |
|---|---|
| 85+ | Top Blox |
| 75+ | Top Blox Lite |
| 65+ | HTR |
| 50+ | MTR |
| 30+ | LTR |
| below 30 | Sub 5 Noob |

## Storylines

### LTR Line (Normal)

Start: Studs 40, Hitbox 35, Avatar Rating 40, Friends 30.

1. You grew up as an LTR.
2. You never got any rizz during school.
3. You slowly accepted it.
4. Each day it bothered you more.
5. One night you were doomscrolling in bed and saw a Bloxpill edit.
6. You learned the whole Bloxpill in one night.
7. You tried to deny your avatar was the reason you got no rizz.
8. Then you kept seeing Top Blox get all the Clout.
9. You knew you had to Rebirth and end this.

### Sub 5 Noob Line (Hard)

Start: Studs 25, Hitbox 20, Avatar Rating 15, Friends 10.

1. You have been a Sub 5 Noob your whole life.
2. People bullied you for your avatar.
3. Every time a girl showed you the smallest kindness, you fell for her.
4. Soon you realized it meant nothing.
5. You started searching for a cure.
6. While searching, you found the Bloxpill forums.
7. They told you only looks matter, all the time.
8. They said your bone structure is cooked.
9. They said the only way out is Brick Smash and Mystery Juice.
10. You step onto the path to fight this unfair server.

Choice: take Brick Smash, take Mystery Juice, or close the forums and grind the slow way.

### Top Blox Line (Story)

Start: Studs 75, Hitbox 70, Avatar Rating 85, Friends 0.

1. He was born with Hunter Eyes.
2. He has been a model since he was a kid.
3. He always gets what he wants.
4. He has no friends.
5. He never had a real childhood.
6. People only used him for modeling.
7. One day he decides to meet a girl.
8. He says a normal thing. Not even a joke.
9. She laughs.
10. Now he knows HyperScale rules everyone, even the ones at the top.
11. He walks into the boss realm to face his old modeling rivals.

Choice: talk to an old classmate (+10 Friends) or ignore them.

## Trap routes

Brick Smash (+25 Avatar Rating) and Mystery Juice (+25 Hitbox) show up only on the Sub 5 Noob line. Each gives a fast stat jump and sets a flag.

At the end, a trap flag triggers a roll:

- 97%: the trap ending plays. Brick Smash leads to "Brick Smashed". Mystery Juice leads to "Juice Crash". HyperScale wins.
- 3%: the Noob gets a Lucky Rebirth and still has to beat all three bosses with his stats.

Tune the chance with `SHORTCUT_REBIRTH_CHANCE` in `StoryData.lua`.

## Boss fight

Bosses come in order. Each one checks Studs, Hitbox, and Avatar Rating. Any stat below the requirement loses the fight.

| Order | Boss | Studs | Hitbox | Avatar Rating |
|---|---|---|---|---|
| 1 | Shawn O'Pixel, The Face of Every Ad | 60 | 55 | 70 |
| 2 | Jordan Bloxett, The Runway King | 70 | 65 | 80 |
| 3 | HyperScale, The Scale Itself | 80 | 75 | 85 |

Beat all three and the scale tips back to normal. HyperScale stops existing.

## Endings

| Ending | Kind | Condition |
|---|---|---|
| The Scale Tips Back | True | No trap used, beat all three bosses. |
| Real Friends | Bonus | Top Blox line, beat all three bosses, Friends 50+. |
| Lucky Rebirth | Rare | Sub 5 Noob used a trap, won the 3% roll, beat all three bosses. |
| Brick Smashed | Bad | Used Brick Smash and lost the roll. |
| Juice Crash | Bad | Used Mystery Juice and lost the roll. |
| Not Enough Studs | Lose | A stat fell below a boss requirement. Retry and grind more. |

## Code API

```lua
local StoryData = require(game.ReplicatedStorage.Shared.StoryData)

local stats = StoryData.NewStats("Sub5")
local flags = {}
StoryData.ApplyAction("Sub5", stats, flags, "Gym")

local tier = StoryData.GetTier(stats)              -- tier.DisplayName
local won, missingStat = StoryData.CanBeatBoss(stats, "ShawnOPixel")
local endingId, info = StoryData.ResolveEnding("Sub5", stats, flags)
local ending = StoryData.Endings[endingId]         -- ending.Title, ending.Text
```

`ResolveEnding` takes an optional fourth argument, a function returning a number in [0, 1), for testing the roll.
