import 'package:flutter/material.dart';
import '../models/medical_document.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../constants/app_constants.dart';
import 'alarm_page.dart';
import 'document_gallery_page.dart';
import 'doctor_list_page.dart';
import 'health_index_page.dart';
import 'medicine_list_page.dart';
import 'nearby_hospital_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
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
                  builder: (context) => const DocumentGalleryPage(
                    type: MedicalDocumentType.testReport,
                  ),
                ),
              );
            }),
            _buildHomeSection('Prescriptions', Icons.medical_information, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DocumentGalleryPage(
                    type: MedicalDocumentType.prescription,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              ).then((_) {
                if (mounted) {
                  setState(() {
                    _currentIndex = 0;
                  });
                }
              });
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
