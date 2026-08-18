importScripts("https://www.gstatic.com/firebasejs/10.13.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.13.0/firebase-messaging-compat.js");

const firebaseConfig = {
    apiKey: 'AIzaSyCOoJp0rCmKDMpMjV0nE-bMxGMJ_7z8BgM',
    appId: '1:1037792018757:web:9fb4fe93dc03ceb6d3fe2c',
    messagingSenderId: '1037792018757',
    projectId: 'khakhi-diary',
    authDomain: 'khakhi-diary.firebaseapp.com',
    storageBucket: 'khakhi-diary.firebasestorage.app',
    measurementId: 'G-C5RCYEWGD4',
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
});
