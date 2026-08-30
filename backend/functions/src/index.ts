import { createHash } from "node:crypto";
import { getAppCheck } from "firebase-admin/app-check";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { initializeApp } from "firebase-admin/app";
import { onRequest } from "firebase-functions/v2/https";
import { defineString } from "firebase-functions/params";
import { google } from "googleapis";

initializeApp();

const packageName = defineString("ANDROID_PACKAGE_NAME");
const productToEntitlement = {
  ashfall_remove_ads: "remove_ads",
  ashfall_theme_rust: "theme_rust",
  ashfall_theme_night: "theme_night",
  ashfall_supporter_bundle: "supporter",
} as const;

type ProductId = keyof typeof productToEntitlement;

interface VerificationRequest {
  productId?: string;
  purchaseToken?: string;
}

export const verifyPlayPurchase = onRequest(
  { region: "asia-east1", timeoutSeconds: 30, memory: "256MiB" },
  async (request, response) => {
    if (request.method !== "POST") {
      response.status(405).json({ verified: false, error: "method_not_allowed" });
      return;
    }

    const appCheckToken = request.header("X-Firebase-AppCheck");
    if (!appCheckToken) {
      response.status(401).json({ verified: false, error: "app_check_required" });
      return;
    }

    try {
      await getAppCheck().verifyToken(appCheckToken);
    } catch {
      response.status(401).json({ verified: false, error: "invalid_app_check" });
      return;
    }

    const body = (request.body ?? {}) as VerificationRequest;
    const productId = body.productId as ProductId;
    const purchaseToken = body.purchaseToken?.trim() ?? "";
    if (!(productId in productToEntitlement) || purchaseToken.length < 20 || purchaseToken.length > 4096) {
      response.status(400).json({ verified: false, error: "invalid_request" });
      return;
    }

    try {
      const auth = new google.auth.GoogleAuth({
        scopes: ["https://www.googleapis.com/auth/androidpublisher"],
      });
      const publisher = google.androidpublisher({ version: "v3", auth });
      const purchase = await publisher.purchases.products.get({
        packageName: packageName.value(),
        productId,
        token: purchaseToken,
      });

      if (purchase.data.purchaseState !== 0) {
        response.status(409).json({
          verified: false,
          state: purchase.data.purchaseState === 2 ? "pending" : "cancelled",
        });
        return;
      }

      const tokenHash = createHash("sha256").update(purchaseToken).digest("hex");
      const purchaseReference = getFirestore().collection("verified_play_purchases").doc(tokenHash);
      await purchaseReference.set(
        {
          packageName: packageName.value(),
          productId,
          entitlementId: productToEntitlement[productId],
          orderId: purchase.data.orderId ?? null,
          purchaseTimeMillis: purchase.data.purchaseTimeMillis ?? null,
          acknowledgementState: purchase.data.acknowledgementState ?? 0,
          lastVerifiedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      if (purchase.data.acknowledgementState !== 1) {
        await publisher.purchases.products.acknowledge({
          packageName: packageName.value(),
          productId,
          token: purchaseToken,
          requestBody: {},
        });
        await purchaseReference.update({
          acknowledgementState: 1,
          acknowledgedAt: FieldValue.serverTimestamp(),
        });
      }

      response.status(200).json({
        verified: true,
        entitlementId: productToEntitlement[productId],
        productId,
        verifiedAt: Date.now(),
      });
    } catch (error) {
      console.error("Play purchase verification failed", {
        productId,
        error: error instanceof Error ? error.message : "unknown_error",
      });
      response.status(502).json({ verified: false, error: "verification_unavailable" });
    }
  },
);
