// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TestReportAdapter extends TypeAdapter<TestReport> {
  @override
  final int typeId = 1;

  @override
  TestReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestReport(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      dateAdded: fields[2] as DateTime,
      testType: fields[3] as String?,
      hospitalName: fields[4] as String?,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TestReport obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.dateAdded)
      ..writeByte(3)
      ..write(obj.testType)
      ..writeByte(4)
      ..write(obj.hospitalName)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
