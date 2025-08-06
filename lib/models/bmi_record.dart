import 'package:hive/hive.dart';

part 'bmi_record.g.dart';

@HiveType(typeId: 4)
class BMIRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double weight; // in kg

  @HiveField(2)
  double height; // in cm

  @HiveField(3)
  double bmi;

  @HiveField(4)
  String category;

  @HiveField(5)
  DateTime dateRecorded;

  @HiveField(6)
  String? notes;

  BMIRecord({
    required this.id,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.category,
    required this.dateRecorded,
    this.notes,
  });

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Normal weight';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  static double calculateBMI(double weight, double height) {
    // height in cm, weight in kg
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }
}
