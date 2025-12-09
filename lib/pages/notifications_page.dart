import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../models/bmi_record.dart';
import '../models/doctor.dart';
import '../models/medicine.dart';
import '../services/doctor_service.dart';
import '../services/medicine_service.dart';
import 'health_index_page.dart';
import 'my_doctors_page.dart';
import 'my_medicines_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final medicineService = MedicineService();
    final doctorService = DoctorService();
    final bmiBox = Hive.box<BMIRecord>('bmi_records');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        children: [
          _SectionHeader(
            title: 'Health Index Updates',
            icon: Icons.health_and_safety,
            iconColor: AppConstants.successColor,
          ),
          ValueListenableBuilder<Box<BMIRecord>>(
            valueListenable: bmiBox.listenable(),
            builder: (context, box, _) {
              if (box.values.isEmpty) {
                return const _EmptyNotification(
                  message: 'No BMI activity yet',
                  hint: 'Record your BMI to see updates here.',
                );
              }

              final records = box.values.toList(growable: false)
                ..sort(
                  (a, b) => b.dateRecorded.compareTo(a.dateRecorded),
                );

              return Column(
                children: [
                  for (final record in records.take(10))
                    _NotificationCard(
                      icon: Icons.monitor_weight,
                      iconColor: AppConstants.successColor,
                      title:
                          'BMI ${record.bmi.toStringAsFixed(1)} • ${record.category}',
                      subtitle:
                          'Weight ${record.weight.toStringAsFixed(1)}kg • Height ${record.height.toStringAsFixed(1)}cm',
                      timestamp: _formatTimestamp(record.dateRecorded),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HealthIndexPage(),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          _SectionHeader(
            title: 'My Medicines Activity',
            icon: Icons.medication,
            iconColor: AppConstants.primaryColor,
          ),
          ValueListenableBuilder<Box<Medicine>>(
            valueListenable: medicineService.savedMedicinesListenable,
            builder: (context, box, _) {
              if (box.values.isEmpty) {
                return const _EmptyNotification(
                  message: 'No medicines saved',
                  hint: 'Save medicines to receive quick reminders here.',
                );
              }

              final medicines = box.values.toList(growable: false)
                ..sort((a, b) => a.name.compareTo(b.name));

              return Column(
                children: [
                  for (final medicine in medicines)
                    _NotificationCard(
                      icon: Icons.local_pharmacy,
                      iconColor: AppConstants.primaryColor,
                      title: medicine.name,
                      subtitle: 'Saved in My Medicines',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyMedicinesPage(),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          _SectionHeader(
            title: 'My Doctors Activity',
            icon: Icons.person,
            iconColor: AppConstants.accentColor,
          ),
          ValueListenableBuilder<Box<Doctor>>(
            valueListenable: doctorService.savedDoctorsListenable,
            builder: (context, box, _) {
              if (box.values.isEmpty) {
                return const _EmptyNotification(
                  message: 'No doctors saved',
                  hint: 'Save preferred doctors for faster access.',
                );
              }

              final doctors = box.values.toList(growable: false)
                ..sort((a, b) => a.name.compareTo(b.name));

              return Column(
                children: [
                  for (final doctor in doctors)
                    _NotificationCard(
                      icon: Icons.person_outline,
                      iconColor: AppConstants.accentColor,
                      title: doctor.name,
                      subtitle: doctor.specialty,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyDoctorsPage(),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppConstants.spacingLarge),
        ],
      ),
    );
  }

  static String _formatTimestamp(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSmall),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? timestamp;
  final VoidCallback? onTap;

  const _NotificationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.timestamp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(subtitle),
            if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  timestamp!,
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      ),
    );
  }
}

class _EmptyNotification extends StatelessWidget {
  final String message;
  final String hint;

  const _EmptyNotification({
    required this.message,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingLarge),
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppConstants.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            hint,
            style: TextStyle(color: AppConstants.textSecondaryColor),
          ),
        ],
      ),
    );
  }
}
