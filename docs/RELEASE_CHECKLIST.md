# Release checklist

Run this checklist against the exact AAB intended for Google Play. Never treat a locally installed debug APK as release proof.

## Identity and signing - owner required

- [ ] Play Console developer identity and physical device are verified.
- [ ] Permanent reverse-domain package ID replaces `com.yourstudio.ashfallroad` in both Android presets.
- [ ] Upload keystore and alias are configured without committing passwords or key material.
- [ ] Two secure backups of the upload key exist.
- [ ] Play App Signing is enabled.
- [ ] Version code is higher than every previously uploaded artifact.

## Binary

- [ ] Godot 4.7.2 and matching export templates are used.
- [ ] Release output is AAB, arm64, portrait, Compatibility renderer, minimum SDK 24, target API 36.
- [ ] Monetization launch flag is false.
- [ ] No AdMob, UMP, Google Play Billing, analytics, debug, or unintended permission is present.
- [ ] Clean install and upgrade install pass through Google Play testing.
- [ ] Fresh airplane-mode launch and a complete offline run pass.

## Automated and data safety

- [ ] Headless suite exits zero.
- [ ] Editor import/parser check exits zero.
- [ ] Balance report completes without content errors.
- [ ] Release-readiness audit has no blocker.
- [ ] Death-marker, prepared-roll, combat-round, migration, and deterministic-run tests pass.
- [ ] Active-run files cannot be restored through Android backup/device transfer.

## Human mobile matrix

- [ ] Samsung physical-device pass.
- [ ] At least one lower-end phone pass.
- [ ] 360x640-equivalent, 393x852 (the design-canvas artboard), and tall portrait layouts pass.
- [ ] Small, normal, and large text pass.
- [ ] High Contrast and Reduced Motion pass.
- [ ] Every overlay closes with `X` and Android Back in the documented order.
- [ ] Force-close before/during/after event rolls, combat rounds, inventory actions, checkpoints, death, and victory does not duplicate or lose state.

## Store and policy - owner required

- [ ] Completed privacy policy exists in the app and at the submitted public URL.
- [ ] Data Safety exactly matches the binary.
- [ ] Ads declaration is No for this release.
- [ ] App access states that no account is required.
- [ ] Target audience is teens/adults, not children.
- [ ] IARC questionnaire accurately describes non-graphic post-apocalyptic violence and permadeath.
- [ ] Support email, developer identity, free pricing, countries, and game category are correct.
- [ ] 512x512 icon, 1024x500 feature graphic, and six real-device screenshots are final and truthful.
- [ ] Font, sound, background, icon, screenshot-overlay, and other asset provenance is recorded.

## Testing and production access - owner required

- [ ] Closed build is stable enough for real use.
- [ ] 15-20 legitimate testers were recruited without review manipulation.
- [ ] At least 12 testers remained continuously opted in for 14 full days.
- [ ] At least eight useful feedback responses were recorded.
- [ ] Feedback, fixes, versions, and dates are documented for the production-access application.
- [ ] Production access is granted before attempting a public rollout.

## Hard stop

Any known crash/ANR, save loss, dead-run resurrection, duplicate action/reward, progression dead end, invisible choice, trapped overlay, materially misleading percentage, severe unreadability, or policy mismatch blocks release.
