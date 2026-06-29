# Push Notifications — implementation spec

Goal: deliver the existing `StaffNotification` stream (hot leads, assignments, SLA,
task reminders, mentions, etc.) to the mobile app as native push. Three parts:
**(A)** a small backend addition, **(B)** Firebase/APNs setup, **(C)** the Flutter client.

The backend already *creates* `StaffNotification` rows from ~10 services and exposes the
in-app bell API. What's missing is (1) somewhere to store device tokens and (2) a fan-out
to FCM when a notification is created.

---

## A. Backend (lead360) — coordinate with the team (touches the active repo)

### A1. Entity + table
`DeviceToken : TenantEntityBase<Guid>`
| field | type | notes |
|---|---|---|
| UserId | Guid | owner of the device |
| Token | string(512) | FCM registration token |
| Platform | enum (Ios=1, Android=2) | |
| LastSeenAt | DateTime | refreshed on each register |

Unique filtered index on `(TenantId, Token)` where `IsDeleted = false`.
Migration: `AddDeviceTokens`.

### A2. Endpoints (new `DeviceTokenController`, `[Authorize]`, tenant-scoped)
```
POST   /api/v1/device-tokens        { token, platform }   → upsert by (tenant, token), set UserId = caller, LastSeenAt = now
DELETE /api/v1/device-tokens/{token}                       → soft-delete on logout
```
Service: `IDeviceTokenService.RegisterAsync(tenantId, userId, token, platform)` / `UnregisterAsync`.
Upsert semantics: if the token exists, reassign UserId + bump LastSeenAt (handles device handed between users).

### A3. Send hook
Where `StaffNotification` is created (centralize in the notification writer if one exists,
else add a single `IPushSender.SendToUserAsync(tenantId, userId, title, body, dataJson)` call
next to the row insert):
- look up active `DeviceToken`s for `(tenantId, userId)`;
- POST to FCM HTTP v1 (`https://fcm.googleapis.com/v1/projects/{projectId}/messages:send`)
  with a service-account bearer token (use `Google.Apis.Auth` or a cached JWT);
- on a `404/410 UNREGISTERED` response, soft-delete that token (stale device).
- Best-effort + fire-and-forget (never block the originating action); reuse the existing
  Hangfire pattern if you want retries.

Config (deployment, not per-tenant): `Push:Fcm:ProjectId`, `Push:Fcm:ServiceAccountJson`
(path or secret). Gate behind `Push:Enabled` so it's dormant until configured.

### A4. Payload contract (so the app can deep-link)
```
notification: { title, body }
data: { type: "lead|deal|task|case", entityId: "<guid>" }
```
The app routes on `data.type` + `entityId` (e.g. → `/leads/{entityId}`).

---

## B. Firebase / APNs (you provide)
1. Create a Firebase project; add an **Android app** (package `com.lead360.mobile` or your id) →
   download `google-services.json` into `android/app/`.
2. Add an **iOS app** → `GoogleService-Info.plist` into `ios/Runner/`; upload the **APNs key**
   (.p8) to Firebase → Cloud Messaging.
3. Create a **service account** with the *Firebase Cloud Messaging API* enabled; give its JSON
   to the backend (`Push:Fcm:ServiceAccountJson`) — never commit it.

## C. Flutter client (this repo — ready to add once B exists)
- Add deps: `firebase_core`, `firebase_messaging`, `flutter_local_notifications`.
- On login (and app start when authed):
  - request permission (iOS), get the FCM token, `POST /v1/device-tokens { token, platform }`;
  - listen to `onTokenRefresh` → re-register.
- On logout: `DELETE /v1/device-tokens/{token}` then clear.
- Foreground: show via `flutter_local_notifications`. Tap (fg/bg/terminated):
  read `data.type/entityId` → `context.push('/<type>s/<entityId>')`.
- New module under `lib/features/notifications/` (service + a small in-app list screen that
  reads the existing bell API — mirror the Leads pattern).

> Kept out of v1 deliberately: it requires native config + a backend change + your Firebase
> project, none of which can be scaffolded blind. Everything above is implementation-ready.
