import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/story_repository.dart';

class StoryCreateState {
  final bool isUploading;
  final double progress; // 0.0 – 1.0
  final bool isDone;
  final String? error;

  const StoryCreateState({
    this.isUploading = false,
    this.progress = 0.0,
    this.isDone = false,
    this.error,
  });

  StoryCreateState copyWith({
    bool? isUploading,
    double? progress,
    bool? isDone,
    String? error,
  }) =>
      StoryCreateState(
        isUploading: isUploading ?? this.isUploading,
        progress: progress ?? this.progress,
        isDone: isDone ?? this.isDone,
        error: error,
      );
}

class StoryCreateNotifier extends Notifier<StoryCreateState> {
  @override
  StoryCreateState build() => const StoryCreateState();

  /// Upload [file] and create a story for [petId].
  /// Returns true on success.
  Future<bool> share({
    required File file,
    required String petId,
    required bool isVideo,
  }) async {
    state = state.copyWith(isUploading: true, progress: 0.0);
    try {
      final repo = ref.read(storyRepositoryProvider);

      final url = await repo.uploadFile(
        file,
        onProgress: (p) => state = state.copyWith(progress: p),
      );

      await repo.createStory(
        petId: petId,
        imageUrl: isVideo ? null : url,
        videoUrl: isVideo ? url : null,
      );

      state = state.copyWith(isUploading: false, isDone: true, progress: 1.0);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void reset() => state = const StoryCreateState();
}

final storyCreateProvider =
    NotifierProvider<StoryCreateNotifier, StoryCreateState>(
  StoryCreateNotifier.new,
);
