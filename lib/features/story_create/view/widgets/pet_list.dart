import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/pet_model.dart';

class PetList extends StatefulWidget {
  final List<PetModel> pets;
  final double w;

  const PetList({super.key, required this.pets, required this.w});

  @override
  State<PetList> createState() => _PetListState();
}

class _PetListState extends State<PetList> {
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
        return PetTile(
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

class PetTile extends StatelessWidget {
  final PetModel pet;
  final bool isSelected;
  final double w;
  final VoidCallback onTap;

  const PetTile({
    super.key,
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
