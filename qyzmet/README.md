# Qyzmet - Book. Pay. Relax.

> Home services booking platform for Kazakhstan 🇰🇿

Qyzmet (meaning "service" in Kazakh) is a marketplace connecting clients with verified home service professionals in Astana, Kazakhstan. Think Uber/Booking.com for home services.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x |
| Backend | Firebase (Firestore, Auth, Storage, Functions) |
| Payments | Stripe Connect |
| State | Flutter Riverpod 2.x |
| Navigation | GoRouter 13.x |
| Languages | Russian (default), Kazakh, English |

---

## Features

### Client App
- Browse and search service professionals by category
- View provider profiles with photos, ratings, and reviews
- Book services with date/time/duration picker
- Secure payment via Stripe (card, Apple Pay, Google Pay)
- Booking history and status tracking
- Loyalty program (Standard → Silver → Gold)
- Multi-language support (RU/KK/EN)

### Provider App
- Dashboard with earnings overview
- Accept/decline booking requests
- Calendar view of scheduled work
- Availability management
- Earnings analytics
- Stripe Connect for payouts

### Service Categories
- 🧹 Cleaning
- 👶 Babysitting
- 🔧 Repairs / Handyman
- 🏗️ Renovation
- 🚿 Plumbing
- ⚡ Electrical
- 🌱 Gardening
- 📦 Moving

---

## Project Structure

```
qyzmet/
├── lib/
│   ├── main.dart              # App entry point
│   ├── app.dart               # MaterialApp with routing
│   ├── firebase_options.dart  # Firebase config (replace with yours)
│   ├── config/                # Colors, theme, constants
│   ├── core/
│   │   ├── models/            # Firestore data models
│   │   ├── services/          # Firebase/Stripe services
│   │   └── utils/             # Validators, formatters, helpers
│   ├── features/
│   │   ├── auth/              # Splash, onboarding, login, register
│   │   ├── client/            # Home, search, booking, payment
│   │   ├── provider/          # Dashboard, bookings, earnings
│   │   └── shared/            # Reusable widgets
│   ├── navigation/            # GoRouter configuration
│   └── l10n/                  # ARB translation files
├── functions/                 # Firebase Cloud Functions (TypeScript)
│   └── src/
│       ├── stripe/            # Payment processing
│       ├── bookings/          # Booking triggers
│       └── notifications/     # Push notifications
├── firestore.rules            # Security rules
├── firestore.indexes.json     # Database indexes
└── storage.rules              # Storage security rules
```

---

## Setup

### Prerequisites
- Flutter SDK >= 3.0.0
- Firebase project
- Stripe account (for payments)
- Node.js 18+ (for Cloud Functions)

### 1. Flutter Setup

```bash
cd qyzmet
flutter pub get
```

### 2. Firebase Configuration

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase project
flutterfire configure
```

This generates `lib/firebase_options.dart` with your actual credentials.

### 3. Stripe Configuration

1. Create a Stripe account at stripe.com
2. Replace `pk_test_YOUR_STRIPE_KEY` in `lib/config/app_constants.dart`
3. Set environment variables for Cloud Functions:

```bash
firebase functions:secrets:set STRIPE_SECRET_KEY
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
```

### 4. Deploy Cloud Functions

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

### 5. Deploy Firestore Rules & Indexes

```bash
firebase deploy --only firestore
```

### 6. Run the App

```bash
flutter run
```

---

## Business Model

- **Commission**: 15% on each booking
- **Currency**: KZT (Kazakhstani Tenge)
- **Launch city**: Astana, Kazakhstan
- **Payout**: Weekly transfers to providers via Stripe Connect

---

## Loyalty Program

| Level | Bookings Required | Discount |
|-------|------------------|---------|
| Standard | 0 | 0% |
| Silver 🥈 | 5+ | 5% |
| Gold 🥇 | 15+ | 10% |

---

## Environment Variables

Create `.env` (never commit this):
```
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
GOOGLE_MAPS_API_KEY=AIza...
```

---

## Contributing

Built with ❤️ for Kazakhstan. Qyzmet - Book. Pay. Relax.
