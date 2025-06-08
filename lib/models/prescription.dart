// First run: flutter pub add hive
// Then the import will work:
import 'package:hive/hive.dart';

// Run 'flutter pub run build_runner build' to generate the part file
part 'prescription.g.dart';

@HiveType(typeId: 0)
class Prescription extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final DateTime dateAdded;

  Prescription({
    required this.id,
    required this.imagePath,
    required this.dateAdded,
  });
}