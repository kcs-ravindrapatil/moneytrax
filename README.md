# MoneyTrax

Local-only daily expense tracker for Android and iOS, built with Flutter.

MoneyTrax stores expense, income, category, budget, and profile data on-device with SQLite. There is no expense backend. ConveyGrid consent is abstracted and currently implemented as a **no-op stub** for later SDK integration.

> Store approval is **not** guaranteed. Follow the checklists below and complete all manual App Store / Play Console steps before submission.

## Stack

- Flutter / Dart (null safety)
- Clean Architecture (Presentation → Domain ← Data)
- `flutter_bloc` (BLoC only — no Cubit, no `setState`)
- `auto_route`
- `get_it`
- `sqflite`
- `json_serializable`
- `fl_chart` (reports)
- `pdf` + `share_plus` (invoice export)
- `flutter_local_notifications` (optional local reminders)

## Project structure

```
lib/
  app/           # theme, router, shell
  core/          # database, errors, validators, widgets
  features/      # feature-first Clean Architecture modules
  integrations/  # consent abstraction (ConveyGrid stub)
  injection/     # GetIt registrations
```

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Regenerate after changing AutoRoute annotations or `@JsonSerializable` models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Quality checks

```bash
dart format .
flutter analyze
flutter test
flutter build apk --release
# on macOS with Xcode:
flutter build ios --release --no-codesign
```

## Feature overview

1. Splash → 3 intro screens → Welcome → Profile (full name, email, mobile)
2. Consent stub after profile save → Dashboard
3. Bottom nav: Home, Transactions, Add, Reports, Settings
4. Expenses / Income CRUD, unified transactions with search/filter/sort
5. Reports with charts + PDF invoice share
6. Monthly / category budgets
7. Settings: currency, payment methods, deferred local notifications, privacy, delete profile

## Privacy notes (current binary)

| Data | Storage | Shared externally? |
|------|---------|--------------------|
| Expenses, income, budgets, categories | Local SQLite | No |
| Full name, email, mobile | Local SQLite | **No** while consent is stubbed |
| Notification preference | SharedPreferences | No |
| Local reminders | On-device notifications | No push backend |

When ConveyGrid is wired, update Privacy screen copy and store declarations to match real SDK behavior.

## Android build

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

Manual steps:

- [ ] Replace `applicationId` (`com.example.conveygrid_moneytracker`) with your production ID
- [ ] Configure release signing (do not commit keystore passwords)
- [ ] Provide adaptive launcher icon / branding assets
- [ ] Complete Play Console Data Safety form from the privacy table above
- [ ] Confirm `POST_NOTIFICATIONS` is only requested after the user enables reminders
- [ ] Review R8/ProGuard: release minify is currently disabled; enable and validate `android/app/proguard-rules.pro` before production hardening

## iOS build

```bash
flutter build ios --release --no-codesign
# then archive/sign in Xcode
```

Manual steps:

- [ ] Set production Bundle Identifier in Xcode
- [ ] Configure signing team / certificates
- [ ] Review Privacy Manifest requirements for all dependencies
- [ ] Do **not** add unused usage description strings
- [ ] Complete App Privacy details in App Store Connect accurately
- [ ] Display name is already set to **MoneyTrax**

## App Store / Play Store checklist

- [ ] App described as an expense tracking utility (not a bank / payment / advisory service)
- [ ] No placeholder or demo branding left in release
- [ ] Privacy policy URL matches actual data practices
- [ ] No unnecessary permissions (contacts, location, camera, etc.)
- [ ] ConveyGrid disclosure updated when SDK is enabled
- [ ] Screenshots and listing copy are accurate
- [ ] Crash-free smoke test on a physical device

## Google Play Data Safety (draft for current stub build)

- Data collected: name, email, phone (stored on device for profile)
- Data shared: none (consent stub does not transmit)
- Data encrypted in transit: N/A for local-only profile usage
- Users can request deletion: in-app Delete Profile removes local data

Re-evaluate all answers after enabling ConveyGrid.

## ConveyGrid integration

MoneyTrax uses `conveygrid_flutter_sdk` (local path to the monorepo package; switch to git for distribution):

```yaml
conveygrid_flutter_sdk:
  git:
    url: https://github.com/conveygrid-sdk/conveygrid-flutter-sdk.git
    ref: v0.1.0
```

### Configure via `.env` (recommended)

Aligned with the iOS `ConveyGridConfig` defaults:

| iOS | Flutter `.env` |
| --- | --- |
| `defaultClientId` | `CONVEYGRID_APPLICATION_KEY` |
| `defaultOrigin` | `CONVEYGRID_DF_ORIGIN` / `CONVEYGRID_DF_REFERER` |
| `defaultNoticeCode` (`NOTICE_001`) | `CONVEYGRID_NOTICE_CODE` |
| API host | `CONVEYGRID_API_BASE_URL=https://conveygridapidev.rysun.in` |

```bash
cp .env.example .env
# put your real CONVEYGRID_APPLICATION_KEY and notice code in `.env`
flutter run
```

`.env` is gitignored and must not be committed. Share only `.env.example` (placeholders). Values resolve as: `--dart-define` → `.env` → defaults.

Optional: `CONVEYGRID_PURPOSE_CODE` enables a `validateConsent` short-circuit so the popup is skipped when that purpose is already granted.

If the application key is missing, MoneyTrax falls back to `NoOpConsentIntegration` so local expense tracking still works.

## License / ownership

Private project — not published to pub.dev (`publish_to: 'none'`).
# moneytrax
