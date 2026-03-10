class StoryViewData {
  final String petName;
  final String ownerName;
  final String? petAvatarUrl;
  final List<String> storyIds;
  final List<String> mediaUrls;
  final List<bool> isVideo;
  final List<String> createdAts;

  const StoryViewData({
    required this.petName,
    required this.ownerName,
    this.petAvatarUrl,
    required this.storyIds,
    required this.mediaUrls,
    required this.isVideo,
    required this.createdAts,
  });
}
