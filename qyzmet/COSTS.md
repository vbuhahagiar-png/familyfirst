# Qyzmet Cost Estimation

## Firebase Pricing

### Spark Plan (Free Tier Limits)

| Service | Free Limit |
|---------|-----------|
| Firestore reads | 50,000/day |
| Firestore writes | 20,000/day |
| Firestore deletes | 20,000/day |
| Storage | 5 GB |
| Cloud Functions | 2M invocations/month |
| Authentication | Unlimited |
| Hosting | 10 GB/month |
| FCM (Push) | Unlimited |

**Cloud Functions require Blaze plan.**

### Blaze Plan (Pay-as-you-go)

| Service | Price | Free Tier |
|---------|-------|-----------|
| Firestore reads | $0.06/100K | 50K/day |
| Firestore writes | $0.18/100K | 20K/day |
| Firestore storage | $0.18/GB/month | 1 GB |
| Cloud Functions | $0.40/M invocations | 2M/month |
| Storage | $0.026/GB/month | 5 GB |
| Storage transfer | $0.12/GB | 1 GB/day |

---

## Stripe Fees

### Standard Kazakhstan Rates

| Fee Type | Rate |
|----------|------|
| Per transaction | 1.5% + 75 KZT |
| Connect transfer | 0.25% (capped at 2,000 KZT) |
| Instant payout | 1% |
| Refund | 75 KZT (processing fee) |

### Qyzmet Commission Model

Qyzmet charges **15%** platform fee per booking.
Provider receives **85%** of booking amount.

Stripe fee comes out of the platform's 15%.

**Example: 10,000 KZT booking**
- Stripe fee: (10,000 × 1.5%) + 75 = 225 KZT
- Qyzmet net commission: 1,500 - 225 = **1,275 KZT**
- Provider payout: **8,500 KZT**

---

## Monthly Cost Scenarios

### Scenario 1: 100 Bookings/Month (Early Stage)

Assumptions:
- Average booking: 8,000 KZT
- Firestore ops: ~50 reads/write per booking
- Functions: ~10 invocations per booking

| Item | Cost |
|------|------|
| Firestore (within free tier) | $0 |
| Cloud Functions | $0 (within 2M free) |
| Firebase Storage (docs/photos) | ~$0.50 |
| Stripe fees (100 × 225 KZT avg) | ~22,500 KZT ($50) |
| **Total infrastructure** | **~$1–2/month** |
| **Gross revenue (15% of 800K KZT)** | **~120,000 KZT ($267)** |
| **Net after Stripe** | **~97,500 KZT ($217)** |

### Scenario 2: 1,000 Bookings/Month (Growth)

| Item | Cost |
|------|------|
| Firestore reads (exceeded free) | ~$5 |
| Firestore writes | ~$2 |
| Cloud Functions | $0 |
| Firebase Storage | ~$2 |
| Stripe fees (1,000 × 225 KZT avg) | ~225,000 KZT ($500) |
| **Total infrastructure** | **~$510/month** |
| **Gross revenue (15% of 8M KZT)** | **~1,200,000 KZT ($2,667)** |
| **Net after Stripe** | **~975,000 KZT ($2,167)** |

### Scenario 3: 10,000 Bookings/Month (Scale)

| Item | Cost |
|------|------|
| Firestore reads | ~$50 |
| Firestore writes | ~$20 |
| Cloud Functions | ~$2 |
| Firebase Storage | ~$15 |
| Stripe fees (10K × 225 KZT avg) | ~2,250,000 KZT ($5,000) |
| **Total infrastructure** | **~$5,087/month** |
| **Gross revenue (15% of 80M KZT)** | **~12,000,000 KZT ($26,667)** |
| **Net after Stripe + infra** | **~9,730,000 KZT ($21,622)** |

---

## Additional Costs to Consider

| Item | Estimated Cost |
|------|---------------|
| Apple Developer Account | $99/year |
| Google Play Developer | $25 one-time |
| Domain (qyzmet.kz) | ~$15/year |
| SSL Certificate | Free (Let's Encrypt) |
| Customer support tool | $0–50/month |
| Email service (SendGrid) | Free tier initially |
| Analytics (Mixpanel/Amplitude) | Free tier initially |

---

## Cost Optimization Tips

1. **Batch Firestore writes** — use `WriteBatch` to reduce write count
2. **Cache frequently read data** in app state management
3. **Use Firestore offline persistence** to reduce reads
4. **Compress images** before upload to Storage
5. **Set up Firestore TTL** to auto-delete old notifications (Firestore 6mo TTL)
6. **Use Firebase Emulator** during development to avoid costs
7. **Set budget alerts** in Firebase console at $10, $50, $100

---

## Break-Even Analysis

| Monthly bookings needed to cover $100 infra | ~50 bookings |
| Monthly bookings for $1,000 net profit | ~350 bookings |
| Monthly bookings for $10,000 net profit | ~3,500 bookings |
