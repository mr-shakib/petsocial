# PetSocial — Claude Code Standards

## Project Overview
PetSocial is a Flutter mobile app for sharing pet stories. Built as a Flutter Developer practical coding task.

- **Base URL:** `https://api.thepetsocial.net`
- **Test Account:** `+8801122223333` / `095a@yZ2`
- **Platform:** iOS & Android

---

## Architecture: MVVM + Feature-Based

Each feature is self-contained with 3 layers:

```
features/[feature]/
  ├── models/         → Dart data classes (freezed) + JSON parsing
  ├── repository/     → All Dio API calls, token storage
  ├── viewmodel/      → Riverpod Notifier, state, business logic
  └── view/
      ├── [feature]_page.dart
      └── widgets/    → Extracted sub-widgets (one per file)
```

### Layer Rules
- **View** — pure UI only. Reads ViewModel state, dispatches events. Never calls APIs directly.
- **ViewModel** — business logic and state only. Calls Repository. Never imports Flutter widgets.
- **Repository** — owns all Dio calls and data mapping. No UI concerns.
- **Models** — simple immutable data classes. Use `freezed` + `json_serializable`.

---

## Mandatory Tech Stack

| Concern | Package |
|---------|---------|
| State Management | `flutter_riverpod` + `riverpod_annotation` |
| HTTP Client | `dio` |
| Real-Time | `signalr_netcore` |
| Navigation | `go_router` |
| Secure Storage | `flutter_secure_storage` |
| Fonts | `google_fonts` |
| Media Picker | `image_picker` |
| Image Cache | `cached_network_image` |
| Video | `video_player` |
| Phone Input | `intl_phone_field` |
| Models | `freezed` + `json_serializable` |
| Code Gen | `build_runner` + `riverpod_generator` |

---

## File & Code Rules

### 200-Line Maximum
Every file must stay under **200 lines**. If a file exceeds this:
- Extract each logical widget into its own file under `view/widgets/`
- One widget = one file, named after the widget (snake_case)

### Widget Extraction Pattern
```
view/
  ├── login_page.dart          ← assembles widgets only, no inline widget trees
  └── widgets/
      ├── login_header.dart
      ├── phone_input_field.dart
      ├── password_input_field.dart
      ├── login_illustration.dart
      └── login_footer.dart
```

Page files are assembly-only — they import and compose widgets, contain no large widget trees themselves.

---

## Responsiveness — MediaQuery Everywhere

**Never use hardcoded pixel values.** All sizing must use `MediaQuery`.

```dart
final size = MediaQuery.sizeOf(context);
final w = size.width;
final h = size.height;
```

### Scaling Reference (base: 390×844 screen)

| Value | Formula |
|-------|---------|
| Horizontal padding (24px) | `w * 0.06` |
| Heading font (42px) | `w * 0.108` |
| Title font (26px) | `w * 0.067` |
| Body font (14px) | `w * 0.036` |
| Field font (15px) | `w * 0.038` |
| Button font (16px) | `w * 0.041` |
| Button height (56px) | `h * 0.066` |
| Button border radius | `w * 0.14` |
| Field border radius (16px) | `w * 0.04` |
| Icon size (20px) | `w * 0.05` |
| Illustration size (260px) | `w * 0.65` |
| Small gap (8px) | `h * 0.010` |
| Medium gap (16px) | `h * 0.02` |
| Large gap (24px) | `h * 0.03` |

Each widget calls `MediaQuery.sizeOf(context)` independently inside its own `build()` method.

---

## Typography

| Usage | Font | Weight |
|-------|------|--------|
| Onboarding heading | `GoogleFonts.pacifico` | regular |
| Buttons | `GoogleFonts.workSans` | `FontWeight.w600` |
| Body / general | `GoogleFonts.nunito` (via theme) | varies |

---

## Color Palette — `AppColors`

```dart
// lib/core/constants/app_colors.dart
static const Color primary      = Color(0xFFF25912); // brand orange
static const Color primaryLight = Color(0xFFF0C48A); // illustration circle bg
static const Color background   = Color(0xFFFAF5F2); // screen background
static const Color white        = Color(0xFFFFFFFF);
static const Color textDark     = Color(0xFF1A1A2E);
static const Color textGrey     = Color(0xFF9E9E9E);
static const Color storyUnseen  = Color(0xFFF25912); // story ring, not seen
static const Color storySeen    = Color(0xFFCCCCCC); // story ring, all seen
```

Always use `AppColors.*` constants. Never write hex values inline in widget files.

### Onboarding Gradient
```dart
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFF25912), Color(0x99F25912), Color(0x4DF25912)],
  stops: [0.0, 0.5096, 1.0],
)
```

---

## UI Component Standards

### Buttons
- Shape: pill (`BorderRadius.circular(w * 0.14)`)
- Height: `h * 0.066`
- Font: `GoogleFonts.workSans(fontWeight: FontWeight.w600, fontSize: w * 0.041)`
- Primary: `backgroundColor: AppColors.primary, foregroundColor: Colors.white`
- Secondary: `backgroundColor: Colors.white, foregroundColor: AppColors.textDark`
- Elevation: `0`

### Input Fields
- Background: `AppColors.white`, filled
- Border radius: `w * 0.04`
- Border: none (enabled), `AppColors.primary 1.5px` (focused)
- Content padding: `horizontal: w * 0.04, vertical: h * 0.022`
- Label: bold, `AppColors.textDark`, `w * 0.036`

### Phone Input Field (`intl_phone_field`)
- `showDropdownIcon: false` — no chevron
- `counterText: ''` — no character count
- `dropdownTextStyle` color: `AppColors.textGrey`
- Default country: `BD` (Bangladesh — matches test account +880)

### Password Field
- Always `obscureText: true`
- No visibility toggle icon (eye removed)

### Assets
- All images in `assets/images/` (PNG)
- SVGs in `assets/` (if needed)
- Both paths declared in `pubspec.yaml`

---

## Project File Structure

```
lib/
├── main.dart                          ← ProviderScope + MaterialApp.router
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── auth_interceptor.dart
│   ├── storage/
│   │   └── secure_storage.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── router/
│       └── app_router.dart
└── features/
    ├── onboarding/
    │   └── view/
    │       ├── onboarding_page.dart
    │       └── widgets/
    │           ├── onboarding_title.dart
    │           └── onboarding_buttons.dart
    ├── auth/
    │   ├── models/
    │   ├── repository/
    │   ├── viewmodel/
    │   └── view/
    │       ├── login_page.dart
    │       └── widgets/
    │           ├── login_header.dart
    │           ├── phone_input_field.dart
    │           ├── password_input_field.dart
    │           ├── login_illustration.dart
    │           └── login_footer.dart
    ├── home/
    │   ├── models/
    │   ├── repository/
    │   ├── viewmodel/
    │   └── view/
    │       ├── home_page.dart
    │       └── widgets/
    ├── pets/
    │   ├── models/
    │   ├── repository/
    │   ├── viewmodel/
    │   └── view/
    │       └── widgets/
    ├── create_story/
    │   ├── models/
    │   ├── repository/
    │   ├── viewmodel/
    │   └── view/
    │       ├── create_story_page.dart
    │       └── widgets/
    └── realtime/
        ├── service/
        │   └── signalr_service.dart
        └── viewmodel/
            └── signalr_viewmodel.dart
```

---

## Navigation Routes

| Route | Page |
|-------|------|
| `/` | `OnboardingPage` |
| `/login` | `LoginPage` |
| `/home` | `HomePage` |
| `/create-story` | `CreateStoryPage` |

---

## API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/auth/login` | No | Login |
| GET | `/api/pets?mine=true` | Yes | Get user's pets |
| POST | `/api/files/upload` | Yes | Upload image/video (multipart) |
| POST | `/api/stories` | Yes | Create story |
| GET | `/api/stories` | Yes | Get active stories grouped by pet |

**SignalR Hub:** `https://api.thepetsocial.net/hubs/feed?access_token=<token>`
**Event:** `NewStoryCreated` → re-fetch `GET /api/stories` and update UI

---

## General Coding Habits

- Prefer `const` constructors wherever possible
- Use `MediaQuery.sizeOf(context)` (not `MediaQuery.of(context).size`) — more efficient
- No magic numbers inline — use `AppColors`, scaled `w`/`h` values
- No logic inside widget `build()` methods — delegate to ViewModel
- Mark completed ViewModel methods with loading state before async calls
- Always `dispose()` controllers in StatefulWidget
