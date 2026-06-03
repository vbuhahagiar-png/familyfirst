import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const onBookingCreated = functions.firestore
  .document('bookings/{bookingId}')
  .onCreate(async (snapshot, context) => {
    const booking = snapshot.data();
    const bookingId = context.params.bookingId;
    const db = admin.firestore();
    const messaging = admin.messaging();

    functions.logger.log('New booking created:', bookingId);

    try {
      // Notify provider
      const providerDoc = await db
        .collection('providers')
        .doc(booking.providerId)
        .get();

      if (!providerDoc.exists) {
        functions.logger.warn('Provider not found:', booking.providerId);
        return;
      }

      const providerData = providerDoc.data()!;

      // Get provider user FCM token
      const providerUserDoc = await db
        .collection('users')
        .doc(providerData.userId)
        .get();

      const fcmToken = providerUserDoc.data()?.fcmToken;

      if (fcmToken) {
        await messaging.send({
          token: fcmToken,
          notification: {
            title: 'Новый заказ!',
            body: `${booking.clientName} хочет заказать "${booking.serviceName}"`,
          },
          data: {
            type: 'booking_created',
            bookingId,
          },
          android: {
            notification: {
              channelId: 'bookings',
              priority: 'high',
            },
          },
          apns: {
            payload: {
              aps: {
                badge: 1,
                sound: 'default',
              },
            },
          },
        });
      }

      // Create notification in Firestore for provider
      await db.collection('notifications').add({
        userId: providerData.userId,
        title: 'Новый заказ!',
        body: `${booking.clientName} хочет заказать "${booking.serviceName}"`,
        type: 'booking_created',
        referenceId: bookingId,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.log('Provider notification sent for booking:', bookingId);
    } catch (error) {
      functions.logger.error('Error in onBookingCreated:', error);
    }
  });
