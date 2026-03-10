import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/token_service.dart';
import '../model/story_group_model.dart';
import '../repository/story_repository.dart';

class HomeStoryNotifier extends AsyncNotifier<List<StoryGroupModel>> {
  @override
  Future<List<StoryGroupModel>> build() =>
      ref.read(homeStoryRepositoryProvider).fetchStories();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(homeStoryRepositoryProvider).fetchStories(),
    );
  }
}

final homeStoryProvider =
    AsyncNotifierProvider<HomeStoryNotifier, List<StoryGroupModel>>(
  HomeStoryNotifier.new,
);

/// Exposes the logged-in user's profile picture URL from secure storage.
final profilePictureProvider = FutureProvider<String?>((ref) async {
  return TokenService.getProfilePictureUrl();
});
