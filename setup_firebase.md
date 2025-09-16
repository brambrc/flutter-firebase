# 🚀 Setup Firebase untuk Firebase Learning App

Panduan langkah demi langkah untuk mengonfigurasi Firebase untuk aplikasi pembelajaran ini.

## ✅ Prerequisites

Pastikan Anda sudah menginstall:
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Node.js](https://nodejs.org/) (untuk Firebase CLI)

## 📋 Langkah Setup

### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
```

### 2. Login ke Firebase

```bash
firebase login
```

### 3. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 4. Buat Firebase Project

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik "Create a project"
3. Masukkan nama project: `firebase-learning-app-[username]`
4. Enable Google Analytics (opsional)
5. Tunggu project selesai dibuat

### 5. Configure Firebase untuk Flutter

Jalankan command berikut di root directory project:

```bash
flutterfire configure
```

Pilih:
- Firebase project yang baru dibuat
- Platform: Android, iOS, Web (sesuai kebutuhan)
- Package name: `com.example.firebase_learning_app`

### 6. Enable Firebase Services

#### A. Authentication

1. Di Firebase Console, buka **Authentication**
2. Klik tab **Sign-in method**
3. Enable **Email/Password**
4. Enable **Google** (masukkan project email)
5. Atur **Authorized domains** jika perlu

#### B. Realtime Database

1. Buka **Realtime Database**
2. Klik **Create Database**
3. Pilih lokasi: `asia-southeast1` (Singapore)
4. Mulai dengan **Test mode** untuk development:

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

#### C. Cloud Firestore

1. Buka **Cloud Firestore**
2. Klik **Create database**
3. Pilih **Start in test mode**
4. Pilih lokasi: `asia-southeast1`

Test mode rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2024, 12, 31);
    }
  }
}
```

#### D. Cloud Messaging

FCM sudah aktif otomatis. Tidak perlu konfigurasi tambahan.

### 7. Setup Security Rules (Production)

#### Realtime Database Rules:
```json
{
  "rules": {
    "todos": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid"
      }
    },
    "users": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid"
      }
    }
  }
}
```

#### Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Users can only read/write their own todos
      match /todos/{todoId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### 8. Konfigurasi Android

1. Download `google-services.json` dari Firebase Console
2. Copy ke `android/app/google-services.json`
3. File sudah dikonfigurasi di `android/app/build.gradle`

### 9. Konfigurasi iOS (jika mengembangkan untuk iOS)

1. Download `GoogleService-Info.plist` dari Firebase Console
2. Drag ke Xcode project di folder `Runner`
3. Pastikan file termasuk dalam target build

### 10. Test Setup

Jalankan aplikasi:

```bash
flutter pub get
flutter run
```

### 11. Test Firebase Features

1. **Test Authentication**:
   - Register dengan email baru
   - Login dengan email yang terdaftar
   - Test Google Sign-In

2. **Test Database**:
   - Tambah todo baru
   - Edit dan hapus todo
   - Test real-time sync

3. **Test Notifications**:
   - Test local notification dari app
   - Send test message dari Firebase Console

## 🔧 Troubleshooting

### Error: SHA-1 fingerprint missing

Untuk Google Sign-In di Android:

```bash
cd android
./gradlew signingReport
```

Copy SHA-1 ke Firebase Console > Project Settings > Your apps > Android app > SHA certificate fingerprints.

### Error: Firebase not initialized

Pastikan `Firebase.initializeApp()` dipanggil di `main()` sebelum `runApp()`.

### Error: Google Sign-In failed

1. Periksa `google-services.json` sudah ada di `android/app/`
2. Periksa SHA-1 fingerprint di Firebase Console
3. Enable Google Sign-In di Firebase Console

### Error: Permission denied (Database)

Update security rules di Firebase Console sesuai contoh di atas.

## ✅ Verifikasi Setup

Cek list berikut untuk memastikan setup berhasil:

- [ ] Firebase project created
- [ ] `google-services.json` di `android/app/`
- [ ] `firebase_options.dart` generated
- [ ] Authentication methods enabled
- [ ] Realtime Database created dan rules set
- [ ] Firestore created dan rules set
- [ ] App bisa running tanpa error
- [ ] Bisa register/login
- [ ] Bisa create/read todos
- [ ] Push notification bekerja

## 🎯 Selesai!

Setup Firebase untuk Firebase Learning App sudah selesai! Anda sekarang bisa mulai menjelajahi fitur-fitur Firebase melalui aplikasi ini.

Untuk panduan lebih detail, lihat `README.md` di root directory project.
