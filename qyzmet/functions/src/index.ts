import * as admin from 'firebase-admin';

admin.initializeApp();

// Stripe functions
export { createPaymentIntent } from './stripe/createPaymentIntent';
export { createConnectAccount, createAccountLink } from './stripe/connectAccount';
export { stripeWebhook } from './stripe/webhook';
export { requestPayout } from './stripe/payout';

// Booking functions
export { onBookingCreated } from './bookings/onBookingCreated';
export { onBookingUpdated } from './bookings/onBookingUpdated';

// Notification functions
export { sendNotification } from './notifications/sendNotification';
