/// Response returned by POST /api/stories
class StoryResponse {
  final String id;
  final String? image;
  final String? video;
  final String createdAt;
  final bool isShared;
  final bool isSeen;

  const StoryResponse({
    required this.id,
    this.image,
    this.video,
    required this.createdAt,
    required this.isShared,
    required this.isSeen,
  });

  factory StoryResponse.fromJson(Map<String, dynamic> json) => StoryResponse(
        id: json['id'] as String,
        image: json['image'] as String?,
        video: json['video'] as String?,
        createdAt: json['createdAt'] as String,
        isShared: json['isShared'] as bool? ?? false,
        isSeen: json['isSeen'] as bool? ?? false,
      );
}
