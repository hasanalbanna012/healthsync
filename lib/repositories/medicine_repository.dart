import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/medicine.dart';

class MedicineRepository {
  static const String savedMedicinesBoxName = 'saved_medicines';
  static const String _csvAssetPath = 'assets/data/medicine_list.csv';

  Box<Medicine> get _savedBox => Hive.box<Medicine>(savedMedicinesBoxName);

  ValueListenable<Box<Medicine>> get savedMedicinesListenable =>
      _savedBox.listenable();

  List<Medicine> getSavedMedicines() =>
      _savedBox.values.toList(growable: false);

  bool isMedicineSaved(String medicineId) => _savedBox.containsKey(medicineId);

  Future<void> saveMedicine(Medicine medicine) async {
    await _savedBox.put(medicine.id, medicine);
  }

  Future<void> removeMedicine(String medicineId) async {
    await _savedBox.delete(medicineId);
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
