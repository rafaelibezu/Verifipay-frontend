# verifipay_frontend

A new Flutter project.

## VerifiPay local API URL

Flutter uses `VERIFIPAY_API_BASE_URL` and Android native uses
`VERIFIPAY_API_URL`.

For Android emulator local backend:

```powershell
flutter run --dart-define=VERIFIPAY_API_BASE_URL=http://10.0.2.2:8080/api/v1
```

Native Yape sender defaults to `http://10.0.2.2:8080` and appends `/api/v1`.
To override it, add this non-secret value to `android/local.properties`:

```properties
VERIFIPAY_API_URL=http://10.0.2.2:8080
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
