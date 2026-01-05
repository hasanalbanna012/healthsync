import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';
import '../models/medicine.dart';
import '../services/medicine_service.dart';
import '../widgets/medicine_card.dart';
import 'my_medicines_page.dart';

class MedicineListPage extends StatefulWidget {
  const MedicineListPage({super.key});

  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  final MedicineService _medicineService = MedicineService();
  final TextEditingController _searchController = TextEditingController();
  static final Uri _buyMedicineUri = Uri.parse('https://medeasy.health/');
  late final Stream<List<Medicine>> _savedMedicinesStream;

  List<Medicine> _allMedicines = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _savedMedicinesStream = _medicineService.watchSavedMedicines();
    _loadMedicines();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicines() async {
    try {
      final medicines = await _medicineService.getAllMedicines();
      setState(() {
        _allMedicines = medicines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to load medicines at the moment. Please try again later.';
      });
    }
  }

  List<Medicine> _filteredMedicines() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _allMedicines;
    }

    return _allMedicines.where((medicine) {
      final nameMatch = medicine.name.toLowerCase().contains(query);
      final genericMatch = medicine.genericName.toLowerCase().contains(query);
      return nameMatch || genericMatch;
    }).toList();
  }

  Future<void> _toggleSaved(Medicine medicine, bool isSaved) async {
    if (isSaved) {
      await _medicineService.removeMedicine(medicine.id);
    } else {
      await _medicineService.saveMedicine(medicine);
    }
  }

  Future<void> _openBuyMedicine() async {
    final success = await launchUrl(
      _buyMedicineUri,
      mode: LaunchMode.inAppBrowserView,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open MedEasy right now.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_added_outlined),
            tooltip: 'My Medicines',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyMedicinesPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openBuyMedicine,
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: const Text('Buy Medicine'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.spacingSmall,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by medicine or generic name',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMedium,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      Expanded(
                        child: StreamBuilder<List<Medicine>>(
                          stream: _savedMedicinesStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Unable to sync saved medicines. ${snapshot.error}',
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final savedIds = snapshot.data!
                                .map((medicine) => medicine.id)
                                .toSet();
                            final filtered = _filteredMedicines();

                            if (filtered.isEmpty) {
                              return const Center(
                                child: Text('No medicines match your search.'),
                              );
                            }

                            return ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final medicine = filtered[index];
                                final isSaved = savedIds.contains(medicine.id);
                                return MedicineCard(
                                  medicine: medicine,
                                  isSaved: isSaved,
                                  onToggleSaved: () =>
                                      _toggleSaved(medicine, isSaved),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
