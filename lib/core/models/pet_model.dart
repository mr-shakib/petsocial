class PetModel {
  final String id;
  final String name;
  final String? pictureUrl;
  final int petType;
  final bool isDefault;

  const PetModel({
    required this.id,
    required this.name,
    this.pictureUrl,
    required this.petType,
    required this.isDefault,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) => PetModel(
        id: json['id'] as String,
        name: json['name'] as String,
        pictureUrl: json['pictureUrl'] as String?,
        petType: json['petType'] is int
            ? json['petType'] as int
            : int.tryParse(json['petType']?.toString() ?? '') ?? 0,
        isDefault: json['isDefault'] as bool? ?? false,
      );
}
