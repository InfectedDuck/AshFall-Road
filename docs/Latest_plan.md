# Ashfall Road: four-week portfolio development plan

## Goal and priorities

Make Ashfall Road a hardcore survival game where players can deliberately create a build, make informed sacrifices, and recognize the consequences of their decisions.

The project already contains **124 events, 72 items, and 21 adversaries**, plus weapon signatures, enemy tells, story callbacks, and save recovery. The next release should make these systems work together more clearly.

Target **four weeks at 15–25 hours per week**, delivering Windows and Android builds from the same Godot project. Windows needs an export preset and platform testing; a separate game implementation is unnecessary. [Godot export documentation](https://docs.godotengine.org/en/stable/tutorials/export/)

## Gameplay improvements

### 1. Add talents that change how equipment is used

Introduce **six run-only talents**, with one selection after the first region and another after the third. Players choose from the remaining talents, without random offers, duplicates, or respecs. Existing stat allocation remains separate.

| Talent | Tactical effect |
|---|---|
| **Retaliation** | With a shield equipped, a failed Block still grants Riposte, but its incoming-damage multiplier rises from 1.25 to 1.5. |
| **Patient Shot** | A loaded ranged weapon’s Attack that spends Opening consumes no ammunition. The weapon must already have enough ammunition for an ordinary attack. |
| **Exploit Weakness** | The first successful weapon interrupt in a fight grants Opening for the next action. Existing interrupt restrictions remain. |
| **Bloodlust** | Execution activates below 60% enemy HP instead of 40%, but attacks receiving that bonus lose 10 percentage points of accuracy. |
| **Sustained Pressure** | Weapon suppression also applies to the following enemy response. It refreshes rather than stacks. |
| **Field Medicine** | The first healing item used in each fight preserves an existing Opening or Riposte. The enemy still responds normally. |

These are initial tuning values, to be adjusted through the planned balance checks.

Show each talent’s requirements and effects in equipment comparisons, action previews, and combat feedback. The player should understand *why* a combination works.

**Desired result:** shield counters, ammunition-conscious precision builds, disruption builds, aggressive finishers, and suppression builds require different decisions.

### 2. Make checkpoints a difficult build decision

Expand the existing checkpoint choice to **Rest, Barter, or Press On**. Players may perform one activity; talents and stat allocation remain independent.

- **Rest:** retain the current food cost and recovery.
- **Barter:** purchase one of three offers, sacrificing the opportunity to rest or gain Momentum.
- **Press On:** retain the current Momentum benefit.

Generate and save three offers when entering a checkpoint:

- One compatible equipment item, using existing gear and regional progression.
- Ammunition for the equipped ranged weapon, or medical supplies for a melee build.
- Food.

Use a small authored catalog with explicit costs in existing scrap and supplies. Display the complete exchange before commitment. Browsing costs nothing; purchasing commits the activity. Reopening the screen or restarting cannot refresh stock.

This creates decisions such as: **recover from exhaustion now, or spend supplies on the shield that makes your build work?**

### 3. Improve meaningful choices and readable danger

Review the fresh audit’s **six potentially dominant scenes and two redundant choice pairs** first. Check their narrative consequences before changing them: automated comparisons cannot determine story value.

For each revised scene:

- Give each option a distinct purpose: conserve supplies, avoid injury, obtain equipment, or support a person.
- Show guaranteed costs and meaningful danger clues before commitment.
- Preserve uncertainty about outcomes and later story developments.
- Connect major commitments to an existing callback or ending consequence.
- Ensure depleted players retain a valid option, even when that option is costly.

Use existing outcome receipts and the Road Chronicle to explain consequences. Ordinary choices should affect resources or circumstances; major commitments should return later in the run.

Keep strict permadeath. Tune difficulty through resource pressure, enemy behavior, and competing priorities.

## Implementation and presentation

- Add talent and checkpoint-offer definitions to the existing data-driven content system. Implement their rules in domain modules rather than embedding calculations in UI code.
- Add domain interfaces for listing/selecting talents and previewing/accepting checkpoint trades. Use the existing save-aware transaction system for every commitment.
- Version the new run state and combat behavior. Existing runs continue under their previous build rules; new runs receive talents and trading. Saved prepared actions remain authoritative.
- Extend content validation to cover talent references, compatible offers, payment requirements, and reward availability.
- Update the choice-analysis fixtures to include Presence and explicitly cover stat-gated options. The current audit exits with uncovered-gate diagnostics, so its findings are provisional.

For presentation:

- Finish portraits for **the fourth survivor, bandits, crows, and Warden** first. Replace remaining generic portrait labels with the existing illustrated or descriptive fallback treatment.
- Make talent activations, interrupted attacks, suppression, and resource costs visually recognizable without slowing turns.
- Preserve large text, reduced motion, and reachable touch controls.
- Keep the portrait interface on Windows, centered against the existing background. Add mouse-wheel scrolling, visible keyboard focus, Enter to activate focused controls, and Escape to close overlays.
- Produce a Windows x64 ZIP and Android APK with the same content version. Test the Android build on a physical phone.

Prepare a portfolio packet containing both downloads, a **60–90 second gameplay video**, screenshots, and a short case study explaining your contribution, architecture, design decisions, and playtest-driven changes. Credit third-party and generated assets accurately.

## Schedule and acceptance criteria

| Week | Deliverable | Estimated effort |
|---|---|---:|
| **1** | Current baseline, choice review, talent rules and persistence | 15–20 hours |
| **2** | Talent UI, checkpoint trading, equipment integration | 20–25 hours |
| **3** | Targeted choice revisions, portraits, Windows controls, first playtests | 15–25 hours |
| **4** | Balance adjustments, platform verification, release builds and portfolio packet | 15–20 hours |

**Automated acceptance**

- Existing regression and save-recovery suites pass.
- Talent and trade previews do not mutate state or RNG.
- Restarting cannot duplicate talent selections, purchases, payments, or rewards.
- Old saves and prepared fights remain valid.
- Every talent activates correctly, respects equipment restrictions, and survives interruption.
- Seeded comparisons cover all five starting stat identities, depleted supplies, and incompatible equipment.
- No revised event leaves the player without a legal choice.

**Player acceptance**

Run two small playtest rounds, aiming for **6–10 external players in total**:

- Most reach their first meaningful decision within one minute.
- Most reach the first talent choice within approximately ten minutes.
- Players can explain one equipment interaction and one sacrifice they made.
- At least three distinct build approaches prove useful across observed sessions.
- Players can identify a plausible reason for a death and something they would change next run.

Keep simulation results separate from human feedback; neither assertion counts nor simulated win rates establish that the game is fun.

**Scope defaults:** complete this focused release before adding route maps, crafting, more regions, permanent power progression, multiplayer, or monetization. If the schedule slips, reduce additional art and editorial coverage first; preserve gameplay correctness, playtesting, and both platform builds.
