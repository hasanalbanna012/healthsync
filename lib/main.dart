import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/alarm.dart';
import 'models/bmi_record.dart';
import 'models/doctor.dart';
import 'models/prescription.dart';
import 'models/test_report.dart';
import 'pages/alarm_ring_screen.dart';
import 'pages/auth/login_page.dart';
import 'pages/home_page.dart';
import 'repositories/alarm_repository.dart';
import 'services/alarm_service.dart';
import 'services/navigation_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(PrescriptionAdapter());
  Hive.registerAdapter(TestReportAdapter());
  Hive.registerAdapter(AlarmAdapter());
  Hive.registerAdapter(AlarmTypeAdapter());
  Hive.registerAdapter(BMIRecordAdapter());
  Hive.registerAdapter(DoctorAdapter());

  // Open the boxes safely
  await _openBoxSafely<Prescription>('prescriptions');
  await _openBoxSafely<TestReport>('test_reports');
  await _openBoxSafely<Alarm>('alarms');
  await _openBoxSafely<BMIRecord>('bmi_records');
  await _openBoxSafely<Doctor>('saved_doctors');

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize alarm service
  await AlarmService().initialize();

  runApp(const MyApp());
}

Future<void> _openBoxSafely<T>(String boxName) async {
  try {
    await Hive.openBox<T>(boxName);
  } catch (e) {
    debugPrint('Error opening box $boxName: $e');
    // If the box is corrupted or has schema mismatch, delete it and recreate
    await Hive.deleteBoxFromDisk(boxName);
    await Hive.openBox<T>(boxName);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('com.example.healthsync/navigation');

  @override
  void initState() {
    super.initState();
    _setupNavigationListener();
  }

  void _setupNavigationListener() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'showAlarmRing') {
        final alarmId = call.arguments['alarmId'] as String?;
        final alarmTitle = call.arguments['alarmTitle'] as String?;
        final alarmDescription = call.arguments['alarmDescription'] as String?;

        if (alarmId != null) {
          _showAlarmRingScreen(alarmId, alarmTitle, alarmDescription);
        }
      }
    });
  }

  Future<void> _showAlarmRingScreen(
      String alarmId, String? title, String? description) async {
    try {
      // Get the alarm from repository
      final alarmRepository = AlarmRepository();
      final alarm = await alarmRepository.getAlarmById(alarmId);

      if (alarm != null && NavigationService.context != null) {
        // Navigate to alarm ring screen
        Navigator.of(NavigationService.context!).push(
          MaterialPageRoute(
            builder: (context) => AlarmRingScreen(alarm: alarm),
          ),
        );
      }
    } catch (e) {
      print('Error showing alarm ring screen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthSync',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Something went wrong. Please restart the app.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
