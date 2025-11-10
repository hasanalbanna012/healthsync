import 'package:hive/hive.dart';
import '../models/alarm.dart';

class AlarmRepository {
  static const String _boxName = 'alarms';
  
  Future<Box<Alarm>> get _box async => await Hive.openBox<Alarm>(_boxName);

  Future<List<Alarm>> getAllAlarms() async {
    final box = await _box;
    return box.values.toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Future<List<Alarm>> getActiveAlarms() async {
    final alarms = await getAllAlarms();
    return alarms.where((alarm) => alarm.isActive).toList();
  }

  Future<List<Alarm>> getUpcomingAlarms({int days = 7}) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    
    final alarms = await getActiveAlarms();
    return alarms.where((alarm) {
      final nextTime = alarm.nextAlarmTime;
      return nextTime != null && 
             nextTime.isBefore(endDate) && 
             nextTime.isAfter(now);
    }).toList();
  }

  Future<List<Alarm>> getAlarmsByType(AlarmType type) async {
    final alarms = await getAllAlarms();
    return alarms.where((alarm) => alarm.type == type).toList();
  }

  Future<List<Alarm>> getMedicationAlarms() async {
    return await getAlarmsByType(AlarmType.medication);
  }

  Future<Alarm?> getAlarmById(String id) async {
    final box = await _box;
    return box.values.firstWhere(
      (alarm) => alarm.id == id,
      orElse: () => throw StateError('Alarm not found'),
    );
  }

  Future<void> saveAlarm(Alarm alarm) async {
    final box = await _box;
    await box.put(alarm.id, alarm);
  }

  Future<void> updateAlarm(Alarm alarm) async {
    await saveAlarm(alarm);
  }

  Future<void> deleteAlarm(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<void> toggleAlarmStatus(String id) async {
    final alarm = await getAlarmById(id);
    if (alarm != null) {
      alarm.isActive = !alarm.isActive;
      await updateAlarm(alarm);
    }
  }

  Future<void> deleteAllAlarms() async {
    final box = await _box;
    await box.clear();
  }

  Future<int> getAlarmCount() async {
    final box = await _box;
    return box.length;
  }

  Future<int> getActiveAlarmCount() async {
    final alarms = await getActiveAlarms();
    return alarms.length;
  }

  Stream<List<Alarm>> watchAlarms() async* {
    final box = await _box;
    yield* box.watch().asyncMap((_) async => await getAllAlarms());
  }

  Stream<List<Alarm>> watchActiveAlarms() async* {
    final box = await _box;
    yield* box.watch().asyncMap((_) async => await getActiveAlarms());
  }
}
