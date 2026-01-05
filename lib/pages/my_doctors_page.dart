import 'package:flutter/material.dart';
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
        child: StreamBuilder<List<Doctor>>(
          stream: doctorService.watchSavedDoctors(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Unable to load saved doctors.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final doctors = snapshot.data!;

            if (doctors.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_search,
                        size: 64, color: AppConstants.textSecondaryColor),
                    const SizedBox(height: AppConstants.spacingMedium),
                    const Text(
                      'You have not saved any doctors yet.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

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
