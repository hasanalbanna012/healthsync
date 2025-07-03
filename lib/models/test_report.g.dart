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
    );
  }

  @override
  void write(BinaryWriter writer, TestReport obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.dateAdded);
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
