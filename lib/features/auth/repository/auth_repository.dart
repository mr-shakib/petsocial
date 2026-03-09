import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../model/auth_response.dart';

export '../model/auth_response.dart';

class AuthRepository {
  Future<AuthResponse> login(String loginIdentifier, String password) async {
    final response = await dioClient.post(
      '/api/auth/login',
      data: {'loginIdentifier': loginIdentifier, 'password': password},
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((_) => AuthRepository());
