/* global firebase, self, fetch, console */
importScripts('https://www.gstatic.com/firebasejs/10.12.4/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.4/firebase-messaging-compat.js');

const firebaseConfigPromise = fetch('/firebase-config.json', { cache: 'no-store' })
  .then((response) => {
    if (!response.ok) {
      throw new Error(`firebase-config.json unavailable (${response.status})`);
    }
    return response.json();
  })
  .then((config) => {
    const requiredKeys = [
      'apiKey',
      'authDomain',
      'projectId',
      'storageBucket',
      'messagingSenderId',
      'appId'
    ];
    const missingKey = requiredKeys.find((key) => !config[key]);
    if (missingKey) {
      throw new Error(`firebase-config.json missing ${missingKey}`);
    }

    firebase.initializeApp(config);
    const messaging = firebase.messaging();

    messaging.onBackgroundMessage((payload) => {
      const notification = payload.notification || {};
      const title = notification.title || 'DailyCatch';
      const options = {
        body: notification.body || 'Nouvelle notification DailyCatch',
        icon: '/icons/Icon-192.png',
        badge: '/icons/Icon-192.png',
        data: payload.data || {}
      };

      self.registration.showNotification(title, options);
    });

    return messaging;
  })
  .catch((error) => {
    console.warn('DailyCatch web push disabled:', error.message);
    return null;
  });

self.addEventListener('push', () => {
  void firebaseConfigPromise;
});
