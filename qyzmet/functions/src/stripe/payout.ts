import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
  apiVersion: '2024-12-18.acacia',
});

export const requestPayout = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const { amount } = data;

    try {
      // Get provider's Stripe account
      const providerQuery = await admin
        .firestore()
        .collection('providers')
        .where('userId', '==', context.auth.uid)
        .limit(1)
        .get();

      if (providerQuery.empty) {
        throw new functions.https.HttpsError('not-found', 'Provider not found');
      }

      const providerData = providerQuery.docs[0].data();
      const stripeAccountId = providerData.stripeAccountId;

      if (!stripeAccountId) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Provider has no Stripe account connected'
        );
      }

      // Create payout to the provider's connected account
      const transfer = await stripe.transfers.create({
        amount: Math.round(amount * 100), // Convert to tiyn
        currency: 'kzt',
        destination: stripeAccountId,
        metadata: {
          providerId: providerQuery.docs[0].id,
          requestedBy: context.auth.uid,
        },
      });

      functions.logger.log('Payout transfer created:', transfer.id);

      return { transferId: transfer.id, status: 'success' };
    } catch (error) {
      functions.logger.error('Error requesting payout:', error);
      if (error instanceof functions.https.HttpsError) throw error;
      throw new functions.https.HttpsError('internal', 'Failed to process payout');
    }
  }
);
