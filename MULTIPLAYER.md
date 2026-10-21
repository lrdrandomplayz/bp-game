# Avatarmaxxing Multiplayer Plan

A plan for the multiplayer version. Nothing here is built yet. The single-player rules in `STORY.md` and `src/shared/StoryData.lua` stay the source of truth: multiplayer adds a shared world, parties, a raid, and team events around them.

## Goals

1. Friends play together in one server.
2. Every player keeps their own storyline, chapter, stats, and ending.
3. Co-op makes runs faster and more fun, but never carries anyone to an ending their stats didn't earn.
4. Players never rate, judge, rank, or vote on each other's avatars. Competition is always against NPCs.

## 1. Architecture

The server is authoritative. Clients only ask; the server decides.

| Piece | Where | Job |
|---|---|---|
| `StoryData` | ReplicatedStorage/Shared | Story text and rules. Clients read it for UI. Only the server calls functions that change a run. |
| RunService (server script) | ServerScriptService | Holds each player's `run` and `profile`. Calls `StoryData` functions. Rolls every random number with a server-side `Random.new()`. |
| SaveService | ServerScriptService | DataStore save and load: `profile` plus the current `run`, keyed by UserId. Saves on leave, on chapter change, and every few minutes. Uses `UpdateAsync` with retries. |
| StoreService | ServerScriptService | `UserOwnsGamePassAsync` on join, then `StoryData.GrantPass`. `ProcessReceipt` for products: `ApplyProduct`, or `CreditProduct` when it can't apply, and always grant the receipt. |
| PartyService | ServerScriptService | Party invites, up to 4 players, raid and event queues. |
| Client UI | StarterPlayerScripts | Dialogue boxes, choices, grind buttons, Energy bar, store, party panel. Sends intents only. |

### RemoteEvents (client to server intents)

| Remote | Payload | Server check |
|---|---|---|
| `ChooseOption` | choiceIndex, optionIndex | `ApplyChoice` |
| `DoAction` | actionId | `RefreshEnergy(os.time())`, then `ApplyAction` |
| `VisitClinic` | procedureId | `RefreshEnergy`, then `ApplyHardmaxx` with the server rng |
| `ChallengeGate` | none | `ChallengeGate` |
| `UseFreeRepair` | statId | `UseScarRepairToken` |
| `PartyInvite`, `PartyAccept`, `PartyLeave` | userId | PartyService |
| `QueueRaid`, `QueueRunway` | none | Party leader only, every member eligible |

Every remote is rate limited per player (for example 5 calls per second). The server ignores any stat, roll, or result a client sends. The client gets back only its own run state through a `RunUpdated` RemoteEvent.

## 2. Hub town

One shared map. Story scenes play at the place they happen.

| Location | Used for |
|---|---|
| School | LTR and Sub 5 Noob chapters 1 and 4 scenes, Lunch Table Larry, Brock, Tyler's Rebirth Rumble poster |
| Gym | Gym and Stretch actions, Dre's 6 AM crew, Gym Spot |
| BLOXED Store | The Clerk, Drip Pack try-on mirror, the Robux store counter |
| Slider Clinic | Dr. Polygon, hardmaxx visits, Clinic Buddy |
| Coffee Shop | Lena scenes, Hang Out spot |
| Bus Stop | The Shortcut Salesman (Sub 5 Noob only, an NPC scene) |
| Home | Sleep, Skincare, Mewing, mirror gates (Mirror You), Bloxpill forum scenes |
| Runway Tower | Boss Realm raid entrance and Team Runway events |

Scenes a player is in right now only show to that player. Other players see them standing at the spot with a "In a scene" bubble.

## 3. Parties

- 1 to 4 players. Invite from the party panel or by walking up and pressing Invite.
- Each player keeps their own line and chapter. A Sub 5 Noob in chapter 2 can party with a Top Blox in chapter 5.
- The party panel shows names, line, chapter, and Raid Ready or Not Ready. It never shows stats, tiers, or scars.

## 4. Co-op mechanics

All co-op bonuses stay inside the existing caps. They make runs faster, never higher.

| Mechanic | Rule | Why it can't be farmed |
|---|---|---|
| Gym Spot | Two or more party members doing Gym within 10 studs of each other each get +1 on that action. | Still counts toward the +20 softmaxx cap. |
| Hang Out | Hanging out with a real party member gives both +5 Friends. | Once per pair every 10 minutes. Friends only matters for some gates and the Top Blox bonus ending. |
| Clinic Buddy | A party member standing in the Slider Clinic lowers your next visit's Energy cost by 1. | Never changes the odds, the gain, or the cap. |
| Story Cameos | Your party can watch your gate fights and cheer. Cheering does nothing to the fight. | Cosmetic only. |

New `StoryData` hooks needed later: an `extraBonus` argument on `ApplyAction` (Gym Spot) and an `energyDiscount` argument on `ApplyHardmaxx` (Clinic Buddy). The server decides when they apply.

## 5. Boss Realm raid

- Party members who reached chapter 5 can queue together. Solo still works.
- The raid fights Shawn O'Pixel, then Jordan Bloxett, then HyperScale, each with a shared HP bar.
- Damage: each player's hits scale with how far their stats meet that boss's requirements. For each fight stat, divide the player's stat by the requirement and cap it at 1.2, then average the three. A player under the requirement still helps, just less.
- After HyperScale falls, each player's own ending comes from `ResolveEnding(run)` on their own stats and flags. A player below the requirements gets Not Enough Studs even if the party won, plus a "Carried" message telling them which stat to grind. Nobody gets the true ending without the stats.
- Traps still apply. A player with the Stat Exploit flag gets their own trap roll, and only their ending changes.
- Raid ending scene: if at least one player gets the true ending, the shared cutscene shows the scale tipping back for the whole party.

## 6. Team Runway events

- Teams of 1 to 4 against NPC models only: Tyler, Dax Velour, Shawn O'Pixel. The difficulty rises in that order.
- Score per walk = team stat score + a rhythm minigame (press on the beat as you walk). Stat score uses the same capped ratio as the raid, averaged across the team, so one strong player can't solo it.
- Win or lose, everyone gets Friends. Wins give cosmetic rewards: Crown colors, walk trails, and a Runway Champion title per NPC beaten.
- Never player against player. No crowd voting, no "who looked best," no leaderboard of avatars. A leaderboard, if added, ranks teams by NPCs beaten and fastest clear only.

## 7. Safety rules

These rules keep the game away from harassment reports, the most common takedown reason.

1. Players only ever see their own stats, tier, scars, and Energy.
2. Other players see your name, line, chapter, and cosmetics. Never a tier label like Sub 5 Noob.
3. No feature rates, scores, votes on, or ranks a player's avatar.
4. Chat uses Roblox's default filtered TextChatService. No custom chat.
5. Scam and Bloxpill scenes (BrickPilled99, the Shortcut Salesman) are NPC-only. Players can't send links, codes, or trades.
6. A report button on the party panel, plus mute and block support.
7. The game description and an opening card state the message: HyperScale is the villain, and every good ending proves "only looks matter" wrong.

## 8. Monetization in multiplayer

- Game passes and products stay per player, exactly as in `STORY.md`.
- Private servers at a low monthly price, so parties can play alone together.
- No buying power for others. A player can't buy Energy, repairs, or boosts for a party member. Gifting cosmetics can come later if Roblox's gifting rules allow it.
- Gym Spot and Clinic Buddy give paying and free players the same bonus.

## 9. Milestones

| Milestone | Scope | Done when |
|---|---|---|
| M1 Server runs | Move single-player runs to the server: RunService, SaveService, StoreService, RemoteEvents, basic UI. One player per server is fine. | A full run saves, loads, and finishes on the server. Store purchases work in Studio test mode. |
| M2 Hub and parties | The town map, location-based scenes, PartyService and party panel. | 4 players in one server each play their own line. |
| M3 Co-op | Gym Spot, Hang Out, Clinic Buddy, plus the two new `StoryData` hooks. | Bonuses apply and respect the caps. Tests cover the farming limits. |
| M4 Raid | Raid queue, shared HP bars, damage formula, per-player endings. | A mixed party clears the raid, and each player gets their own correct ending. |
| M5 Team Runway | Rhythm minigame, NPC models, rewards. | Teams beat all three NPCs, and rewards save. |
| M6 Playtest | Private friends-only test, fix reports, fill in the Content Maturity questionnaire, then go public. | No safety issues in the playtest, and the questionnaire is done. |

## 10. Open questions for kaydnn

1. Should parties allow players in different chapters to do story scenes together, or only grind, raid, and run events together?
2. Raid size: keep 1 to 4, or allow up to 6 with harder boss HP?
3. Should Team Runway have a weekly rotating NPC with a limited-time Crown color?
4. Should Kai's Story (the fourth line) launch with multiplayer, or before it as a single-player update?
5. Do you want a daily login reward (for example a free Skip Rest every 24 hours) to help retention and Premium Payouts?
