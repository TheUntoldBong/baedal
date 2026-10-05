importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyBBwQ_XQuW4j1Gg9L3tbLcyaOKBJ7qL2NU",
  authDomain: "baedal-food-delivery.firebaseapp.com",
  projectId: "baedal-food-delivery",
  storageBucket: "baedal-food-delivery.firebasestorage.app",
  messagingSenderId: "369896627923",
  appId: "1:369896627923:web:3108cae6fbfad2ef9dbe26",
  databaseURL: "...",
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