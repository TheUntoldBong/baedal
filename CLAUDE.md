# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter run -d web       # Run web version
flutter analyze          # Lint (allowed via settings)
flutter build apk        # Android APK
flutter build ios        # iOS build
flutter build web        # Web build
```

## Architecture

Clean Architecture with GetX. Every feature follows this layer chain:

```
Controller → ServiceInterface → Service → RepositoryInterface → Repository → ApiClient
```

**Dependency Injection** — all registered lazily in [lib/helper/get_di.dart](lib/helper/get_di.dart):
```dart
Get.lazyPut(() => AuthServiceInterface(authRepoInterface: Get.find()));
Get.lazyPut(() => AuthController(authServiceInterface: Get.find()));
```

**Routing** — all routes are static strings in [lib/helper/route_helper.dart](lib/helper/route_helper.dart). Add new routes there and register in `getPages` list.

**API layer** — [lib/api/api_client.dart](lib/api/api_client.dart) handles all HTTP. Dynamic headers include zone ID, language, lat/lng, and auth token. Base URL is in [lib/util/app_constants.dart](lib/util/app_constants.dart).

**Caching** — [lib/api/local_client.dart](lib/api/local_client.dart) abstracts cache read/write. Mobile uses Drift ([lib/data_source/cache_response.dart](lib/data_source/cache_response.dart)); web uses SharedPreferences. Controllers use `DataSourceEnum.local` first, then `DataSourceEnum.client`:
```dart
bannerModel = await service.getBannerList(source: DataSourceEnum.local);
bannerModel = await service.getBannerList(source: DataSourceEnum.client);
```

## Feature Structure

Each feature in [lib/features/](lib/features/) follows this layout:
```
features/[feature]/
├── controllers/          # GetX controllers (extend GetxController)
├── domain/
│   ├── models/          # Feature-specific models
│   ├── repositories/    # *Interface + implementation
│   └── services/        # *Interface + implementation
├── screens/             # Full-page UI
└── widgets/             # Feature-scoped widgets
```

Shared models and widgets live in [lib/common/](lib/common/). Global constants, dimensions, colors, and image paths are in [lib/util/](lib/util/).

## State Management

GetX only. UI rebuilds via `GetBuilder<Controller>` + `controller.update()`. Access controllers with `Get.find<Controller>()`. Never use `setState` or other state solutions.

## Localization

All user-facing strings must use `.tr` and have a key in [lib/util/messages.dart](lib/util/messages.dart) and all four JSON files under [assets/language/](assets/language/) (`en.json`, `ar.json`, `bn.json`, `es.json`). Add localization keys at the end of the class that introduces them.

## Responsive / Multi-platform

`ResponsiveHelper` and `kIsWeb` conditionals handle mobile vs web differences. Google Maps, Firebase, and some UI components have platform-specific branches.

## Code Style

Do not add code comments unless they explain something critical that isn't obvious from the code itself (a non-obvious constraint, a workaround, a tricky edge case). Do not comment on what the code does — well-named identifiers should make that clear.
