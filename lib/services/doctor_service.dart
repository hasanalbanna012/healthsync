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

  Stream<List<Doctor>> watchSavedDoctors() => _repository.watchSavedDoctors();

  Future<List<Doctor>> fetchSavedDoctors() => _repository.fetchSavedDoctors();

  Future<bool> isDoctorSaved(String doctorId) =>
      _repository.isDoctorSaved(doctorId);

  Future<void> saveDoctor(Doctor doctor) => _repository.saveDoctor(doctor);

  Future<void> removeDoctor(String doctorId) =>
      _repository.removeDoctor(doctorId);
}
