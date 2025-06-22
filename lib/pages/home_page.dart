import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import '../models/prescription.dart';
import '../widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Box<Prescription> _prescriptionBox = Hive.box<Prescription>(
    'prescriptions',
  );
  final ImagePicker _picker = ImagePicker();
  int _currentIndex = 0;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final prescription = Prescription(
          id: DateTime.now().toString(),
          imagePath: image.path,
          dateAdded: DateTime.now(),
        );
        await _prescriptionBox.add(prescription);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _showAddPrescriptionDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeSection(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      appBar: AppBar(
        title: const Text('HealthSync'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildHomeSection('Medicine', Icons.medication, () {}),
            _buildHomeSection('Alarm', Icons.alarm, () {}),
            _buildHomeSection('Doctors', Icons.person_2, () {}),
            _buildHomeSection('Test Reports', Icons.description, () {}),
            _buildHomeSection('Prescriptions', Icons.medical_information, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ValueListenableBuilder(
                    valueListenable: _prescriptionBox.listenable(),
                    builder: (context, Box<Prescription> box, _) {
                      return Scaffold(
                        appBar: AppBar(title: const Text('Prescriptions')),
                        body: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: box.length,
                          itemBuilder: (context, index) {
                            final prescription = box.getAt(index);
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.file(
                                File(prescription!.imagePath),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                        floatingActionButton: FloatingActionButton(
                          onPressed: _showAddPrescriptionDialog,
                          child: const Icon(Icons.add),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
            _buildHomeSection('Health Index', Icons.health_and_safety, () {}),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // TODO: Implement navigation for other sections
        },
      ),
    );
  }
}
