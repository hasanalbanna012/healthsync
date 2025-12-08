import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../constants/app_constants.dart';
import '../models/doctor.dart';
import '../services/doctor_service.dart';
import '../widgets/doctor_card.dart';

class MyDoctorsPage extends StatelessWidget {
  const MyDoctorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorService = DoctorService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Doctors'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: ValueListenableBuilder<Box<Doctor>>(
          valueListenable: doctorService.savedDoctorsListenable,
          builder: (context, savedBox, _) {
            if (savedBox.values.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_search,
                        size: 64, color: AppConstants.textSecondaryColor),
                    SizedBox(height: AppConstants.spacingMedium),
                    Text(
                      'You have not saved any doctors yet.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final doctors = savedBox.values.toList(growable: false);

            return ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return DoctorCard(
                  doctor: doctor,
                  isSaved: true,
                  onToggleSaved: () => doctorService.removeDoctor(doctor.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
