# PetSocial — Flutter Developer Practical Task

A Flutter mobile application built as a practical coding task for PetSocial. Implements phone-based authentication, a pet story feed with real-time updates via SignalR, and a full story creation flow with image/video upload.

---

## Features

| # | Feature | Status |
|---|---------|--------|
| 1 | Login with phone number & password | Done |
| 2 | Home screen with horizontal story feed grouped by pet | Done |
| 3 | Create story — select pet, pick image or video, upload and post | Done |
| 4 | Real-time story updates via SignalR (`NewStoryCreated` event) | Done |

---

## Tech Stack

| Concern | Package |
|---------|---------|
| State Management | `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator` |
| HTTP Client | `dio` |
| Real-Time | `signalr_netcore` |
| Navigation | `go_router` |
| Secure Storage | `flutter_secure_storage` |
| Fonts | `google_fonts` |
| Media Picker | `image_picker` |
| Camera | `camera` |
| Image Cache | `cached_network_image` |
| Video Playback | `media_kit` + `media_kit_video` |
| Phone Input | `intl_phone_field` |
| SVG Icons | `flutter_svg` |
| Models | `freezed` + `json_serializable` |
| Code Gen | `build_runner` |

---

## Architecture

MVVM + feature-based. Each feature is fully self-contained:

```
lib/
├── main.dart
├── core/
│   ├── constants/        ← AppColors
│   ├── network/          ← DioClient, AuthInterceptor
│   ├── router/           ← go_router config
│   ├── services/         ← SignalR service, TokenService
│   └── theme/            ← AppTheme
└── features/
    ├── onboarding/       ← splash/onboarding screen
    ├── auth/             ← login (model, repo, viewmodel, view)
    ├── home/             ← story feed (model, repo, viewmodel, view)
    ├── story_create/     ← pet select + camera + upload + post
    └── story_view/       ← full-screen story viewer with progress bars
```

### Layer responsibilities

- **View** — UI only. Reads ViewModel state, dispatches events. No API calls.
- **ViewModel** — business logic and state via Riverpod `Notifier`. Calls Repository.
- **Repository** — all Dio calls and data mapping. No UI imports.
- **Model** — immutable data classes using `freezed` + `json_serializable`.

---

## API Reference

**Base URL:** `https://api.thepetsocial.net`

All authenticated endpoints require:
```
Authorization: Bearer <token>
```

### Endpoints used

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/auth/login` | No | Login, returns JWT |
| GET | `/api/pets?mine=true` | Yes | Get current user's pets |
| POST | `/api/files/upload` | Yes | Upload image or video (multipart) |
| POST | `/api/stories` | Yes | Create a story |
| GET | `/api/stories` | Yes | Get active stories grouped by pet |

### Login

```
POST /api/auth/login
Content-Type: application/json

{
  "loginIdentifier": "+8801122223333",
  "password": "095a@yZ2"
}
```

Response includes `token` (JWT) and `refreshToken`. The JWT is stored securely via `flutter_secure_storage` and attached to all subsequent requests by `AuthInterceptor`.

### Upload File

```
POST /api/files/upload
Content-Type: multipart/form-data
Authorization: Bearer <token>

file: <image.jpg | video.mp4>
```

Returns `{ "url": "...", "id": "..." }`. The `url` is used in the create story request.

### Create Story

```
POST /api/stories
Content-Type: application/json
Authorization: Bearer <token>

// Image story
{ "image": "<cdn_url>", "petId": "<uuid>" }

// Video story
{ "video": "<cdn_url>", "petId": "<uuid>" }
```

### Get Active Stories

```
GET /api/stories
Authorization: Bearer <token>
```

Returns an array of story groups. Each group:

```json
{
  "user": { "id": "...", "username": "..." },
  "pet": { "id": "...", "name": "Buddy", "pictureUrl": "..." },
  "stories": [
    { "id": "...", "image": "...", "video": null, "isSeen": false }
  ],
  "allSeen": false,
  "isFollowed": true
}
```

---

## Real-Time Updates (SignalR)

**Hub URL:** `https://api.thepetsocial.net/hubs/feed`

Authentication is passed as a query parameter on connect:
```
/hubs/feed?access_token=<token>
```

**Event:** `NewStoryCreated` — payload: `{ storyId, userId, petId }`

When this event fires, the app automatically re-fetches `GET /api/stories` and updates the home feed. The service also handles automatic reconnection on connection loss.

---

## Screens

### Onboarding
Entry screen with brand illustration and navigation to login.

### Login
- Phone number input with country code picker (`intl_phone_field`, default: `BD`)
- Password field
- Login button posts to `/api/auth/login`, stores JWT, navigates to Home
- Inline error message on failure

### Home
- Horizontal story bar at top — stories grouped by pet with seen/unseen ring indicator
- First item is an "Add Story" button
- Tapping a pet's story ring opens the full-screen story viewer
- SignalR keeps the feed live without manual refresh

### Story Viewer
- Full-screen swipeable viewer with per-story progress bars
- Supports image and video stories
- Tap left/right to navigate, hold to pause
- Header shows pet avatar, name, and timestamp

### Create Story
1. Tap "Add Story" → pet selection sheet lists pets from `GET /api/pets?mine=true`
2. Select pet → camera/gallery picker
3. Preview selected media → confirm
4. Upload via `POST /api/files/upload` → create via `POST /api/stories`
5. Loading state shown during upload and creation
6. On success, story feed refreshes automatically

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.5.0`
- Dart SDK `^3.5.0`
- Android SDK / Xcode (for iOS)

### Setup

```bash
# Install dependencies
flutter pub get

# Run code generation (freezed, riverpod, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Android permissions

The following permissions are declared in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

---

## Test Account

```
Phone:    +8801122223333
Password: 095a@yZ2
```

---

## Project Conventions

- **200-line file limit** — every file stays under 200 lines; widgets are extracted into `view/widgets/`
- **No hardcoded sizes** — all dimensions use `MediaQuery.sizeOf(context)` scaled against a 390×844 base
- **No inline colors** — all colors via `AppColors` constants
- **Fonts** — Pacifico (onboarding heading), Work Sans w600 (buttons), Nunito (body)
- **`const` constructors** wherever possible
