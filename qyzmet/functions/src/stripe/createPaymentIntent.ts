import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
  apiVersion: '2024-12-18.acacia',
});

const COMMISSION_RATE = 0.15;

export const createPaymentIntent = functions.https.onCall(
  async (data, context) => {
    // Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const { amount, currency, bookingId, clientId, providerId } = data;

    if (!amount || !bookingId || !providerId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Missing required fields'
      );
    }

    try {
      // Get or create Stripe customer
      const userDoc = await admin
        .firestore()
        .collection('users')
        .doc(context.auth.uid)
        .get();

      let customerId = userDoc.data()?.stripeCustomerId;

      if (!customerId) {
        const customer = await stripe.customers.create({
          email: userDoc.data()?.email,
          name: userDoc.data()?.displayName,
          metadata: { firebaseUid: context.auth.uid },
        });
        customerId = customer.id;

        await admin
          .firestore()
          .collection('users')
          .doc(context.auth.uid)
          .update({ stripeCustomerId: customerId });
      }

      // Get provider's Stripe account
      const providerDoc = await admin
        .firestore()
        .collection('providers')
        .doc(providerId)
        .get();

      const stripeAccountId = providerDoc.data()?.stripeAccountId;

      // Calculate commission
      const commissionAmount = Math.round(amount * COMMISSION_RATE);
      const providerAmount = amount - commissionAmount;

      // Create payment intent
      const paymentIntentParams: Stripe.PaymentIntentCreateParams = {
        amount,
        currency: currency || 'kzt',
        customer: customerId,
        metadata: {
          bookingId,
          clientId,
          providerId,
          commissionAmount: commissionAmount.toString(),
          providerAmount: providerAmount.toString(),
        },
        automatic_payment_methods: { enabled: true },
      };

      // Add transfer if provider has Stripe account
      if (stripeAccountId) {
        paymentIntentParams.transfer_data = {
          destination: stripeAccountId,
          amount: providerAmount,
        };
      }

      const paymentIntent =
        await stripe.paymentIntents.create(paymentIntentParams);

      // Update booking with payment intent ID
      await admin
        .firestore()
        .collection('bookings')
        .doc(bookingId)
        .update({
          paymentIntentId: paymentIntent.id,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      return {
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
      };
    } catch (error) {
      functions.logger.error('Error creating payment intent:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to create payment intent'
      );
    }
  }
);
