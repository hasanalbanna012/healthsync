import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/prescription.dart';
import 'models/test_report.dart';
import 'models/alarm.dart';
import 'pages/home_page.dart';
import 'pages/alarm_ring_screen.dart';
import 'theme/app_theme.dart';
import 'services/navigation_service.dart';
import 'services/alarm_service.dart';
import 'repositories/alarm_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(PrescriptionAdapter());
  Hive.registerAdapter(TestReportAdapter());
  Hive.registerAdapter(AlarmAdapter());
  Hive.registerAdapter(AlarmTypeAdapter());

  // Open the boxes
  await Hive.openBox<Prescription>('prescriptions');
  await Hive.openBox<TestReport>('test_reports');
  await Hive.openBox<Alarm>('alarms');

  // Initialize alarm service
  await AlarmService().initialize();

  runApp(const MyApp());
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
      home: const HomePage(),
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
    );
  }
}
