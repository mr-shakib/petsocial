import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/pet_model.dart';
import '../../../core/network/dio_client.dart';

class PetRepository {
  Future<List<PetModel>> getMyPets() async {
    final response = await dioClient.get(
      '/api/pets',
      queryParameters: {'mine': true},
    );
    final data = (response.data['data'] as List<dynamic>);
    return data
        .map((e) => PetModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final petRepositoryProvider =
    Provider<PetRepository>((_) => PetRepository());
