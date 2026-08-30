# Purchase-verification backend

This Firebase Functions project is the production trust boundary for the four non-consumable Google Play products. It accepts a product ID and purchase token, requires Firebase App Check, verifies the token with the Google Play Developer API, records only a SHA-256 token hash, acknowledges a completed purchase, and returns the verified entitlement.

It is intentionally not required by normal gameplay. When the device is offline or verification is unavailable, the store remains closed and the last locally verified non-expiring entitlements remain usable.

## Before deployment

1. Replace `com.yourstudio.ashfallroad` everywhere with the permanent Play package ID.
2. Create a Firebase project linked to the Android app and enable Play Integrity for App Check.
3. Link the Google Cloud project to Play Console, enable the Android Publisher API, and grant the Functions runtime service account the minimum Play Console permission needed to view and manage orders.
4. From `backend/functions`, install dependencies and run `npm run check`.
5. Set the `ANDROID_PACKAGE_NAME` Functions parameter and deploy.
6. Put only the HTTPS endpoint and Firebase public configuration in the game. Never ship a service-account key.

The client must grant an entitlement only for a `verified: true` response and only after Google reports the purchase as completed. Pending, cancelled, refunded, missing, and verification-error states grant nothing. On every online store restore, replace the cached ownership snapshot so a refunded item is removed; while offline, keep the most recently verified snapshot.
