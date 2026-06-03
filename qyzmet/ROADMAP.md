# Qyzmet Product Roadmap

## Vision

Qyzmet is Kazakhstan's premier home services marketplace — connecting clients with verified, professional service providers for cleaning, repair, beauty, childcare, and more.

---

## V1.0 — Foundation (Month 1–3)

**Goal:** Validate the core marketplace loop in Almaty.

### Core Features

#### Client App
- [x] Phone + Google + Apple authentication
- [x] Service category browsing
- [x] Provider search with filters (city, rating, price)
- [x] Provider profile view with reviews
- [x] Booking flow with date/time selection
- [x] Stripe payment (cards)
- [x] Booking history
- [x] Push notifications (booking updates)
- [x] Russian + Kazakh + English localization

#### Provider App
- [x] Provider registration & profile setup
- [x] Identity verification (ID upload)
- [x] Service listing management
- [x] Booking request accept/decline
- [x] Calendar view
- [x] Earnings dashboard
- [x] Stripe Connect payout setup

#### Admin Panel
- [x] Provider verification workflow
- [x] User management
- [x] Booking oversight
- [x] Dispute resolution
- [x] Real-time stats dashboard

#### Infrastructure
- [x] Firebase (Auth, Firestore, Storage, FCM)
- [x] Cloud Functions (payments, notifications)
- [x] Firestore security rules
- [x] CI/CD pipeline (GitHub Actions)

### V1 Launch Targets
- 50 verified providers (Almaty)
- 5 service categories: cleaning, repair, beauty, childcare, tutoring
- 200 registered users
- App Store + Play Store listings

---

## V2.0 — Growth (Month 4–6)

**Goal:** Increase retention, expand categories, improve trust.

### Client Features
- [ ] **In-app chat** — real-time messaging with providers
- [ ] **Loyalty program** — Qyzmet Points for repeat bookings
- [ ] **Referral system** — invite friends, earn credits
- [ ] **Saved providers** — favorites list
- [ ] **Recurring bookings** — weekly/bi-weekly repeat
- [ ] **Multiple addresses** — home, office, parents' home
- [ ] **Service bundles** — package deals (e.g., 4 cleanings)
- [ ] **Review photos** — attach photos to reviews
- [ ] **Live tracking** — see when provider is en route (GPS)
- [ ] **Wallet** — Qyzmet balance for faster checkout

### Provider Features
- [ ] **Portfolio** — before/after photos
- [ ] **Availability calendar sync** — Google Calendar integration
- [ ] **Multi-service listing** — offer multiple service types
- [ ] **Team mode** — bring assistants, split earnings
- [ ] **Analytics** — views, conversion rate, earnings chart
- [ ] **Custom pricing** — surge pricing on weekends/holidays
- [ ] **Certificate upload** — education, professional certs

### Platform
- [ ] **Kaspi Pay integration** — dominant KZ payment method
- [ ] **Halyk Bank integration** — second option
- [ ] **SMS notifications** — fallback for no-internet users
- [ ] **Web app (PWA)** — browser-based booking
- [ ] **Promo codes & discounts** — admin-managed campaigns
- [ ] **Subscription plans** — monthly provider subscription tiers
- [ ] **Expand to Astana** — second city launch

### Admin
- [ ] **Revenue analytics** — charts, cohorts
- [ ] **Fraud detection** — automated suspicious activity flags
- [ ] **Bulk notifications** — campaign push notifications
- [ ] **Provider onboarding flow** — guided setup checklist

---

## V3.0 — Scale (Month 7–12)

**Goal:** National expansion, enterprise clients, platform maturity.

### Client Features
- [ ] **Video consultations** — pre-booking video call with provider
- [ ] **AI service recommendations** — personalized home for each user
- [ ] **Smart home integration** — book via voice (Google/Alexa)
- [ ] **Corporate accounts** — companies book services for employees
- [ ] **Gift cards** — give a Qyzmet booking as a gift
- [ ] **Home profile** — save home size, floors, notes for providers
- [ ] **Emergency services** — 2-hour emergency booking with premium

### Provider Features
- [ ] **Provider app (standalone)** — separate dedicated provider app
- [ ] **Business account** — register a cleaning/repair company
- [ ] **Lead marketplace** — buy leads, not just accept requests
- [ ] **Provider training** — in-app courses for quality improvement
- [ ] **Insurance** — partnership with insurer for service guarantee

### Platform
- [ ] **National expansion** — Shymkent, Karaganda, Aktobe
- [ ] **B2B marketplace** — corporate clients, property managers
- [ ] **API for third-parties** — embed Qyzmet booking in other apps
- [ ] **Franchise model** — city operator partnerships
- [ ] **KYC automation** — AI-powered document verification
- [ ] **Multi-currency** — KZT, USD for expats
- [ ] **Central Asia expansion** — Kyrgyzstan, Uzbekistan

### Tech
- [ ] **ML recommendation engine** — best provider for each user
- [ ] **Automated dispute resolution** — ML-assisted decisions
- [ ] **Real-time dynamic pricing** — demand-based pricing
- [ ] **Provider quality scoring** — automated quality signals
- [ ] **Fraud ML model** — payment fraud prevention

---

## Key Metrics

| Metric | V1 Target | V2 Target | V3 Target |
|--------|-----------|-----------|-----------|
| Registered users | 500 | 5,000 | 50,000 |
| Active providers | 50 | 500 | 5,000 |
| Monthly bookings | 200 | 2,000 | 20,000 |
| Monthly GMV | 1.6M KZT | 16M KZT | 160M KZT |
| Cities | 1 | 2 | 5+ |
| App Store rating | — | 4.3+ | 4.5+ |
| Provider retention (3mo) | — | 60% | 75% |
| Client repeat rate | — | 40% | 55% |

---

## Technical Debt & Quality

### Ongoing (each sprint)
- Unit test coverage > 70%
- Crashlytics P0 bugs fixed within 24h
- Performance: app cold start < 3 seconds
- Accessibility audit (every release)
- Security review (quarterly)
- Firebase rules review (monthly)

---

*Last updated: June 2026*
