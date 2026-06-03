import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
  apiVersion: '2024-12-18.acacia',
});

export const createConnectAccount = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const { email, country = 'KZ' } = data;

    try {
      // Create Express account
      const account = await stripe.accounts.create({
        type: 'express',
        country,
        email,
        capabilities: {
          card_payments: { requested: true },
          transfers: { requested: true },
        },
        business_type: 'individual',
        metadata: { firebaseUid: context.auth.uid },
      });

      // Save account ID to provider profile
      const providerQuery = await admin
        .firestore()
        .collection('providers')
        .where('userId', '==', context.auth.uid)
        .limit(1)
        .get();

      if (!providerQuery.empty) {
        await providerQuery.docs[0].ref.update({
          stripeAccountId: account.id,
        });
      }

      return { accountId: account.id };
    } catch (error) {
      functions.logger.error('Error creating connect account:', error);
      throw new functions.https.HttpsError('internal', 'Failed to create account');
    }
  }
);

export const createAccountLink = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const { accountId } = data;

    try {
      const accountLink = await stripe.accountLinks.create({
        account: accountId,
        refresh_url: 'https://qyzmet.kz/provider/setup',
        return_url: 'https://qyzmet.kz/provider/setup/complete',
        type: 'account_onboarding',
      });

      return { url: accountLink.url };
    } catch (error) {
      functions.logger.error('Error creating account link:', error);
      throw new functions.https.HttpsError('internal', 'Failed to create account link');
    }
  }
);
