import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../model/story_response.dart';

class StoryRepository {
  /// Uploads a file and returns the CDN URL.
  Future<String> uploadFile(
    File file, {
    void Function(double progress)? onProgress,
  }) async {
    final MultipartFile multipart;
    if (file.path.startsWith('content://')) {
      final bytes = await file.readAsBytes();
      multipart = MultipartFile.fromBytes(bytes,
          filename: file.path.split('/').last);
    } else {
      multipart = await MultipartFile.fromFile(file.path);
    }
    final formData = FormData.fromMap({'file': multipart});

    final response = await dioClient.post(
      '/api/files/upload',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );
    return response.data['url'] as String;
  }

  /// Creates a story with an image or video URL. Returns the created story.
  Future<StoryResponse> createStory({
    required String petId,
    String? imageUrl,
    String? videoUrl,
  }) async {
    final body = <String, dynamic>{'petId': petId};
    if (imageUrl != null) body['image'] = imageUrl;
    if (videoUrl != null) body['video'] = videoUrl;
    final response = await dioClient.post('/api/stories', data: body);
    return StoryResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

final storyRepositoryProvider =
    Provider<StoryRepository>((_) => StoryRepository());
