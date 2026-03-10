import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../model/story_group_model.dart';

class HomeStoryRepository {
  Future<List<StoryGroupModel>> fetchStories() async {
    final response = await dioClient.get('/api/stories');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => StoryGroupModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final homeStoryRepositoryProvider =
    Provider<HomeStoryRepository>((_) => HomeStoryRepository());
