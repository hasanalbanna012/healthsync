import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../constants/app_constants.dart';
import '../models/medicine.dart';
import '../services/medicine_service.dart';
import '../widgets/medicine_card.dart';

class MyMedicinesPage extends StatelessWidget {
  const MyMedicinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final medicineService = MedicineService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medicines'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: ValueListenableBuilder<Box<Medicine>>(
          valueListenable: medicineService.savedMedicinesListenable,
          builder: (context, savedBox, _) {
            if (savedBox.values.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.medication_liquid,
                        size: 64, color: AppConstants.textSecondaryColor),
                    SizedBox(height: AppConstants.spacingMedium),
                    Text(
                      'You have not saved any medicines yet.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final medicines = savedBox.values.toList(growable: false);

            return ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicines[index];
                return MedicineCard(
                  medicine: medicine,
                  isSaved: true,
                  onToggleSaved: () =>
                      medicineService.removeMedicine(medicine.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
