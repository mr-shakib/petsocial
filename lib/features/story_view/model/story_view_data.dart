class StoryViewData {
  final String petName;
  final String ownerName;
  final String? petAvatarUrl;
  final List<String> mediaUrls;
  final List<bool> isVideo;

  const StoryViewData({
    required this.petName,
    required this.ownerName,
    this.petAvatarUrl,
    required this.mediaUrls,
    required this.isVideo,
  });
}
