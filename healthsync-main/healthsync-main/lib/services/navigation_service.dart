import 'package:flutter/material.dart';
import '../pages/alarm_ring_screen.dart';
import '../models/alarm.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static Future<T?> pushNamed<T extends Object?>(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> push<T extends Object?>(Route<T> route) {
    return navigatorKey.currentState!.push<T>(route);
  }

  static void pop<T extends Object?>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }

  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    Route<T> newRoute,
    RoutePredicate predicate,
  ) {
    return navigatorKey.currentState!
        .pushAndRemoveUntil<T>(newRoute, predicate);
  }

  static Future<void> navigateToAlarmRing(String alarmId) async {
    if (context != null) {
      // For now, we'll need to get the alarm from the repository
      // This is a temporary solution until we pass the alarm object directly
      push(
        MaterialPageRoute(
          builder: (context) => AlarmRingScreen(
            alarm: Alarm(
              id: alarmId,
              title: 'Health Alarm',
              description: 'Time for your health reminder',
              dateTime: DateTime.now(),
              type: AlarmType.medication,
              isActive: true,
            ),
          ),
        ),
      );
    }
  }
}
