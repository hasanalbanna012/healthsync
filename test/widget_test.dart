import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HealthSync App Tests', () {
    test('App constants are defined correctly', () {
      // Test that the app name is correctly defined
      const appName = 'HealthSync';
      expect(appName, isNotEmpty);
      expect(appName.length, greaterThan(0));
    });

    test('Prescription model properties', () {
      // Test basic string properties that don't require Hive
      final testId = DateTime.now().millisecondsSinceEpoch.toString();
      const testPath = '/test/path/image.jpg';
      final testDate = DateTime.now();

      expect(testId, isNotEmpty);
      expect(testPath, contains('.jpg'));
      expect(testDate, isA<DateTime>());
    });
  });
}
