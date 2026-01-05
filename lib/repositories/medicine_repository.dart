import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../models/medicine.dart';

class MedicineRepository {
  MedicineRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  static const String _csvAssetPath = 'assets/data/medicine_list.csv';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _savedMedicinesCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('User not authenticated');
    }
    return _firestore.collection('users').doc(uid).collection('savedMedicines');
  }

  Stream<List<Medicine>> watchSavedMedicines() {
    return _savedMedicinesCollection.snapshots().map((snapshot) {
      final medicines = snapshot.docs
          .map((doc) => Medicine.fromMap(doc.data(), id: doc.id))
          .toList();
      medicines.sort((a, b) => a.name.compareTo(b.name));
      return medicines;
    });
  }

  Future<List<Medicine>> fetchSavedMedicines() async {
    final snapshot = await _savedMedicinesCollection.get();
    final medicines = snapshot.docs
        .map((doc) => Medicine.fromMap(doc.data(), id: doc.id))
        .toList();
    medicines.sort((a, b) => a.name.compareTo(b.name));
    return medicines;
  }

  Future<bool> isMedicineSaved(String medicineId) async {
    final doc = await _savedMedicinesCollection.doc(medicineId).get();
    return doc.exists;
  }

  Future<void> saveMedicine(Medicine medicine) async {
    await _savedMedicinesCollection.doc(medicine.id).set(medicine.toMap());
  }

  Future<void> removeMedicine(String medicineId) async {
    await _savedMedicinesCollection.doc(medicineId).delete();
  }

  Future<List<Medicine>> loadMedicinesFromAsset() async {
    final csvContent = await rootBundle.loadString(_csvAssetPath);
    final rows =
        const CsvToListConverter(shouldParseNumbers: false).convert(csvContent);

    if (rows.isEmpty) {
      return [];
    }

    final headers = rows.first.map((cell) => cell.toString()).toList();
    final medicines = <Medicine>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      final mappedRow = <String, String>{};
      for (var j = 0; j < headers.length && j < row.length; j++) {
        final cell = row[j];
        mappedRow[headers[j]] = cell == null ? '' : cell.toString().trim();
      }

      final name = mappedRow["Medicine's Name"];
      if (name == null || name.isEmpty) {
        continue;
      }

      final genericName = mappedRow['Generic Name'] ?? 'Generic not specified';
      final imageUrl = mappedRow['Image_1'] ?? '';

      medicines.add(
        Medicine(
          id: Medicine.buildId(name, genericName, i),
          name: name,
          genericName: genericName,
          imageUrl: imageUrl,
        ),
      );
    }

    return medicines;
  }
}
