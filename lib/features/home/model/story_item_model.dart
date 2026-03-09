/// A single story inside a pet's story group.
class StoryItemModel {
  final String id;
  final String? image;
  final String? video;
  final String createdAt;
  final bool isSeen;

  const StoryItemModel({
    required this.id,
    this.image,
    this.video,
    required this.createdAt,
    required this.isSeen,
  });

  factory StoryItemModel.fromJson(Map<String, dynamic> json) => StoryItemModel(
        id: json['id'] as String,
        image: json['image'] as String?,
        video: json['video'] as String?,
        createdAt: json['createdAt'] as String,
        isSeen: json['isSeen'] as bool? ?? false,
      );
}
