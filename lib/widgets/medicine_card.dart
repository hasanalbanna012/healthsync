import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/medicine.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.isSaved,
    required this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
    final buttonLabel =
        isSaved ? 'Remove from My Medicines' : 'Save to My Medicines';
    final buttonIcon =
        isSaved ? Icons.delete_outline : Icons.bookmark_add_outlined;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
      elevation: AppConstants.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusSmall),
              child: medicine.imageUrl.isNotEmpty
                  ? Image.network(
                      medicine.imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _placeholderImage();
                      },
                    )
                  : _placeholderImage(),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicine.genericName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textSecondaryColor,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  OutlinedButton.icon(
                    onPressed: onToggleSaved,
                    icon: Icon(buttonIcon),
                    label: Text(buttonLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 72,
      height: 72,
      color: AppConstants.backgroundColor,
      child: const Icon(Icons.medication, size: 36),
    );
  }
}
