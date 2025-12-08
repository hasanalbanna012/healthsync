import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/doctor.dart';

class DoctorRepository {
  static const String savedDoctorsBoxName = 'saved_doctors';
  static const String _csvAssetPath = 'assets/data/doctors_final.csv';

  Box<Doctor> get _savedDoctorsBox => Hive.box<Doctor>(savedDoctorsBoxName);

  ValueListenable<Box<Doctor>> get savedDoctorsListenable =>
      _savedDoctorsBox.listenable();

  List<Doctor> getSavedDoctors() =>
      _savedDoctorsBox.values.toList(growable: false);

  bool isDoctorSaved(String doctorId) => _savedDoctorsBox.containsKey(doctorId);

  Future<void> saveDoctor(Doctor doctor) async {
    await _savedDoctorsBox.put(doctor.id, doctor);
  }

  Future<void> removeDoctor(String doctorId) async {
    await _savedDoctorsBox.delete(doctorId);
  }

  Future<List<Doctor>> loadDoctorsFromAsset() async {
    final csvContent = await rootBundle.loadString(_csvAssetPath);
    final rows =
        const CsvToListConverter(shouldParseNumbers: false).convert(csvContent);

    if (rows.isEmpty) {
      return [];
    }

    final headers = rows.first.map((cell) => cell.toString()).toList();
    final doctors = <Doctor>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      final mappedRow = <String, String>{};
      for (var j = 0; j < headers.length && j < row.length; j++) {
        final cell = row[j];
        mappedRow[headers[j]] = cell == null ? '' : cell.toString().trim();
      }

      final name = mappedRow["Doctor's Name"];
      if (name == null || name.isEmpty) {
        continue;
      }

      final specialty = mappedRow['Specialty'] ?? 'General Practitioner';
      final address = mappedRow['Address'] ?? 'Address not provided';
      final contactNumber = mappedRow['Contact Number'] ?? '';
      final imageUrl = mappedRow['Image'] ?? '';

      doctors.add(
        Doctor(
          id: Doctor.buildId(name, specialty, i),
          name: name,
          specialty: specialty,
          address: address,
          contactNumber: contactNumber,
          imageUrl: imageUrl,
        ),
      );
    }

    return doctors;
  }
}
