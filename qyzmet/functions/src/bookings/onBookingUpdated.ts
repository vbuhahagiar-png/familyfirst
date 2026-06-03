import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const onBookingUpdated = functions.firestore
  .document('bookings/{bookingId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const bookingId = context.params.bookingId;
    const db = admin.firestore();
    const messaging = admin.messaging();

    // Only process status changes
    if (before.status === after.status) return;

    functions.logger.log(
      `Booking ${bookingId} status changed: ${before.status} -> ${after.status}`
    );

    try {
      // Get client FCM token
      const clientUserDoc = await db
        .collection('users')
        .doc(after.clientId)
        .get();
      const clientFcmToken = clientUserDoc.data()?.fcmToken;

      let notificationTitle = '';
      let notificationBody = '';
      let notificationType = '';

      switch (after.status) {
        case 'confirmed':
          notificationTitle = 'Заказ подтверждён!';
          notificationBody = `${after.providerName} подтвердил ваш заказ`;
          notificationType = 'booking_confirmed';
          break;

        case 'in_progress':
          notificationTitle = 'Работа началась';
          notificationBody = `${after.providerName} приступил к работе`;
          notificationType = 'booking_in_progress';
          break;

        case 'completed':
          notificationTitle = 'Заказ выполнен!';
          notificationBody = 'Пожалуйста, оставьте отзыв о специалисте';
          notificationType = 'booking_completed';
          break;

        case 'cancelled':
          notificationTitle = 'Заказ отменён';
          notificationBody = `Заказ от ${after.clientName} был отменён`;
          notificationType = 'booking_cancelled';
          break;

        default:
          return;
      }

      // Send push to client (for confirmed/in_progress/completed)
      if (
        clientFcmToken &&
        ['confirmed', 'in_progress', 'completed'].includes(after.status)
      ) {
        await messaging.send({
          token: clientFcmToken,
          notification: {
            title: notificationTitle,
            body: notificationBody,
          },
          data: {
            type: notificationType,
            bookingId,
          },
        });
      }

      // Send push to provider for cancellation
      if (after.status === 'cancelled') {
        const providerDoc = await db
          .collection('providers')
          .doc(after.providerId)
          .get();

        if (providerDoc.exists) {
          const providerUserDoc = await db
            .collection('users')
            .doc(providerDoc.data()!.userId)
            .get();
          const providerFcmToken = providerUserDoc.data()?.fcmToken;

          if (providerFcmToken) {
            await messaging.send({
              token: providerFcmToken,
              notification: {
                title: notificationTitle,
                body: notificationBody,
              },
              data: {
                type: notificationType,
                bookingId,
              },
            });
          }
        }
      }

      // Create Firestore notification for client
      const targetUserId = after.status === 'cancelled'
        ? null // For cancellation, notify provider instead
        : after.clientId;

      if (targetUserId) {
        await db.collection('notifications').add({
          userId: targetUserId,
          title: notificationTitle,
          body: notificationBody,
          type: notificationType,
          referenceId: bookingId,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      functions.logger.log('Booking update notification sent:', bookingId);
    } catch (error) {
      functions.logger.error('Error in onBookingUpdated:', error);
    }
  });
