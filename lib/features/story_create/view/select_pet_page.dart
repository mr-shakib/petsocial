import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/error_parser.dart';
import '../viewmodel/select_pet_viewmodel.dart';
import 'widgets/pet_error_state.dart';
import 'widgets/pet_list.dart';

class SelectPetPage extends ConsumerWidget {
  const SelectPetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.sizeOf(context).width;
    final petsAsync = ref.watch(selectPetProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(w: w),
            Expanded(
              child: petsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => PetErrorState(
                  message: ErrorParser.parse(e),
                  onRetry: () => ref.invalidate(selectPetProvider),
                  w: w,
                ),
                data: (pets) => pets.isEmpty
                    ? Center(
                        child: Text(
                          'No pets found.',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: w * 0.038,
                          ),
                        ),
                      )
                    : PetList(pets: pets, w: w),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final double w;
  const _Header({required this.w});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.04),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Icon(Icons.close,
                  size: w * 0.065, color: AppColors.textBlack),
            ),
          ),
          Text(
            'Select profile',
            style: TextStyle(
              fontSize: w * 0.045,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}
