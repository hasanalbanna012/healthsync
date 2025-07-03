import 'package:hive/hive.dart';

part 'test_report.g.dart';

@HiveType(typeId: 1)
class TestReport extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final DateTime dateAdded;

  TestReport({
    required this.id,
    required this.imagePath,
    required this.dateAdded,
  });
}