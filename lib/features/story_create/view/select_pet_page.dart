import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/pet_model.dart';
import '../../../core/utils/error_parser.dart';
import '../viewmodel/select_pet_viewmodel.dart';

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
                error: (e, _) => _ErrorState(
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
                    : _PetList(pets: pets, w: w),
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
              child: Icon(Icons.close, size: w * 0.065, color: AppColors.textBlack),
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

class _PetList extends StatefulWidget {
  final List<PetModel> pets;
  final double w;
  const _PetList({required this.pets, required this.w});

  @override
  State<_PetList> createState() => _PetListState();
}

class _PetListState extends State<_PetList> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.pets.firstWhere(
      (p) => p.isDefault,
      orElse: () => widget.pets.first,
    ).id;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: widget.pets.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: const Color(0xFFEEE8E3),
        indent: widget.w * 0.2,
      ),
      itemBuilder: (_, i) {
        final pet = widget.pets[i];
        final isSelected = pet.id == _selectedId;
        return _PetTile(
          pet: pet,
          isSelected: isSelected,
          w: widget.w,
          onTap: () {
            setState(() => _selectedId = pet.id);
            Future.delayed(const Duration(milliseconds: 180), () {
              if (context.mounted) {
                context.push('/story/camera', extra: _selectedId);
              }
            });
          },
        );
      },
    );
  }
}

class _PetTile extends StatelessWidget {
  final PetModel pet;
  final bool isSelected;
  final double w;
  final VoidCallback onTap;

  const _PetTile({
    required this.pet,
    required this.isSelected,
    required this.w,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.05,
          vertical: w * 0.04,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: w * 0.075,
              backgroundImage: pet.pictureUrl != null
                  ? NetworkImage(pet.pictureUrl!)
                  : null,
              backgroundColor: AppColors.primaryLight,
              child: pet.pictureUrl == null
                  ? Icon(Icons.pets, color: Colors.white, size: w * 0.06)
                  : null,
            ),
            SizedBox(width: w * 0.04),
            Expanded(
              child: Text(
                pet.name,
                style: TextStyle(
                  fontSize: w * 0.042,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textBlack,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: AppColors.primary, size: w * 0.06),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final double w;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets_outlined, color: AppColors.textGrey, size: w * 0.15),
            SizedBox(height: w * 0.04),
            Text(
              'Could not load your pets',
              style: TextStyle(
                fontSize: w * 0.042,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: w * 0.02),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: w * 0.035),
            ),
            SizedBox(height: w * 0.06),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: Size(w * 0.4, w * 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.14),
                ),
              ),
              child: Text(
                'Try again',
                style: TextStyle(
                  fontSize: w * 0.038,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
