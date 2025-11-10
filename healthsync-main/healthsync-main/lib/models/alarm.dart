import 'package:hive/hive.dart';

part 'alarm.g.dart';

@HiveType(typeId: 2)
class Alarm extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dateTime;

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  AlarmType type;

  @HiveField(6)
  List<int> repeatDays; // 1=Monday, 2=Tuesday, etc. Empty = no repeat

  @HiveField(7)
  String? prescriptionId; // Link to prescription if it's a medication alarm

  @HiveField(8)
  DateTime createdAt;

  Alarm({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isActive = true,
    this.type = AlarmType.medication,
    this.repeatDays = const [],
    this.prescriptionId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isRepeating => repeatDays.isNotEmpty;

  String get repeatDaysString {
    if (!isRepeating) return 'Once';
    
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (repeatDays.length == 7) return 'Daily';
    if (repeatDays.length == 5 && 
        repeatDays.every((day) => day >= 1 && day <= 5)) {
      return 'Weekdays';
    }
    if (repeatDays.length == 2 && 
        repeatDays.contains(6) && repeatDays.contains(7)) {
      return 'Weekends';
    }
    
    return repeatDays.map((day) => dayNames[day - 1]).join(', ');
  }

  DateTime? get nextAlarmTime {
    if (!isActive) return null;
    
    final now = DateTime.now();
    
    if (!isRepeating) {
      return dateTime.isAfter(now) ? dateTime : null;
    }
    
    // For repeating alarms, find the next occurrence
    final today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final checkDate = today.add(Duration(days: i));
      final weekday = checkDate.weekday;
      
      if (repeatDays.contains(weekday)) {
        final alarmDateTime = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
          dateTime.hour,
          dateTime.minute,
        );
        
        if (alarmDateTime.isAfter(now)) {
          return alarmDateTime;
        }
      }
    }
    
    return null;
  }
}

@HiveType(typeId: 3)
enum AlarmType {
  @HiveField(0)
  medication,
  
  @HiveField(1)
  appointment,
  
  @HiveField(2)
  exercise,
  
  @HiveField(3)
  vitals,
  
  @HiveField(4)
  other,
}

extension AlarmTypeExtension on AlarmType {
  String get displayName {
    switch (this) {
      case AlarmType.medication:
        return 'Medication';
      case AlarmType.appointment:
        return 'Appointment';
      case AlarmType.exercise:
        return 'Exercise';
      case AlarmType.vitals:
        return 'Check Vitals';
      case AlarmType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case AlarmType.medication:
        return '💊';
      case AlarmType.appointment:
        return '🏥';
      case AlarmType.exercise:
        return '🏃';
      case AlarmType.vitals:
        return '🩺';
      case AlarmType.other:
        return '⏰';
    }
  }
}
