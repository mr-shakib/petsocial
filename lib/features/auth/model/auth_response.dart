class AuthResponse {
  final String id;
  final String token;
  final String? username;
  final String? fullName;
  final String? profilePictureUrl;

  const AuthResponse({
    required this.id,
    required this.token,
    this.username,
    this.fullName,
    this.profilePictureUrl,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        id: json['id'] as String,
        token: json['token'] as String,
        username: json['username'] as String?,
        fullName: json['fullName'] as String?,
        profilePictureUrl: json['profilePictureUrl'] as String?,
      );
}
