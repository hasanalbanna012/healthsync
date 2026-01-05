import '../models/medicine.dart';
import '../repositories/medicine_repository.dart';

class MedicineService {
  MedicineService._internal();
  static final MedicineService _instance = MedicineService._internal();
  factory MedicineService() => _instance;

  final MedicineRepository _repository = MedicineRepository();
  List<Medicine>? _cachedMedicines;

  Future<List<Medicine>> getAllMedicines() async {
    _cachedMedicines ??= await _repository.loadMedicinesFromAsset();
    return _cachedMedicines!;
  }

  Stream<List<Medicine>> watchSavedMedicines() =>
      _repository.watchSavedMedicines();

  Future<List<Medicine>> fetchSavedMedicines() =>
      _repository.fetchSavedMedicines();

  Future<bool> isMedicineSaved(String medicineId) =>
      _repository.isMedicineSaved(medicineId);

  Future<void> saveMedicine(Medicine medicine) =>
      _repository.saveMedicine(medicine);

  Future<void> removeMedicine(String medicineId) =>
      _repository.removeMedicine(medicineId);
}
