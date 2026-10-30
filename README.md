# OurTree (`ourtree_app`)

Семейный альбом: профили, таймлайн событий, календарь и медиатека. Flutter,
Riverpod, Hive, локализация на `en`, `ru`, `be`, `uk`.

## Идентификаторы приложения

| Платформа | Идентификатор |
|---|---|
| Android (`applicationId`, `namespace`) | `com.ourtree.family` |
| iOS / macOS (`PRODUCT_BUNDLE_IDENTIFIER`) | `com.ourtree.family` |
| Linux (`APPLICATION_ID`) | `com.ourtree.family` |
| Web / Windows | название «OurTree», ключи берутся из web-приложения Firebase |

Идентификатор должен совпадать с приложением, зарегистрированным в Firebase:
при его смене нужно создавать новое приложение в консоли.

## Облако (в разработке)

Синхронизация — Cloud Firestore + Firebase Storage, авторизация — анонимный
Firebase Auth, покупки — RevenueCat (iOS/Android/Web) и Telegram-бот + Cloud
Functions (РФ/РБ). Локальные данные остаются в Hive и работают офлайн.

## Firebase (dev-проект `ourtree-dev`)

| Параметр | Значение |
|---|---|
| Project ID | `ourtree-dev` |
| Приложения | Android/iOS — `com.ourtree.family`, Web — `ourtree_app (web)`, Windows — `ourtree_app(windows)` |
| Firestore / Storage | `ourtree-dev.firebasestorage.app` |
| Регион функций | `europe-west3` |

Конфиг генерируется CLI: `flutterfire configure --project=ourtree-dev --platforms=android,ios,web,windows`
→ `lib/firebase_options.dart`, `android/app/google-services.json`, `firebase.json`, `.firebaserc`.

### Запуск с App Check

App Check выключен по умолчанию (включается осознанно, после настройки провайдеров):

```powershell
flutter run --dart-define=APP_CHECK_ENABLED=true `
            --dart-define=APP_CHECK_WEB_KEY=<recaptcha-v3-site-key> `
            --dart-define=APP_CHECK_WINDOWS_TOKEN=<debug-token>
```

Android/iOS в debug-режиме используют debug-провайдер (токен регистрируется в
консоли: *App Check → Manage debug tokens*).

### Правила и эмуляторы

```powershell
firebase emulators:start                 # auth 9099, firestore 8080, storage 9199, functions 5001, UI 4000
firebase deploy --only firestore:rules,storage
```

Правила: `firestore.rules`, `storage.rules`. Модель доступа — анонимный Auth +
членство в семье (`families/{fid}/members/{auth.uid}`); премиум меняет только
Cloud Functions.

### Cloud Functions

```powershell
cd functions
npm install
npm run build
firebase deploy --only functions
```
Runtime — Node 20 (`nodejs20`), регион `europe-west3`; секреты задаются через
`firebase functions:secrets:set <NAME>`.

## Android signing report (SHA-1 / SHA-256)

Отпечатки нужны для регистрации приложения в Firebase и проверки Play Integrity.
`gradlew` не находит Java, если не задан `JAVA_HOME`, — Flutter использует JDK из
Android Studio:

```powershell
$env:JAVA_HOME = 'C:\Users\<user>\AppData\Local\Programs\Android Studio\jbr'
cd android
.\gradlew.bat signingReport --console=plain
```

Значения ищите в блоке `Variant: debug` → `SHA1:` и `SHA-256:`.
Release-сборка сейчас подписана debug-ключом (`signingConfig = debug`), поэтому
отпечатки release появятся только после настройки upload-keystore.

