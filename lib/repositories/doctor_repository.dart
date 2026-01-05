import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../models/doctor.dart';

class DoctorRepository {
  DoctorRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  static const String _csvAssetPath = 'assets/data/doctors_final.csv';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _savedDoctorsCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('User not authenticated');
    }
    return _firestore.collection('users').doc(uid).collection('savedDoctors');
  }

  Stream<List<Doctor>> watchSavedDoctors() {
    return _savedDoctorsCollection.snapshots().map((snapshot) {
      final doctors = snapshot.docs
          .map((doc) => Doctor.fromMap(doc.data(), id: doc.id))
          .toList();
      doctors.sort((a, b) => a.name.compareTo(b.name));
      return doctors;
    });
  }

  Future<List<Doctor>> fetchSavedDoctors() async {
    final snapshot = await _savedDoctorsCollection.get();
    final doctors = snapshot.docs
        .map((doc) => Doctor.fromMap(doc.data(), id: doc.id))
        .toList();
    doctors.sort((a, b) => a.name.compareTo(b.name));
    return doctors;
  }

  Future<bool> isDoctorSaved(String doctorId) async {
    final doc = await _savedDoctorsCollection.doc(doctorId).get();
    return doc.exists;
  }

  Future<void> saveDoctor(Doctor doctor) async {
    await _savedDoctorsCollection.doc(doctor.id).set(doctor.toMap());
  }

  Future<void> removeDoctor(String doctorId) async {
    await _savedDoctorsCollection.doc(doctorId).delete();
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
