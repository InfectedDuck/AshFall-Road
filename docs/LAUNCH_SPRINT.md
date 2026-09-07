# Four-week launch sprint

Target window: 31 August-27 September 2026. Public availability inside this window is conditional on Google granting production access and completing review. A new personal account must first keep at least 12 testers continuously opted into a closed test for 14 days.

## Locked v1 scope

- Ship the existing six-region offline game.
- Prioritize first-session clarity, combat/readability defects, save safety, and Android compatibility.
- Include no advertising SDK, billing plugin, store entry point, paid item, shop economy, map rewrite, or major event expansion.
- Keep curated placeholder art. Only store-facing and frequently seen assets receive launch polish.
- Preserve the current schemas (active run 5, profile 5, entitlements 1), deterministic rolls, strict permadeath, current content IDs, and the existing region structure.

## Daily board

### Week 1 - release foundation and closed-test start

- [ ] Day 1 - OWNER: register Play Console, complete identity/device verification, choose the legal developer name, support email, and permanent package ID.
- [ ] Day 1 - OWNER: replace `com.yourstudio.ashfallroad` in both Android presets only after the permanent ID is decided.
- [ ] Day 1 - OWNER: generate the upload keystore outside the repository and back it up securely in two places.
- [x] Day 1 - PROJECT: API 36 AAB preset, portrait orientation, arm64, offline saves, and Android backup boundaries are configured.
- [x] Day 2 - PROJECT: free-v1 launch flag disables and hides ads, billing, and the cosmetic store.
- [x] Day 2 - PROJECT: opening-event guidance prevents a combat opener and teaches resources plus equipment across the first two events.
- [x] Day 2 - PROJECT: death summaries identify fatal context, conditions, and equipped loadout.
- [ ] Day 2 - OWNER: upload a signed AAB to internal testing and install the Play-delivered build on the Samsung.
- [ ] Days 2-4 - HUMAN: complete five fresh first-ten-minute observations using the pacing sheet below.
- [ ] Days 3-5 - OWNER: recruit 15-20 genuine testers and start the closed test by Day 5.
- [ ] Days 6-7 - PROJECT/HUMAN: fix only reproduced P0/P1 issues, run all gates, publish closed build `0.9.0`, and record version/commit/known limitations.

### Week 2 - balance and mobile usability

- [ ] Days 8-9 - run `tools/balance_report.gd`; inspect false choices, weapon damage, armor, enemies, and regional supplies.
- [ ] Days 8-10 - review closed-test feedback by severity and first-session impact.
- [ ] Days 10-12 - verify journey, inventory, combat, large text, high contrast, reduced motion, and Android Back behavior.
- [ ] Days 12-14 - publish at most one controlled closed-test update and confirm the continuous tester count remains above 12.

### Week 3 - release-candidate lock

- [ ] Days 15-16 - run the interruption/offline/device matrix in `TESTING.md`.
- [ ] Day 15 - audit every placeholder against `UI_ASSET_MANIFEST.md` and `ASSET_PROVENANCE.md`.
- [ ] Day 16 - polish only the icon, feature graphic, early-region presentation, common silhouettes, and common item symbols.
- [ ] Day 17 - lock code/content/art except P0/P1 corrections.
- [ ] Days 17-19 - complete privacy policy, Data Safety, ads declaration, app access, audience, IARC rating, listing, and screenshots.
- [ ] Day 19 or later - apply for production access only after the full continuous 14-day test requirement is shown as complete.
- [ ] Days 20-21 - build and distribute RC1 through the closed track.

### Week 4 - submission and launch

- [ ] Days 22-24 - review Play pre-launch results; test clean install, upgrade, offline start, and the exact signed AAB.
- [ ] Days 25-27 - run `tools/release_readiness.gd` and the complete automated suite. Accept no unresolved P0/P1 defect.
- [ ] Day 27 - submit/roll out only if every gate in `RELEASE_CHECKLIST.md` passes.
- [ ] Day 28 - release if Google approval is complete; otherwise keep RC1 in closed testing and launch on the first eligible day.

## First-ten-minute observation sheet

Record timestamps rather than asking whether the tester “liked” the game.

| Moment | Target | Actual | Needed help? | Friction observed |
|---|---:|---:|---|---|
| Candidate chosen | 0:45 | | | |
| First meaningful choice visible | 1:00 | | | |
| First resolved consequence | 3:00 | | | |
| Resource/equipment interaction understood | 5:00 | | | |
| Significant danger understood | 8:00-10:00 | | | |
| First death/restart, if reached | Two restart actions | | | |

Ask afterward: What changed? Why did it change? What would you do differently on another run? A failure to answer is a clarity defect even if the mechanic behaved correctly.

## Severity and go/no-go

- P0: crash, corrupted/lost run, resurrection, duplicate result, progression dead end, or policy mismatch.
- P1: unreadable/blocked input, misleading odds, unexplained death, broken onboarding, or severe balance failure.
- P2: repeated friction, excessive taps, weak hierarchy, or pacing problem.
- P3: isolated cosmetic preference.

Release requires zero known P0/P1 issues, all automated checks passing, completed policy/listing assets, a signed AAB, at least 12 continuous testers for 14 days, and production access. External approval time is not under project control.

## Deferred work

Shops, salvage currency, six new items, merchant events, dynamic map nodes, billing, and AdMob remain post-launch work. The in-game shop currency must be run-only and unrelated to paid cosmetics.
