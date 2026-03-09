# PetSocial Flutter App — Implementation Plan

## Overview

**Company:** PetSocial
**Position:** Flutter Developer Practical Coding Task
**Duration:** 72 Hours
**Base URL:** `https://api.thepetsocial.net`
**Test Account:** Phone: `+8801122223333` | Password: `095a@yZ2`

---

## Architecture: MVVM + Feature-Based

Each feature is self-contained with 3 layers:

```
Model      → Dart data classes + Repository (API calls)
ViewModel  → Riverpod Notifier (state + business logic)
View       → Flutter widgets/pages (pure UI, no logic)
```

**Rules:**
- Views only read from ViewModel, never call APIs directly
- ViewModels call Repositories, never touch widgets
- Repositories handle all Dio calls and data mapping
- Models are simple immutable data classes (freezed)

---

## Features to Build

| # | Feature | Description |
|---|---------|-------------|
| 1 | Login | Phone number & password authentication |
| 2 | Home Screen | Horizontal scrollable story list grouped by pet |
| 3 | Create Story | Select pet → pick image/video → upload → create |
| 4 | Real-Time | SignalR hub for live story updates |

---

## API Reference

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/login` | No | Login |
| GET | `/api/pets?mine=true` | Yes | Get user's pets |
| POST | `/api/files/upload` | Yes | Upload image/video (multipart) |
| POST | `/api/stories` | Yes | Create story |
| GET | `/api/stories` | Yes | Get active stories grouped by pet |

**Auth header:** `Authorization: Bearer <token>`
**SignalR Hub:** `https://api.thepetsocial.net/hubs/feed?access_token=<token>`
**Event:** `NewStoryCreated` → `{ storyId, userId, petId }`

---

## Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # State Management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # HTTP
  dio: ^5.8.0+1

  # Real-Time
  signalr_netcore: ^1.3.5

  # Secure Storage
  flutter_secure_storage: ^9.2.4

  # Navigation
  go_router: ^14.6.3

  # Media
  image_picker: ^1.1.2
  cached_network_image: ^3.4.1
  video_player: ^2.9.2

  # Models
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.4.14
  riverpod_generator: ^2.6.3
  freezed: ^2.5.8
  json_serializable: ^6.9.2
```

---

## Project Structure

```
lib/
├── main.dart
│
├── core/
│   ├── constants/
│   │   └── api_constants.dart          # Base URL, all endpoint paths
│   ├── network/
│   │   ├── dio_client.dart             # Configured Dio singleton (provider)
│   │   └── auth_interceptor.dart       # Injects Bearer token on every request
│   ├── storage/
│   │   └── secure_storage.dart         # Token read/write/delete wrapper
│   └── router/
│       └── app_router.dart             # go_router with auth redirect logic
│
└── features/
    ├── auth/
    │   ├── models/
    │   │   ├── login_request.dart       # { loginIdentifier, password }
    │   │   └── login_response.dart      # { id, username, token, refreshToken, ... }
    │   ├── repository/
    │   │   └── auth_repository.dart     # login() → calls Dio, saves token
    │   ├── viewmodel/
    │   │   └── auth_viewmodel.dart      # AuthState + AuthViewModel (AsyncNotifier)
    │   └── view/
    │       ├── login_page.dart
    │       └── widgets/
    │           ├── phone_input_field.dart
    │           └── password_input_field.dart
    │
    ├── home/
    │   ├── models/
    │   │   ├── story_group.dart         # { user, pet, stories[], allSeen, isFollowed }
    │   │   └── story_item.dart          # { id, image?, video?, createdAt, isSeen }
    │   ├── repository/
    │   │   └── stories_repository.dart  # getStories() → GET /api/stories
    │   ├── viewmodel/
    │   │   └── stories_viewmodel.dart   # StoriesState + StoriesViewModel
    │   └── view/
    │       ├── home_page.dart
    │       └── widgets/
    │           ├── story_bar.dart        # Horizontal ListView (+ button + avatars)
    │           ├── story_avatar.dart     # Pet avatar with seen/unseen ring
    │           └── add_story_button.dart # First item in story bar
    │
    ├── pets/
    │   ├── models/
    │   │   └── pet.dart                 # { id, name, pictureUrl, petType, isDefault }
    │   ├── repository/
    │   │   └── pets_repository.dart     # getMyPets() → GET /api/pets?mine=true
    │   ├── viewmodel/
    │   │   └── pets_viewmodel.dart      # PetsViewModel (FutureProvider)
    │   └── view/
    │       └── widgets/
    │           └── pet_selection_sheet.dart  # Modal bottom sheet
    │
    ├── create_story/
    │   ├── models/
    │   │   ├── upload_response.dart     # { url, id }
    │   │   └── create_story_request.dart # { image?, video?, petId }
    │   ├── repository/
    │   │   └── create_story_repository.dart  # uploadFile() + createStory()
    │   ├── viewmodel/
    │   │   └── create_story_viewmodel.dart   # CreateStoryState + Notifier
    │   └── view/
    │       ├── create_story_page.dart
    │       └── widgets/
    │           └── media_preview.dart    # Preview selected image/video
    │
    └── realtime/
        ├── service/
        │   └── signalr_service.dart     # Hub connect/disconnect/listen
        └── viewmodel/
            └── signalr_viewmodel.dart   # Provider that manages SignalR lifecycle
```

---

## Implementation Steps

### Step 1 — Project Setup
- [ ] Update `pubspec.yaml` with all packages, run `flutter pub get`
- [ ] Create full folder structure above
- [ ] Configure `analysis_options.yaml`

---

### Step 2 — Core Layer

#### `api_constants.dart`
```dart
class ApiConstants {
  static const String baseUrl     = 'https://api.thepetsocial.net';
  static const String login       = '/api/auth/login';
  static const String myPets      = '/api/pets';
  static const String uploadFile  = '/api/files/upload';
  static const String stories     = '/api/stories';
  static const String signalrHub  = '/hubs/feed';
}
```

#### `secure_storage.dart`
- Wrap `FlutterSecureStorage`
- Methods: `saveToken(String)`, `readToken()`, `deleteToken()`
- Also store: `userId`, `username` for profile display

#### `dio_client.dart`
```dart
// Riverpod provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  dio.interceptors.add(AuthInterceptor(ref));
  return dio;
});
```

#### `auth_interceptor.dart`
- On each request: read token from `SecureStorage`, add `Authorization: Bearer <token>`
- On 401 response: clear token, redirect to `/login`

#### `app_router.dart`
- Routes: `/login`, `/home`, `/create-story`
- `redirect` callback: if no token → `/login`, else `/home`
- After login success → `context.go('/home')`

---

### Step 3 — Auth Feature

#### Model: `login_request.dart`
```dart
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String loginIdentifier,
    required String password,
  }) = _LoginRequest;
  factory LoginRequest.fromJson(Map<String, dynamic> json) => ...
}
```

#### Model: `login_response.dart`
Fields: `id`, `username`, `fullName`, `email`, `phoneNumber`, `profilePictureUrl`, `token`, `refreshToken`, `tokenExpiresAt`, `role`

#### Repository: `auth_repository.dart`
```dart
class AuthRepository {
  final Dio _dio;
  final SecureStorage _storage;

  Future<LoginResponse> login(String phone, String password) async {
    final res = await _dio.post(ApiConstants.login,
      data: LoginRequest(loginIdentifier: phone, password: password).toJson());
    final response = LoginResponse.fromJson(res.data);
    await _storage.saveToken(response.token);
    return response;
  }

  Future<void> logout() => _storage.deleteToken();
}
```

#### ViewModel: `auth_viewmodel.dart`
```dart
// State
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _AuthState;
}

// ViewModel
@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  AuthState build() => const AuthState();

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await ref.read(authRepositoryProvider).login(phone, password);
      // Connect SignalR
      // Navigate to home (via router)
    } on DioException catch (e) {
      state = state.copyWith(errorMessage: _mapError(e));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
```

#### View: `login_page.dart`
- Logo / app name at top
- `PhoneInputField` — text input, keyboard: phone, hint: `+8801122223333`
- `PasswordInputField` — obscured, trailing eye icon toggle
- Login button — shows `CircularProgressIndicator` when `isLoading`
- Watches `authViewModel` state, shows error below button on `errorMessage != null`
- On success: router navigates to `/home`

---

### Step 4 — Pets Feature

#### Model: `pet.dart`
```dart
@freezed
class Pet with _$Pet {
  const factory Pet({
    required String id,
    required String name,
    String? pictureUrl,
    required int petType,
    required bool isDefault,
  }) = _Pet;
  factory Pet.fromJson(Map<String, dynamic> json) => ...
}
```

#### Repository: `pets_repository.dart`
```dart
Future<List<Pet>> getMyPets() async {
  final res = await _dio.get(ApiConstants.myPets, queryParameters: {'mine': true});
  return (res.data['data'] as List).map((e) => Pet.fromJson(e)).toList();
}
```

#### ViewModel: `pets_viewmodel.dart`
```dart
@riverpod
Future<List<Pet>> petsViewModel(PetsViewModelRef ref) {
  return ref.read(petsRepositoryProvider).getMyPets();
}
```

#### View: `pet_selection_sheet.dart`
- `showModalBottomSheet` with a `ListView` of pets
- Each tile: `CircleAvatar` (pet image) + pet name + pet type label
- Taps return the selected `Pet` back to the caller

---

### Step 5 — Home / Stories Feature

#### Models
```dart
// story_item.dart
@freezed
class StoryItem with _$StoryItem {
  const factory StoryItem({
    required String id,
    String? image,
    String? video,
    required String createdAt,
    required bool isSeen,
  }) = _StoryItem;
}

// story_group.dart
@freezed
class StoryGroup with _$StoryGroup {
  const factory StoryGroup({
    required String petId,
    required String petName,
    String? petPictureUrl,
    required String userId,
    required String username,
    required List<StoryItem> stories,
    required bool allSeen,
    required bool isFollowed,
  }) = _StoryGroup;
}
```

#### Repository: `stories_repository.dart`
```dart
Future<List<StoryGroup>> getStories() async {
  final res = await _dio.get(ApiConstants.stories);
  return (res.data as List).map((e) => StoryGroup.fromJson(e)).toList();
}
```

#### ViewModel: `stories_viewmodel.dart`
```dart
@freezed
class StoriesState with _$StoriesState {
  const factory StoriesState({
    @Default([]) List<StoryGroup> groups,
    @Default(false) bool isLoading,
    String? error,
  }) = _StoriesState;
}

@riverpod
class StoriesViewModel extends _$StoriesViewModel {
  @override
  StoriesState build() {
    fetchStories(); // auto-load on creation
    return const StoriesState();
  }

  Future<void> fetchStories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final groups = await ref.read(storiesRepositoryProvider).getStories();
      state = state.copyWith(groups: groups);
    } on DioException catch (e) {
      state = state.copyWith(error: e.message);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Called by SignalR on NewStoryCreated
  Future<void> refresh() => fetchStories();
}
```

#### View: `home_page.dart`
- `Scaffold` with `AppBar` (PetSocial branding)
- `StoryBar` widget at top (fixed height ~100px)
- Main body: placeholder feed or empty state

#### Widget: `story_bar.dart`
```dart
// Horizontal ListView
ListView.builder(
  scrollDirection: Axis.horizontal,
  itemCount: groups.length + 1,  // +1 for Add button
  itemBuilder: (context, index) {
    if (index == 0) return AddStoryButton(...);
    return StoryAvatar(group: groups[index - 1]);
  },
)
```

#### Widget: `story_avatar.dart`
- `CachedNetworkImage` in a circle (80×80)
- Border: colored ring if `!allSeen`, grey if `allSeen`
- Pet name below in small text
- `onTap` → (future: story viewer)

---

### Step 6 — Create Story Feature

#### Models
- `upload_response.dart` → `{ url, id }`
- `create_story_request.dart` → `{ image?, video?, petId }`

#### Repository: `create_story_repository.dart`
```dart
Future<UploadResponse> uploadFile(File file) async {
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(file.path),
  });
  final res = await _dio.post(
    ApiConstants.uploadFile,
    data: formData,
    onSendProgress: (sent, total) { /* expose progress */ },
  );
  return UploadResponse.fromJson(res.data);
}

Future<void> createStory(CreateStoryRequest request) async {
  await _dio.post(ApiConstants.stories, data: request.toJson());
}
```

#### ViewModel: `create_story_viewmodel.dart`
```dart
@freezed
class CreateStoryState with _$CreateStoryState {
  const factory CreateStoryState({
    Pet? selectedPet,
    File? pickedFile,
    bool? isVideo,
    @Default(0.0) double uploadProgress,
    @Default(false) bool isUploading,
    @Default(false) bool isCreating,
    @Default(false) bool isSuccess,
    String? error,
  }) = _CreateStoryState;
}

@riverpod
class CreateStoryViewModel extends _$CreateStoryViewModel {
  @override
  CreateStoryState build() => const CreateStoryState();

  void selectPet(Pet pet) =>
    state = state.copyWith(selectedPet: pet);

  Future<void> pickMedia({required bool fromCamera, required bool isVideo}) async {
    final picker = ImagePicker();
    final XFile? file = isVideo
      ? await picker.pickVideo(source: fromCamera ? ImageSource.camera : ImageSource.gallery)
      : await picker.pickImage(source: fromCamera ? ImageSource.camera : ImageSource.gallery);
    if (file != null) {
      state = state.copyWith(pickedFile: File(file.path), isVideo: isVideo);
    }
  }

  Future<void> submit() async {
    final pet = state.selectedPet;
    final file = state.pickedFile;
    if (pet == null || file == null) return;

    state = state.copyWith(isUploading: true, error: null);
    try {
      final uploaded = await ref.read(createStoryRepositoryProvider).uploadFile(file);
      state = state.copyWith(isUploading: false, isCreating: true);

      final request = state.isVideo == true
        ? CreateStoryRequest(video: uploaded.url, petId: pet.id)
        : CreateStoryRequest(image: uploaded.url, petId: pet.id);

      await ref.read(createStoryRepositoryProvider).createStory(request);

      // Refresh home stories
      ref.read(storiesViewModelProvider.notifier).refresh();
      state = state.copyWith(isCreating: false, isSuccess: true);
    } on DioException catch (e) {
      state = state.copyWith(isUploading: false, isCreating: false, error: e.message);
    }
  }
}
```

#### View: `create_story_page.dart`
Flow:
1. Page opens → `PetSelectionSheet` shown immediately
2. After pet selected → show two buttons: "Image" / "Video" (gallery or camera)
3. After file picked → `MediaPreview` widget shown
4. "Post" button → calls `viewModel.submit()`
5. Linear progress bar while uploading (`uploadProgress`)
6. On `isSuccess` → `context.pop()` back to home

---

### Step 7 — Real-Time (SignalR)

#### `signalr_service.dart`
```dart
class SignalRService {
  HubConnection? _connection;
  Function()? onNewStory;

  Future<void> connect(String token) async {
    _connection = HubConnectionBuilder()
      .withUrl(
        '${ApiConstants.baseUrl}${ApiConstants.signalrHub}',
        options: HttpConnectionOptions(
          accessTokenFactory: () async => token,
        ),
      )
      .withAutomaticReconnect()
      .build();

    _connection!.on('NewStoryCreated', (_) => onNewStory?.call());

    await _connection!.start();
  }

  Future<void> disconnect() async => await _connection?.stop();
}
```

#### `signalr_viewmodel.dart`
```dart
@riverpod
SignalRService signalRViewModel(SignalRViewModelRef ref) {
  final service = SignalRService();

  service.onNewStory = () {
    ref.read(storiesViewModelProvider.notifier).refresh();
  };

  ref.onDispose(() => service.disconnect());
  return service;
}
```

- After login success in `AuthViewModel`:
  ```dart
  final token = await ref.read(secureStorageProvider).readToken();
  ref.read(signalRViewModelProvider).connect(token!);
  ```

---

### Step 8 — `main.dart`
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PetSocialApp()));
}

class PetSocialApp extends ConsumerWidget {
  const PetSocialApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'PetSocial',
      theme: AppTheme.light,  // match Figma
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
```

---

## Data Flow

### Login
```
LoginPage (View)
  → AuthViewModel.login(phone, password)
    → AuthRepository.login()
      → POST /api/auth/login
      → SecureStorage.saveToken()
    → SignalRService.connect(token)
    → router.go('/home')
```

### Create Story
```
AddStoryButton tap (View)
  → PetSelectionSheet → picks Pet
  → CreateStoryViewModel.selectPet(pet)
  → image_picker → picks File
  → CreateStoryViewModel.pickMedia()
  → Post button tap
  → CreateStoryViewModel.submit()
    → CreateStoryRepository.uploadFile(file)  → POST /api/files/upload
    → CreateStoryRepository.createStory(req)  → POST /api/stories
    → StoriesViewModel.refresh()              → GET /api/stories
  → router.pop() back to home
```

### Real-Time Update
```
SignalR hub receives 'NewStoryCreated'
  → SignalRService.onNewStory callback
    → StoriesViewModel.refresh()
      → StoriesRepository.getStories()   → GET /api/stories
      → state.groups updated
        → StoryBar re-renders
```

---

## File Creation Order

| # | File | Reason |
|---|------|--------|
| 1 | `pubspec.yaml` | Packages first |
| 2 | `core/constants/api_constants.dart` | Used everywhere |
| 3 | `core/storage/secure_storage.dart` | Auth depends on it |
| 4 | `core/network/dio_client.dart` + `auth_interceptor.dart` | All repos depend on it |
| 5 | `core/router/app_router.dart` | Navigation |
| 6 | `auth/` — model → repo → viewmodel → view | First user-facing flow |
| 7 | `pets/` — model → repo → viewmodel → view | Needed by create story |
| 8 | `home/` — model → repo → viewmodel → view | Core screen |
| 9 | `create_story/` — model → repo → viewmodel → view | Depends on pets + home |
| 10 | `realtime/` — service → viewmodel | Wire up last |
| 11 | `main.dart` | Entry point |

---

## MVVM Layer Responsibilities Summary

| Layer | Responsibility | Does NOT |
|-------|---------------|----------|
| **Model** (data class + repository) | API calls, JSON parsing, token storage | Touch widgets, hold UI state |
| **ViewModel** (Riverpod Notifier) | State, business logic, calls repository | Import Flutter widgets |
| **View** (Widget/Page) | Render UI, dispatch events to ViewModel | Call APIs, contain logic |
