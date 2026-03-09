import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/pet_model.dart';
import '../repository/pet_repository.dart';

class SelectPetNotifier extends AsyncNotifier<List<PetModel>> {
  @override
  Future<List<PetModel>> build() =>
      ref.read(petRepositoryProvider).getMyPets();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(petRepositoryProvider).getMyPets(),
    );
  }
}

final selectPetProvider =
    AsyncNotifierProvider<SelectPetNotifier, List<PetModel>>(
  SelectPetNotifier.new,
);
