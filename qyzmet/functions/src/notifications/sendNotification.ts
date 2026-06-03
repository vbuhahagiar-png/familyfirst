import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

interface SendNotificationData {
  userId: string;
  title: string;
  body: string;
  type: string;
  referenceId?: string;
  topic?: string;
}

export const sendNotification = functions.https.onCall(
  async (data: SendNotificationData, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const { userId, title, body, type, referenceId, topic } = data;
    const db = admin.firestore();
    const messaging = admin.messaging();

    try {
      // Save notification to Firestore
      await db.collection('notifications').add({
        userId,
        title,
        body,
        type,
        referenceId: referenceId || null,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Send push notification
      if (topic) {
        // Send to topic (broadcast)
        await messaging.sendToTopic(topic, {
          notification: { title, body },
          data: { type, referenceId: referenceId || '' },
        });
      } else {
        // Send to specific user
        const userDoc = await db.collection('users').doc(userId).get();
        const fcmToken = userDoc.data()?.fcmToken;

        if (fcmToken) {
          await messaging.send({
            token: fcmToken,
            notification: { title, body },
            data: { type, referenceId: referenceId || '' },
          });
        }
      }

      return { success: true };
    } catch (error) {
      functions.logger.error('Error sending notification:', error);
      throw new functions.https.HttpsError('internal', 'Failed to send notification');
    }
  }
);
