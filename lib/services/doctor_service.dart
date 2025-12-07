import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/doctor.dart';
import '../repositories/doctor_repository.dart';

class DoctorService {
  DoctorService._internal();
  static final DoctorService _instance = DoctorService._internal();
  factory DoctorService() => _instance;

  final DoctorRepository _repository = DoctorRepository();
  List<Doctor>? _cachedDoctors;

  Future<List<Doctor>> getAllDoctors() async {
    _cachedDoctors ??= await _repository.loadDoctorsFromAsset();
    return _cachedDoctors!;
  }

  List<Doctor> getSavedDoctors() => _repository.getSavedDoctors();

  ValueListenable<Box<Doctor>> get savedDoctorsListenable =>
      _repository.savedDoctorsListenable;

  bool isDoctorSaved(String doctorId) =>
      _repository.isDoctorSaved(doctorId);

  Future<void> saveDoctor(Doctor doctor) => _repository.saveDoctor(doctor);

  Future<void> removeDoctor(String doctorId) =>
      _repository.removeDoctor(doctorId);
}
