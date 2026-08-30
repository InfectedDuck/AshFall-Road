# Google Play and user-acquisition roadmap

Do not buy the Play Console account merely to continue development. Buy/register after the vertical slice is understandable and stable enough for external testing, because coding, desktop play, local APK export, and direct device installation do not require a Play developer account.

## Milestone 1: device-ready vertical slice

- Connect a physical phone and pass the first-phone checklist in `ANDROID_SETUP.md`.
- Complete 20 short runs across fixed seeds without contradictory state.
- Give a fresh APK to 3–5 nearby testers by direct install.
- Observe without coaching: candidate choice, event odds, inventory use, checkpoint rest, death, and restart.
- Fix every comprehension blocker, save loss, clipped control, and accidental back-navigation issue.
- Test largest font, high contrast, reduced motion, sound/haptics off, and airplane mode.

Gate: a new tester plays 15–30 minutes, dies, restarts, and can explain why major outcomes happened.

## Milestone 2: balance and presentation

- Run all automated checks after every rules/content change.
- Play at least three viable strategy families: physical/armor, agile/ranged, and wits/presence/utility.
- Track event selection rates, deaths by region, chosen approaches, unused items, and dominant choices from opt-in tester notes—not an external analytics SDK.
- Test on a small/tall screen and one lower-end Android device.
- Replace placeholder store/package/support/privacy information.
- Capture real-device screenshots for candidate selection, pressures, a hard choice, visible dice math, inventory, and permadeath.

Gate: no single approach dominates most events and no item is mandatory for every winning route.

## Milestone 3: monetization isolation

- Pin and license-review Godot AdMob/UMP and Play Billing plugins.
- Prove each plugin alone in a blank API 36 custom-Gradle project.
- Integrate through the existing facades, never directly from event/UI calculation code.
- Deploy verification backend to a non-production Firebase project and enable App Check/Play Integrity.
- Use test ad IDs and Play license testers only.
- Exercise offline, pending, cancelled, restored, refunded, duplicate, already-owned, no-fill, timeout, and consent-refusal cases.

Gate: airplane mode permits a complete run, store/ad failures never block it, and previously verified ownership survives death/restart.

## Milestone 4: Play Console setup

- Register the developer account and complete identity/device verification.
- Choose the permanent package ID before the first upload; replace the repository placeholder everywhere.
- Enable Play App Signing and create/back up the upload keystore.
- Upload the signed AAB to internal testing.
- Create all four products and configure license testers.
- Complete support contact, privacy-policy URL, Data Safety, ads declaration, target audience, IARC rating, app access, content declarations, store listing, and asset-license record.
- Declare teens/adults, not children under 13, and ensure ad serving matches that declaration.
- Verify the target API again at upload time. As of 30 August 2026, new apps must target API 36.

## Milestone 5: required closed test

Google's current rule applies to personal accounts created after 13 November 2023: at least 12 testers must remain opted in continuously for the preceding 14 days before production access can be requested. Official source: <https://support.google.com/googleplay/android-developer/answer/14151465?hl=en-GB>.

- Recruit 15–20 genuine RPG/roguelike players so dropouts do not take the count below 12.
- Avoid tester-exchange services, review farms, paid ratings, or asking for positive reviews.
- Give testers a feedback form covering device, session length, region reached, understood odds, confusing screen, most/least useful item, crash/save issue, and whether they voluntarily started another run.
- Keep at least 12 continuously opted in for the full 14 days; replacing a dropout does not retroactively satisfy continuity.
- Ship only necessary closed-test fixes and document version code/date/feedback.
- After the requirement is met, apply for production access with concrete answers about recruitment, engagement, bugs found, and fixes made.

## Milestone 6: production launch

- Start with a small staged rollout, then monitor crashes, ANRs, reviews, acquisition, and uninstalls in Play Console.
- Maintain a rollback-ready previous AAB and do not rotate/lose the upload key.
- Respond to reproducible data-loss/purchase-loss issues before marketing.
- Re-run offline, death, restore, consent, ad-removal, and refund checks on the exact production candidate.

## First 100 legitimate users

- Begin a mechanics-focused development log in the permitted weekly threads of r/roguelikedev and participate before sharing links.
- Contact small traditional-roguelike, interactive-fiction-adjacent, tabletop/D20, and offline-mobile communities whose rules allow developer posts.
- Post short clips that each demonstrate one mechanic: equal-budget survivors, visible odds, ammunition tradeoff, pressure penalty, critical outcome, or permadeath.
- Make the store's first three screenshots communicate genre, decision math, and inventory—not scenery alone.
- Position the game consistently: “offline, mechanics-first post-apocalyptic D20 roguelike; strict permadeath; no paid resurrection.”
- Ask closed testers who voluntarily begin multiple runs for a candid store review only after production; never gate rewards on reviews.
- Consider a free Windows/web demo after Android content is stable.
- Once store traffic is meaningful, A/B test icon, feature graphic, and screenshot ordering.
- Do not buy ads until organic testers replay voluntarily and crash/save/purchase severity bugs are zero.

Initial objective: 100 legitimate installs and 20 useful feedback responses in the first 30 days.
