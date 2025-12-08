import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';
import '../models/doctor.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.isSaved,
    required this.onToggleSaved,
  });

  Future<void> _callDoctor(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final sanitized = doctor.contactNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (sanitized.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Contact number not available.')),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: sanitized);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Unable to start the call on this device.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonLabel =
        isSaved ? 'Remove from My Doctors' : 'Save to My Doctors';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusSmall),
                  child: doctor.imageUrl.isNotEmpty
                      ? Image.network(
                          doctor.imageUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 72,
                              height: 72,
                              color: AppConstants.backgroundColor,
                              child: const Icon(Icons.person, size: 36),
                            );
                          },
                        )
                      : Container(
                          width: 72,
                          height: 72,
                          color: AppConstants.backgroundColor,
                          child: const Icon(Icons.person, size: 36),
                        ),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialty,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppConstants.textSecondaryColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.address,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onToggleSaved,
                    icon: Icon(buttonIcon),
                    label: Text(buttonLabel),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                IconButton(
                  onPressed: () => _callDoctor(context),
                  icon: const Icon(Icons.call),
                  tooltip: 'Call doctor',
                  color: AppConstants.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Contact: ${doctor.contactNumber}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
