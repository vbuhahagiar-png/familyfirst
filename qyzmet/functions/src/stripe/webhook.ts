import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
  apiVersion: '2024-12-18.acacia',
});

const WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET || '';

export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];

  if (!sig) {
    res.status(400).send('Missing stripe-signature header');
    return;
  }

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, WEBHOOK_SECRET);
  } catch (err) {
    functions.logger.error('Webhook signature verification failed:', err);
    res.status(400).send(`Webhook Error: ${(err as Error).message}`);
    return;
  }

  try {
    switch (event.type) {
      case 'payment_intent.succeeded': {
        const paymentIntent = event.data.object as Stripe.PaymentIntent;
        await handlePaymentSuccess(paymentIntent);
        break;
      }

      case 'payment_intent.payment_failed': {
        const paymentIntent = event.data.object as Stripe.PaymentIntent;
        await handlePaymentFailed(paymentIntent);
        break;
      }

      case 'account.updated': {
        const account = event.data.object as Stripe.Account;
        await handleAccountUpdated(account);
        break;
      }

      default:
        functions.logger.log(`Unhandled event type: ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    functions.logger.error('Error handling webhook:', error);
    res.status(500).send('Error handling webhook');
  }
});

async function handlePaymentSuccess(
  paymentIntent: Stripe.PaymentIntent
): Promise<void> {
  const { bookingId, providerId, commissionAmount, providerAmount } =
    paymentIntent.metadata;

  if (!bookingId) return;

  const db = admin.firestore();
  const now = admin.firestore.FieldValue.serverTimestamp();

  // Update booking status
  await db.collection('bookings').doc(bookingId).update({
    paymentStatus: 'paid',
    status: 'confirmed',
    updatedAt: now,
  });

  // Record payment
  await db.collection('payments').add({
    bookingId,
    providerId,
    amount: paymentIntent.amount / 100,
    commission: Number(commissionAmount) / 100,
    providerAmount: Number(providerAmount) / 100,
    currency: paymentIntent.currency.toUpperCase(),
    paymentIntentId: paymentIntent.id,
    status: 'succeeded',
    createdAt: now,
    completedAt: now,
  });

  // Update provider total bookings
  const bookingDoc = await db.collection('bookings').doc(bookingId).get();
  const providerId_ = bookingDoc.data()?.providerId;

  if (providerId_) {
    const providerQuery = await db
      .collection('providers')
      .doc(providerId_)
      .get();

    if (providerQuery.exists) {
      await providerQuery.ref.update({
        totalBookings: admin.firestore.FieldValue.increment(1),
      });
    }
  }

  // Update client total bookings and loyalty points
  const clientId = bookingDoc.data()?.clientId;
  if (clientId) {
    await db.collection('users').doc(clientId).update({
      totalBookings: admin.firestore.FieldValue.increment(1),
      loyaltyPoints: admin.firestore.FieldValue.increment(100),
    });

    // Check and update loyalty level
    const userDoc = await db.collection('users').doc(clientId).get();
    const totalBookings = (userDoc.data()?.totalBookings || 0) + 1;
    let newLevel = 1;
    if (totalBookings >= 15) newLevel = 3;
    else if (totalBookings >= 5) newLevel = 2;

    await db.collection('users').doc(clientId).update({
      loyaltyLevel: newLevel,
    });
  }
}

async function handlePaymentFailed(
  paymentIntent: Stripe.PaymentIntent
): Promise<void> {
  const { bookingId } = paymentIntent.metadata;
  if (!bookingId) return;

  await admin.firestore().collection('bookings').doc(bookingId).update({
    paymentStatus: 'pending',
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function handleAccountUpdated(account: Stripe.Account): Promise<void> {
  if (!account.metadata?.firebaseUid) return;

  const isVerified =
    account.details_submitted && account.charges_enabled;

  const query = await admin
    .firestore()
    .collection('providers')
    .where('userId', '==', account.metadata.firebaseUid)
    .limit(1)
    .get();

  if (!query.empty) {
    await query.docs[0].ref.update({
      stripeAccountVerified: isVerified,
    });
  }
}
