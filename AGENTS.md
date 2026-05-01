# AGENTS Guide

## Codebase at a glance
- Flutter app (GetX) for AI-powered Lost & Found platform with ownership verification.
- Entry: `lib/main.dart` -> `GetMaterialApp` with named routes and `AppBindings`.
- Arabic-first RTL app, locale `ar_SA`, Material 3 theme.

## Architecture (layered GetX)
- `lib/data/model/` — Domain models: `UserModel`, `PostModel`, `VerificationAttemptModel`, `ChatRoomModel`, `NotificationModel`.
- `lib/data/datasource/verification_datasource.dart` — `AppDataSource` in-memory store (users, posts, attempts, chat rooms, notifications, admin settings).
- `lib/core/services/` — Business logic: `CryptoService` (XOR+hash), `SemanticSimilarityService` (local NLP), `VerificationService` (3-question AI scoring with numeric bonus), `MatchingService` (weighted matching: 40% category, 30% desc, 20% geo, 10% time).
- `lib/controller/` — GetX controllers: `AuthController`, `PostController`, `VerificationController`, `ChatController`.
- `lib/view/Screen/` — All screens: onboarding, register, login, home, all items, report lost, report found, post detail, verification, chat list, chat room, notifications, admin, profile.
- `lib/core/constant/app_routes.dart` — Named route constants.
- `lib/core/class/app_bindings.dart` — Full DI registration.

## Key business rules
- National ID: exactly 9 digits, stored encrypted (AES-like XOR), hashed for lookups.
- Found posts require 3 verification questions with encrypted reference answers.
- AI verification: cosine-like semantic comparison per question, numeric bonus/penalty ±20%, average across 3 questions.
- Threshold ≥70% → chat opens; 50-69% → retry; <50% → reject. 3 fails → block on that post.
- Chat rooms created only after verification passes. No direct contact info exposed.
- Admin can adjust AI threshold (60-85%) and matching threshold (50-75%).

## Dev workflows
```
flutter pub get
flutter analyze
flutter test
flutter run
```

## Conventions
- Package: `rajeali_app`. Screens in `lib/view/Screen/`. Widgets in `lib/view/widget/`.
- All controllers use constructor DI via `AppDataSource` + services.
- Arabic strings hardcoded in screens (no separate translation file for full app screens).
- `uuid` package for all ID generation. `crypto` package for SHA-256 hashing.
