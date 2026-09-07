# Monetization integration

Monetization is optional infrastructure around an offline game. A missing connection, denied consent, no-fill, plugin exception, store outage, or verification timeout must never delay a choice, checkpoint, save, death, restart, or complete run.

Version 1 launches free with `ashfall/release/monetization_enabled=false`. The settings store and ad status are hidden, both service facades refuse activation, and no ad or billing plugin is bundled. Everything below is deferred post-launch work and requires updated privacy/Data Safety/ads declarations before the flag may change.

## Current implementation boundary

- `AdService` owns eligibility: only completed regions 2 and 4, at most two per run, at least ten minutes apart, never replay a missed opportunity, and disabled by cached Remove Ads ownership.
- `BillingService` owns the product allowlist, cached ownership checks, offline store status, and the callback boundary for a future Android billing adapter.
- The settings UI lists products only when the post-launch monetization feature flag is deliberately enabled.
- `backend/functions` verifies purchases with Google, requires Firebase App Check, accepts only allowlisted products, grants only completed purchases, stores a token hash rather than a raw token, and acknowledges the purchase server-side.

The Android plugins and store credentials are deliberately not bundled. Pin exact plugin commits/releases only after an isolated Godot 4.7/API 36 test succeeds.

## Advertising integration sequence

1. Select a maintained Godot Android AdMob plugin that explicitly supports Godot 4.7, custom Gradle export, API 36, and UMP.
2. Record its version, source URL, license, transitive SDK versions, and rollback instructions.
3. Create a separate blank compatibility-renderer project and prove one test interstitial plus the UMP privacy-options entry point.
4. Use Google's sample/test ad unit IDs on every development, internal-test, and closed-test build.
5. At app launch, ask UMP to refresh consent state. Request an ad only after `canRequestAds()` permits it. If consent update fails, respect the previously cached UMP state; otherwise skip ads.
6. Load ahead of the region 2 or 4 checkpoint, but do not block the checkpoint waiting for a response.
7. At the opportunity, call the provider once. On load error, no-fill, timeout, consent refusal, backgrounding, or offline state, mark that opportunity attempted and continue immediately.
8. Count an ad as shown only after the provider's presentation callback.
9. Never queue a missed ad to surprise the player later.
10. When verified Remove Ads is present, do not initialize/request an ad. UMP privacy options may still remain available if required.

Official UMP setup: <https://developers.google.com/admob/android/privacy>

## Billing products

| Entitlement | Play product ID | Type |
|---|---|---|
| Remove Ads | `ashfall_remove_ads` | Non-consumable |
| Cinder Rust Theme | `ashfall_theme_rust` | Non-consumable |
| Signal at Night Theme | `ashfall_theme_night` | Non-consumable |
| Supporter Bundle | `ashfall_supporter_bundle` | Non-consumable |

No product changes stats, odds, resources, survivability, resurrection, or run progression.

## Purchase flow

1. Query Google Play for product details and show Play-provided localized prices; do not hardcode prices.
2. Start the purchase through the Android adapter.
3. For pending purchases, show Pending and grant nothing.
4. Send the completed purchase token and product ID to the Firebase verification endpoint.
5. The backend verifies package, product, token, uniqueness/state, records the hash, and acknowledges if needed.
6. Only a verified response can replace the local entitlement snapshot and persist it through `SaveService`.
7. On launch/store-open while online, query already-owned purchases and re-verify them. Replacing—not only merging—the snapshot lets refunded ownership disappear after reconciliation.
8. When offline, show the store unavailable but continue honoring the most recent verified non-expiring snapshot.
9. Never include a Play service-account key or verification secret in the APK.

Official guidance says to verify before granting, grant only when state is purchased, handle pending separately, and acknowledge purchases; secure backend verification is recommended:

- <https://developer.android.com/google/play/billing/integrate>
- <https://developer.android.com/google/play/billing/security>

## Backend readiness

The TypeScript backend passes `tsc --noEmit`. Its package audit currently reports moderate advisories in transitive Google Cloud `uuid` dependencies, with no safe non-breaking automatic resolution offered by npm. Re-run `npm audit --omit=dev` immediately before deployment and upgrade Firebase/Google libraries when upstream fixes are available. Do not use `npm audit fix --force` blindly.

Production additionally requires Firebase App Check/Play Integrity, Android Publisher API access, a permanent package ID, service-account permissions, deployed HTTPS endpoint, Play license testers, refund reconciliation, and Real-time Developer Notifications or periodic voided-purchase reconciliation.
