import 'package:cloud_firestore/cloud_firestore.dart';

class Alarm {
  String id;
  String title;
  String description;
  DateTime dateTime;
  bool isActive;
  AlarmType type;
  List<int> repeatDays; // 1=Monday, 2=Tuesday, etc. Empty = no repeat
  String? prescriptionId; // Link to prescription if it's a medication alarm
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

  factory Alarm.fromMap(Map<String, dynamic> data, {required String id}) {
    return Alarm(
      id: id,
      title: (data['title'] as String?)?.trim() ?? '',
      description: (data['description'] as String?)?.trim() ?? '',
      dateTime: _parseDateTime(data['dateTime']) ?? DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
      type: _parseAlarmType(data['type'] as String?),
      repeatDays: _parseRepeatDays(data['repeatDays']),
      prescriptionId: data['prescriptionId'] as String?,
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'isActive': isActive,
      'type': type.name,
      'repeatDays': repeatDays,
      'prescriptionId': prescriptionId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Alarm copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isActive,
    AlarmType? type,
    List<int>? repeatDays,
    String? prescriptionId,
    DateTime? createdAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      repeatDays: repeatDays ?? List<int>.from(this.repeatDays),
      prescriptionId: prescriptionId ?? this.prescriptionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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
        repeatDays.contains(6) &&
        repeatDays.contains(7)) {
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

List<int> _parseRepeatDays(dynamic value) {
  if (value is Iterable) {
    return value
        .map((entry) => entry is int ? entry : int.tryParse('$entry') ?? 0)
        .where((entry) => entry > 0)
        .toList()
      ..sort();
  }
  return const [];
}

AlarmType _parseAlarmType(String? raw) {
  if (raw == null || raw.isEmpty) {
    return AlarmType.medication;
  }
  return AlarmType.values.firstWhere(
    (type) => type.name == raw,
    orElse: () => AlarmType.medication,
  );
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

enum AlarmType {
  medication,
  appointment,
  exercise,
  vitals,
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
