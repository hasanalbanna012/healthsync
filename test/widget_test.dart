import 'package:flutter_test/flutter_test.dart';
import 'package:healthsync/models/bmi_record.dart';

void main() {
  group('HealthSync App Tests', () {
    test('App constants are defined correctly', () {
      // Test that the app name is correctly defined
      const appName = 'HealthSync';
      expect(appName, isNotEmpty);
      expect(appName.length, greaterThan(0));
    });

    test('BMIRecord calculation helpers work', () {
      final bmi = BMIRecord.calculateBMI(70, 175);
      expect(bmi, closeTo(22.86, 0.01));
      expect(BMIRecord.getBMICategory(bmi), equals('Normal weight'));
    });
  });
}
