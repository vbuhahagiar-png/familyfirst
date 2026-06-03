# Qyzmet Deployment Guide

## Prerequisites

- Flutter SDK 3.19+
- Node.js 20+
- Firebase CLI (`npm install -g firebase-tools`)
- Xcode 15+ (for iOS)
- Android Studio / JDK 17 (for Android)

---

## 1. Firebase Project Setup

### 1.1 Create Firebase Project

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click "Add project" → Name: `qyzmet-app`
3. Enable Google Analytics

### 1.2 Enable Services

```
Authentication → Sign-in method:
  ✓ Phone
  ✓ Google
  ✓ Apple

Firestore Database → Create database → Production mode
Storage → Get started → Production mode
Cloud Messaging → Auto-enabled
```

### 1.3 Add Apps

**Android:**
1. Add Android app → Package: `kz.qyzmet.app`
2. Download `google-services.json` → place at `android/app/google-services.json`

**iOS:**
1. Add iOS app → Bundle ID: `kz.qyzmet.app`
2. Download `GoogleService-Info.plist` → place at `ios/Runner/GoogleService-Info.plist`
3. Copy `REVERSED_CLIENT_ID` from plist → update `ios/Runner/Info.plist`

**Web (Admin Panel):**
1. Add Web app → Nickname: `qyzmet-admin`
2. Copy config → update `admin/js/firebase-config.js`

### 1.4 Deploy Firestore Rules & Indexes

```bash
cd qyzmet
firebase login
firebase use qyzmet-app
firebase deploy --only firestore,storage
```

### 1.5 Set Billing Plan

Upgrade to **Blaze (pay-as-you-go)** to enable Cloud Functions.

---

## 2. Stripe Connect Setup

### 2.1 Create Stripe Account

1. Go to [dashboard.stripe.com](https://dashboard.stripe.com)
2. Create account for Kazakhstan

### 2.2 Enable Stripe Connect

1. Dashboard → Connect → Get started
2. Platform type: **Marketplace**
3. Enable for Kazakhstan

### 2.3 Configure Functions

```bash
firebase functions:secrets:set STRIPE_SECRET_KEY
# Enter: sk_live_... (or sk_test_... for testing)

firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
# Enter webhook signing secret from Stripe dashboard
```

### 2.4 Set Stripe in App

In `lib/config/app_constants.dart`:
```dart
static const stripePublishableKey = 'pk_live_...'; // your key
```

### 2.5 Android Redirect

The `qyzmet://` scheme is already configured in `AndroidManifest.xml`.

### 2.6 iOS Redirect

The `qyzmet` URL scheme is already configured in `Info.plist`.

---

## 3. Google Sign-In Setup

### Android

1. In Firebase Console → Authentication → Sign-in method → Google → Enable
2. SHA-1 fingerprint is auto-configured via `google-services.json`

### iOS

1. Download `GoogleService-Info.plist`
2. Copy `REVERSED_CLIENT_ID` value
3. Replace `REVERSED_CLIENT_ID_PLACEHOLDER` in `ios/Runner/Info.plist`

---

## 4. Apple Sign-In Setup

### Requirements

- Apple Developer account ($99/year)
- App ID with Sign In with Apple capability

### Steps

1. Apple Developer → Identifiers → `kz.qyzmet.app`
2. Enable "Sign In with Apple" capability
3. Firebase Console → Authentication → Apple → configure
4. In Xcode: Signing & Capabilities → "+ Capability" → Sign In with Apple

---

## 5. Push Notifications

### Android (FCM)

Auto-configured via `google-services.json` and `FirebaseMessagingService` in manifest.

### iOS (APNs)

1. Apple Developer → Certificates → APNs Auth Key (`.p8`)
2. Firebase Console → Project Settings → Cloud Messaging → iOS → upload APNs key
3. In Xcode: Signing & Capabilities → Push Notifications + Background Modes (remote notifications)

---

## 6. Environment Variables

### GitHub Actions Secrets

| Secret | Description |
|--------|-------------|
| `FIREBASE_TOKEN` | From `firebase login:ci` |
| `STRIPE_SECRET_KEY` | Stripe live secret key |

### Local Development

Create `qyzmet/.env` (not committed):
```
STRIPE_PUBLISHABLE_KEY=pk_test_...
FIREBASE_EMULATOR=true
```

---

## 7. Deploy Cloud Functions

```bash
cd qyzmet/functions
npm install
npm run build

cd ..
firebase deploy --only functions
```

---

## 8. Deploy Admin Panel

```bash
# Option A: Firebase Hosting
firebase deploy --only hosting

# Option B: Any static host
# Upload /admin/ directory to Netlify, Vercel, etc.
```

Add to `firebase.json`:
```json
"hosting": {
  "public": "admin",
  "ignore": ["firebase.json", "**/node_modules/**"],
  "rewrites": [{"source": "**", "destination": "/index.html"}]
}
```

---

## 9. Play Store Submission Checklist

- [ ] App signed with release keystore
- [ ] `versionCode` incremented in pubspec.yaml
- [ ] Screenshots (phone + tablet): 2-8 per device
- [ ] Feature graphic (1024x500px)
- [ ] App icon (512x512px)
- [ ] Privacy Policy URL
- [ ] Content rating questionnaire
- [ ] Target SDK = 34 (Android 14)
- [ ] 64-bit APK / App Bundle (AAB)
- [ ] Data safety form completed
- [ ] `flutter build appbundle --release`

### Signing

```bash
keytool -genkey -v -keystore qyzmet-release.keystore \
  -alias qyzmet -keyalg RSA -keysize 2048 -validity 10000

# Add to android/key.properties:
storePassword=<password>
keyPassword=<password>
keyAlias=qyzmet
storeFile=../../qyzmet-release.keystore
```

---

## 10. App Store Submission Checklist

- [ ] Apple Developer account active
- [ ] Bundle ID registered: `kz.qyzmet.app`
- [ ] App signed with Distribution certificate
- [ ] Provisioning profile (App Store distribution)
- [ ] Screenshots: iPhone 6.7" + 6.5" (required), iPad 12.9" (if universal)
- [ ] App icon 1024x1024px (no alpha channel)
- [ ] Privacy Policy URL
- [ ] App Privacy nutrition labels filled
- [ ] Export compliance (HTTPS = standard encryption)
- [ ] Age rating questionnaire
- [ ] `flutter build ipa --release`
- [ ] Upload via Xcode Organizer or `xcrun altool`

---

## 11. Post-Launch

1. Enable Firebase Performance Monitoring
2. Set up Crashlytics alerts
3. Configure Firestore backups (daily)
4. Set up uptime monitoring for Cloud Functions
5. Review Firebase Security Rules after 1 month of usage
