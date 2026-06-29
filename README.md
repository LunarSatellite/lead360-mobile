# Lead360 Mobile

Flutter (iOS + Android) companion for the Lead360 CRM. Talks to the same backend API
as the web app (`/api/v1/...`, JWT + `X-Tenant-Id`). No backend changes required.

## Status (v1)
- ✅ Auth (login, secure token storage, refresh-on-401, auth-aware routing)
- ✅ Dark-green "Bato" theme matching the web identity
- ✅ Leads / Contacts / Deals / Tasks — list (search/filter, pull-to-refresh) + detail; lead stage-change; task complete
- ✅ CRM Copilot — streaming agent chat over SSE (`/v1/agent-runtime/message/stream`) with confirmations
- ✅ Global search — leads + contacts + deals, grouped
- ⏳ Next: push notifications (see `docs/PUSH-NOTIFICATIONS.md` — needs Firebase + a small backend addition), offline cache, list pagination

## Handoff — to take this live
1. **Create the remote** (`lead360-mobile`) and push; this repo currently has no remote.
2. **Verify the build:** `flutter create .` then `flutter pub get` then `flutter analyze` + `flutter run`.
   The Dart was written without a local SDK (analyzer not run here) — fix anything `flutter analyze` flags.
3. **Wire the API base URL** for your environments via `--dart-define=API_BASE_URL=...` (and CI flavors).
4. **Copilot** needs the tenant's `agentRuntimeEnabled` on (web Feature Settings) + a DeepSeek key server-side.
5. **Push notifications:** follow `docs/PUSH-NOTIFICATIONS.md` (Firebase project + backend `DeviceToken` endpoint).

## Architecture
Feature-first, mirroring the web's Feature-Sliced layout:
```
lib/
  core/        config, network (Dio + interceptors, JSON helpers), auth, theme, router, providers
  features/    auth, shell, leads (model → repository → providers → screens)
  shared/      reusable widgets (AsyncView, StagePill)
```
- **State:** Riverpod. **HTTP:** Dio (bearer + tenant interceptor, 1× refresh retry on 401).
- **Models:** hand-written `fromJson` that read the API's **PascalCase** keys (with camelCase fallback) — see `core/network/json.dart`.
- **Auth tokens:** `flutter_secure_storage` (Keychain / Keystore).

## Run it
This repo ships `lib/` + `pubspec.yaml` only. Generate the platform folders once, then run:

```bash
flutter create .            # attaches android/ ios/ (and web/ macos/ …) to this project
flutter pub get
flutter run --dart-define=API_BASE_URL=https://<your-host>/api
```
- Android emulator reaching a host `localhost:5000`: the default `API_BASE_URL` is `http://10.0.2.2:5000/api`.
- iOS simulator: use `http://localhost:5000/api`.
- Production: pass your real `--dart-define=API_BASE_URL=...` (also wire it into your CI build flavors).

## Conventions to follow when extending
1. New module = `features/<name>/` with `*_model.dart`, `*_repository.dart`, `*_providers.dart`, screens.
2. Parse responses via the `json.dart` helpers (PascalCase-safe). Paged endpoints → `Paged<T>.fromJson`.
3. All network goes through `apiClientProvider` (never construct Dio directly) so auth/tenant/refresh apply.
4. Use design tokens from `core/theme/app_theme.dart` (`AppColors`), not raw hex.
5. RBAC: the API enforces role/ownership server-side; surface 403s as a message, don't pre-gate in UI.
