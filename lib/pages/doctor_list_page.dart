import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/doctor.dart';
import '../services/doctor_service.dart';
import '../widgets/doctor_card.dart';
import 'my_doctors_page.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final DoctorService _doctorService = DoctorService();
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<Doctor>> _savedDoctorsStream;

  List<Doctor> _allDoctors = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _savedDoctorsStream = _doctorService.watchSavedDoctors();
    _loadDoctors();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await _doctorService.getAllDoctors();
      setState(() {
        _allDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to load doctors at the moment. Please try again later.';
      });
    }
  }

  List<Doctor> _filteredDoctors() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _allDoctors;
    }

    return _allDoctors
        .where((doctor) => doctor.name.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _toggleSaved(Doctor doctor, bool isSaved) async {
    if (isSaved) {
      await _doctorService.removeDoctor(doctor.id);
    } else {
      await _doctorService.saveDoctor(doctor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_added_outlined),
            tooltip: 'My Doctors',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyDoctorsPage(),
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
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by doctor name',
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
                        child: StreamBuilder<List<Doctor>>(
                          stream: _savedDoctorsStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Unable to sync saved doctors. ${snapshot.error}',
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
                                .map((doctor) => doctor.id)
                                .toSet();
                            final filtered = _filteredDoctors();

                            if (filtered.isEmpty) {
                              return const Center(
                                child: Text('No doctors match your search.'),
                              );
                            }

                            return ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final doctor = filtered[index];
                                final isSaved = savedIds.contains(doctor.id);
                                return DoctorCard(
                                  doctor: doctor,
                                  isSaved: isSaved,
                                  onToggleSaved: () =>
                                      _toggleSaved(doctor, isSaved),
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
