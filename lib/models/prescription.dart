import 'package:hive/hive.dart';

part 'prescription.g.dart';

@HiveType(typeId: 0)
class Prescription extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final DateTime dateAdded;

  @HiveField(3)
  String? notes;

  @HiveField(4)
  String? doctorName;

  Prescription({
    required this.id,
    required this.imagePath,
    required this.dateAdded,
    this.notes,
    this.doctorName,
  });
}
