// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmAdapter extends TypeAdapter<Alarm> {
  @override
  final int typeId = 2;

  @override
  Alarm read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alarm(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      dateTime: fields[3] as DateTime,
      isActive: fields[4] as bool,
      type: fields[5] as AlarmType,
      repeatDays: (fields[6] as List).cast<int>(),
      prescriptionId: fields[7] as String?,
      createdAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Alarm obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.dateTime)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.repeatDays)
      ..writeByte(7)
      ..write(obj.prescriptionId)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlarmTypeAdapter extends TypeAdapter<AlarmType> {
  @override
  final int typeId = 3;

  @override
  AlarmType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlarmType.medication;
      case 1:
        return AlarmType.appointment;
      case 2:
        return AlarmType.exercise;
      case 3:
        return AlarmType.vitals;
      case 4:
        return AlarmType.other;
      default:
        return AlarmType.medication;
    }
  }

  @override
  void write(BinaryWriter writer, AlarmType obj) {
    switch (obj) {
      case AlarmType.medication:
        writer.writeByte(0);
        break;
      case AlarmType.appointment:
        writer.writeByte(1);
        break;
      case AlarmType.exercise:
        writer.writeByte(2);
        break;
      case AlarmType.vitals:
        writer.writeByte(3);
        break;
      case AlarmType.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
