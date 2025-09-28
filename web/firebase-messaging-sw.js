importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyDQ3lxAHoKaXQl2xZ0WEZXPQbB2D67n7uI",
    authDomain: "jouan-8e433.firebaseapp.com",
    projectId: "jouan-8e433",
    storageBucket: "jouan-8e433.firebasestorage.app",
    messagingSenderId: "1008785511526",
    appId: "1:1008785511526:web:b2a643531d09b04581c9a7",
    measurementId: "G-WDL20VD0DV"
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});