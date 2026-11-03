/*
 * Service worker для push-уведомлений (FCM Web).
 *
 * Лежит в /push/, чтобы не конфликтовать с flutter_service_worker.js: тот
 * кэширует приложение и регистрируется на корне. Клиент регистрирует этот файл
 * через FirebaseMessaging.getToken(serviceWorkerScriptPath: 'push/...').
 *
 * В конфиге — публичные ключи веб-приложения Firebase (они и так есть в
 * main.dart.js), секретов здесь нет.
 */
importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCBycpq2RMG3mAjmWN12ALaUc5almi05zE',
  appId: '1:477705174790:web:0852a48a6d0f9379bba887',
  messagingSenderId: '477705174790',
  projectId: 'ourtree-dev',
  authDomain: 'ourtree-dev.firebaseapp.com',
  storageBucket: 'ourtree-dev.firebasestorage.app',
});

// Показ уведомления и обработку клика делает сам FCM: сервер присылает
// `notification`-payload и `webpush.fcmOptions.link` на приложение.
firebase.messaging();
