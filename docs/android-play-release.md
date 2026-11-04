# Android release — TrekViệt

- Application ID: `com.trekviet.app`
- Version: `1.0.0+1` (version name `1.0.0`, version code `1`)
- Production API: `https://api-gateway-trekvn.onrender.com/api/v1`
- Output: `build/app/outputs/bundle/release/app-release.aab`

## Build

Run from `Frontend-TrekVN`:

```powershell
flutter build appbundle --release --dart-define=APP_ENV=production --dart-define=API_BASE_URL=https://api-gateway-trekvn.onrender.com/api/v1 --dart-define=TREKKING_BASE_URL=https://api-gateway-trekvn.onrender.com/api/v1 --dart-define=CHECKIN_BASE_URL=https://api-gateway-trekvn.onrender.com/api/v1 --dart-define=COMMUNITY_BASE_URL=https://api-gateway-trekvn.onrender.com/api/v1
```

For subsequent uploads, increase the version code in `pubspec.yaml`, or pass
`--build-number=<next-number>`. Keep the application ID and upload key.

## Upload key backup

Back up both local files securely; neither is tracked by Git:

- `android/app/trekviet-upload-keystore.jks`
- `android/key.properties` (contains the keystore and key passwords)

Alias: `trekviet-upload`. The keystore path in `key.properties` is relative to
`android/app`. Release builds require this signing configuration.

Public upload certificate: `android/app/trekviet-upload-certificate.pem`.

Upload certificate SHA-1:
`3B:EA:1F:A0:CD:7B:0E:C9:36:5B:97:83:16:7A:B1:2C:05:13:F7:CC`

## Google sign-in

The Android OAuth client must use package `com.trekviet.app` and the certificate
SHA-1 of the installed build. For a build distributed by Google Play with Play
App Signing, use the **app signing certificate** SHA-1 shown in Play Console.
For a locally signed build, use the upload certificate SHA-1 above. The app's
existing web OAuth client ID stays configured in `GoogleSignInService`.

## Play Console

Upload the AAB into the desired testing or production release. Complete the
store listing and required Console forms, then submit the release for review.
Only the build artifact is produced locally; publishing is done in Play Console.
