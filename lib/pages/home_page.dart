import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import '../models/prescription.dart';
import '../models/test_report.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/image_viewer.dart';
import '../widgets/app_drawer.dart';
import '../constants/app_constants.dart';
import 'alarm_page.dart';
import 'doctor_list_page.dart';
import 'health_index_page.dart';
import 'medicine_list_page.dart';
import 'nearby_hospital_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Box<Prescription> _prescriptionBox =
      Hive.box<Prescription>('prescriptions');
  final Box<TestReport> _testReportBox = Hive.box<TestReport>('test_reports');
  final ImagePicker _picker = ImagePicker();
  int _currentIndex = 0;

  Future<void> _pickImage(ImageSource source,
      {bool isTestReport = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        if (isTestReport) {
          final testReport = TestReport(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            imagePath: image.path,
            dateAdded: DateTime.now(),
          );
          await _testReportBox.add(testReport);
        } else {
          final prescription = Prescription(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            imagePath: image.path,
            dateAdded: DateTime.now(),
          );
          await _prescriptionBox.add(prescription);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isTestReport
                  ? AppConstants.testReportAddedMessage
                  : AppConstants.prescriptionAddedMessage),
              backgroundColor: AppConstants.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${AppConstants.imagePickErrorMessage}: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
          ),
        );
      }
    }
  }

  void _showAddDialog({bool isTestReport = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add ${isTestReport ? 'Test Report' : 'Prescription'}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppConstants.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppConstants.spacingSmall),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: Icon(Icons.camera_alt, color: AppConstants.primaryColor),
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Capture using camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, isTestReport: isTestReport);
              },
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppConstants.spacingSmall),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child:
                    Icon(Icons.photo_library, color: AppConstants.accentColor),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select existing photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isTestReport: isTestReport);
              },
            ),
            const SizedBox(height: AppConstants.spacingMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeSection(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.surfaceColor,
              AppConstants.cardColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: AppConstants.dividerColor,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(Box box, String title, VoidCallback onAddPressed,
      {bool enableTextDetection = false}) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: box.length == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    enableTextDetection
                        ? Icons.medical_information
                        : Icons.description,
                    size: 64,
                    color: AppConstants.textDisabledColor,
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text(
                    'No ${title.toLowerCase()} yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppConstants.textSecondaryColor,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    'Tap the + button to add your first ${title.toLowerCase().substring(0, title.length - 1)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textDisabledColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.spacingMedium,
                mainAxisSpacing: AppConstants.spacingMedium,
                childAspectRatio: 0.8,
              ),
              itemCount: box.length,
              itemBuilder: (context, index) {
                final item = box.getAt(index);
                if (item?.imagePath == null) return const SizedBox.shrink();

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageViewer(
                          imagePath: item!.imagePath,
                          title: title,
                          enableTextDetection: enableTextDetection,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppConstants.surfaceColor,
                      borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppConstants.primaryColor.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(
                                  AppConstants.borderRadiusMedium),
                            ),
                            child: Image.file(
                              File(item!.imagePath),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppConstants.cardColor,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 40,
                                          color: AppConstants.textDisabledColor,
                                        ),
                                        const SizedBox(
                                            height: AppConstants.spacingSmall),
                                        Text(
                                          'Image not found',
                                          style: TextStyle(
                                            color:
                                                AppConstants.textDisabledColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.all(AppConstants.spacingSmall),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${title.substring(0, title.length - 1)} ${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.textPrimaryColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Added ${_formatDate(item.dateAdded)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddPressed,
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: AppConstants.elevationMedium,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('HealthSync'),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: AppConstants.spacingLarge,
          crossAxisSpacing: AppConstants.spacingLarge,
          children: [
            _buildHomeSection('Medicine', Icons.medication, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicineListPage(),
                ),
              );
            }),
            _buildHomeSection('Alarm', Icons.alarm, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlarmPage(),
                ),
              );
            }),
            _buildHomeSection('Doctors', Icons.person_2, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DoctorListPage(),
                ),
              );
            }),
            _buildHomeSection('Test Reports', Icons.description, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ValueListenableBuilder(
                    valueListenable: _testReportBox.listenable(),
                    builder: (context, Box<TestReport> box, _) {
                      return _buildImageGrid(
                        box,
                        'Test Reports',
                        () => _showAddDialog(isTestReport: true),
                        enableTextDetection: true,
                      );
                    },
                  ),
                ),
              );
            }),
            _buildHomeSection('Prescriptions', Icons.medical_information, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ValueListenableBuilder(
                    valueListenable: _prescriptionBox.listenable(),
                    builder: (context, Box<Prescription> box, _) {
                      return _buildImageGrid(
                        box,
                        'Prescriptions',
                        () => _showAddDialog(),
                        enableTextDetection: true,
                      );
                    },
                  ),
                ),
              );
            }),
            _buildHomeSection('Health Index', Icons.health_and_safety, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HealthIndexPage(),
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              // Already on home, do nothing
              break;
            case 1:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(AppConstants.notificationsComingSoon),
                  backgroundColor: AppConstants.infoColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NearbyHospitalPage(),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}
