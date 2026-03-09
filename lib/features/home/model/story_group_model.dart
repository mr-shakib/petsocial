import 'story_item_model.dart';

/// One pet's story group as returned by GET /api/stories.
class StoryGroupModel {
  final String petId;
  final String petName;
  final String? petPictureUrl;
  final String ownerId;
  final String ownerUsername;
  final String? ownerProfilePictureUrl;
  final List<StoryItemModel> stories;
  final bool allSeen;
  final bool isFollowed;

  const StoryGroupModel({
    required this.petId,
    required this.petName,
    this.petPictureUrl,
    required this.ownerId,
    required this.ownerUsername,
    this.ownerProfilePictureUrl,
    required this.stories,
    required this.allSeen,
    required this.isFollowed,
  });

  factory StoryGroupModel.fromJson(Map<String, dynamic> json) {
    final pet = json['pet'] as Map<String, dynamic>;
    final user = json['user'] as Map<String, dynamic>;
    final storiesJson = json['stories'] as List<dynamic>;

    return StoryGroupModel(
      petId: pet['id'] as String,
      petName: pet['name'] as String,
      petPictureUrl: pet['pictureUrl'] as String?,
      ownerId: user['id'] as String,
      ownerUsername: user['username'] as String,
      ownerProfilePictureUrl: user['profilePictureUrl'] as String?,
      stories: storiesJson
          .map((e) => StoryItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      allSeen: json['allSeen'] as bool? ?? false,
      isFollowed: json['isFollowed'] as bool? ?? false,
    );
  }
}
