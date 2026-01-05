import 'package:flutter/material.dart';
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
        child: StreamBuilder<List<Medicine>>(
          stream: medicineService.watchSavedMedicines(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Unable to load saved medicines.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final medicines = snapshot.data!;

            if (medicines.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.medication_liquid,
                        size: 64, color: AppConstants.textSecondaryColor),
                    const SizedBox(height: AppConstants.spacingMedium),
                    const Text(
                      'You have not saved any medicines yet.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

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
