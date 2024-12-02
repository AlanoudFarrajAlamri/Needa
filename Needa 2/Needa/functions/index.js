const { https } = require("firebase-functions/v2");
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
if (admin.apps.length === 0) {
    admin.initializeApp();
}

// Function to send a push notification to multiple devices
exports.sendNotificationV3 = https.onRequest((req, res) => {
    // Ensure the request is a POST request
    if (req.method !== 'POST') {
        return res.status(405).send('Method Not Allowed');
    }

    // Extract dynamic values from the request body
    const token = req.body.token; // Array of FCM tokens
    const needaRecordId = req.body.needaRecordId; // Dynamic Needa record ID
    const title = req.body.title; // Dynamic title for the notification
    const body = req.body.body; // Dynamic body for the notification

    // Validate that required fields are present
    if (!token || !needaRecordId || !title || !body) {
        return res.status(400).send('Missing required fields');
    }

    // Prepare the message with dynamic values
    const message = {
        notification: {
            title: title, // Notification title
            body: body,   // Notification body
        },
        data: {
            needaRecordId: needaRecordId, // Dynamic Needa record ID in data
        },
        token: token // Array of FCM device tokens
    };

    // Send the message to multiple device tokens using sendMulticast
    admin.messaging().send(message)
        .then((response) => {
            console.log('Successfully sent message:', response);
            res.status(200).send('Notifications sent successfully');
        })
        .catch((error) => {
            console.log('Error sending message:', error);
            res.status(500).send('Error sending notification: ' + error.message);
        });
});
